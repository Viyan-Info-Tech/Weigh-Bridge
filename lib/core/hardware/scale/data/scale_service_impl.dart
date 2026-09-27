import 'dart:async';
import 'dart:math' as math;

import '../domain/scale_models.dart';
import '../domain/scale_protocol.dart';
import '../domain/scale_service.dart';
import '../domain/scale_status.dart';
import '../domain/serial_transport.dart';
import 'protocols/scale_protocol_registry.dart';

/// Production [ScaleService] implementation.
///
/// Owns lifecycle and every hardware-specific concern that must be available
/// before any concrete protocol parser exists: opening/validating the port,
/// automatic reconnection with capped exponential backoff, staleness
/// detection, per-reading validation, and diagnostics streams.
class ScaleServiceImpl implements ScaleService {
  ScaleServiceImpl({
    required SerialTransport Function() transportFactory,
    ScaleConfig config = const ScaleConfig(),
    ScaleProtocol? protocol,
    FrameTerminator? frameTerminator,
    Duration staleTimeout = const Duration(seconds: 30),
    Duration reconnectBaseDelay = const Duration(seconds: 1),
    Duration reconnectMaxDelay = const Duration(seconds: 30),
    double maxPlausibleKg = 150000,
    DateTime Function()? now,
  }) : _transportFactory = transportFactory,
       _config = config,
       _explicitProtocol = protocol,
       _explicitFrameTerminator = frameTerminator,
       _staleTimeout = staleTimeout,
       _reconnectBaseDelay = reconnectBaseDelay,
       _reconnectMaxDelay = reconnectMaxDelay,
       _maxPlausibleKg = maxPlausibleKg,
       _now = now ?? DateTime.now {
    _resolveProtocolAndDecoder();
  }

  final SerialTransport Function() _transportFactory;
  final ScaleProtocol? _explicitProtocol;
  final FrameTerminator? _explicitFrameTerminator;
  final Duration _staleTimeout;
  final Duration _reconnectBaseDelay;
  final Duration _reconnectMaxDelay;
  final double _maxPlausibleKg;
  final DateTime Function() _now;

  late ScaleProtocol _protocol;
  late FrameDecoder _decoder;

  void _resolveProtocolAndDecoder() {
    _protocol =
        _explicitProtocol ??
        ScaleProtocolRegistry.getProtocol(_config.protocol);
    final terminator =
        _explicitFrameTerminator ??
        ScaleProtocolRegistry.getTerminator(_config.protocol);
    _decoder = FrameDecoder(terminator: terminator);
  }

  final StreamController<ScaleReading> _weightController =
      StreamController<ScaleReading>.broadcast();
  final StreamController<ScaleStatus> _statusController =
      StreamController<ScaleStatus>.broadcast();
  final StreamController<List<int>> _rawController =
      StreamController<List<int>>.broadcast();

  SerialTransport? _transport;
  StreamSubscription<List<int>>? _dataSubscription;
  Timer? _reconnectTimer;
  Timer? _staleTimer;

  ScaleConfig _config;
  ScaleStatus _status = const ScaleStatus();

  bool _active = false;
  bool _connecting = false;
  bool _manualDisconnect = false;

  double? _lastEmittedWeight;
  DateTime? _lastEmittedAt;

  @override
  Stream<ScaleReading> get weightStream => _weightController.stream;

  @override
  Stream<ScaleStatus> get statusStream => _statusController.stream;

  @override
  Stream<List<int>> get rawBytesStream => _rawController.stream;

  @override
  ScaleStatus get currentStatus => _status;

  @override
  ScaleConfig get config => _config;

  @override
  Future<void> start() async {
    _active = true;
    _manualDisconnect = false;
    if (!_config.enabled) {
      _emitStatus(const ScaleStatus(state: ScaleConnectionState.disconnected));
      return;
    }
    await connect();
  }

  @override
  Future<void> connect({ScaleConfig? config}) async {
    if (config != null) {
      _config = config;
      _resolveProtocolAndDecoder();
    }
    if (_connecting) return;
    _connecting = true;
    _cancelReconnect();
    _manualDisconnect = false;
    if (!_active) _active = true;

    _emitStatus(
      _status.copyWith(
        state: ScaleConnectionState.connecting,
        error: null,
        clearError: true,
      ),
    );

    // Ensure previous transport is completely disconnected and released before creating a new one
    final oldTransport = _transport;
    _transport = null;
    await _dataSubscription?.cancel();
    _dataSubscription = null;
    if (oldTransport != null) {
      await oldTransport.disconnect();
    }

    final transport = _transportFactory();
    try {
      final result = await transport.connect(_config);
      if (result.success) {
        _transport = transport;
        _attachDataListener();
        _decoder.clear();
        _lastEmittedWeight = null;
        _lastEmittedAt = null;
        _startStaleTimer();
        _emitStatus(
          _status.copyWith(
            state: ScaleConnectionState.connected,
            reconnectAttempt: 0,
            stale: false,
            error: null,
            clearError: true,
          ),
        );
      } else {
        await transport.disconnect();
        _handleConnectFailure(result.error ?? 'Connection failed');
      }
    } on Object catch (e) {
      await transport.disconnect();
      _handleConnectFailure('$e');
    } finally {
      _connecting = false;
    }
  }

  void _attachDataListener() {
    final transport = _transport!;
    unawaited(_dataSubscription?.cancel());
    _dataSubscription = transport.dataStream.listen(
      _onBytes,
      onError: (Object e, StackTrace s) => _onTransportError(e),
      onDone: _onTransportClosed,
    );
  }

  void _onBytes(List<int> chunk) {
    if (_rawController.isClosed) return;
    _rawController.add(chunk);

    final receivedAt = _now();
    final frames = _decoder.feed(chunk, receivedAt);
    if (frames.isNotEmpty) {
      _emitStatus(_status.copyWith(lastReceivedAt: receivedAt, stale: false));
    }

    for (final frame in frames) {
      final parsed = _protocol.parse(frame);
      if (parsed == null || !parsed.isValid) {
        continue;
      }
      _onParsed(parsed, frame.receivedAt);
    }
  }

  void _onParsed(ParsedScaleFrame parsed, DateTime receivedAt) {
    final weight = parsed.weightKg!;
    if (weight > _maxPlausibleKg) {
      return;
    }

    final isDuplicate =
        weight == _lastEmittedWeight &&
        _lastEmittedAt != null &&
        receivedAt.difference(_lastEmittedAt!) <
            const Duration(milliseconds: 250);
    if (!isDuplicate) {
      _lastEmittedWeight = weight;
      _lastEmittedAt = receivedAt;
      if (!_weightController.isClosed) {
        _weightController.add(
          ScaleReading(
            weightKg: weight,
            stable: parsed.stable,
            isMotion: parsed.isMotion,
            isOverload: parsed.isOverload,
            receivedAt: receivedAt,
          ),
        );
      }
    }

    _emitStatus(
      _status.copyWith(
        currentWeightKg: weight,
        clearCurrentWeight: false,
        stable: parsed.stable,
        isMotion: parsed.isMotion,
        isOverload: parsed.isOverload,
        stale: false,
        lastReceivedAt: receivedAt,
      ),
    );
  }

  void _handleConnectFailure(String reason) {
    _emitStatus(
      _status.copyWith(
        state: _shouldAutoReconnect()
            ? ScaleConnectionState.reconnecting
            : ScaleConnectionState.error,
        error: reason,
        clearCurrentWeight: true,
      ),
    );
    if (_shouldAutoReconnect()) {
      _scheduleReconnect();
    }
  }

  void _onTransportError(Object e) {
    final transport = _transport;
    _transport = null;
    _dataSubscription?.cancel();
    _dataSubscription = null;
    _stopStaleTimer();
    _emitStatus(
      _status.copyWith(
        state: _shouldAutoReconnect()
            ? ScaleConnectionState.reconnecting
            : ScaleConnectionState.disconnected,
        error: '$e',
        clearCurrentWeight: true,
      ),
    );
    transport?.disconnect();
    if (_shouldAutoReconnect()) {
      _scheduleReconnect();
    }
  }

  void _onTransportClosed() {
    _onTransportError(const SerialTransportDisconnected('Port closed'));
  }

  bool _shouldAutoReconnect() =>
      _active && _config.enabled && !_manualDisconnect;

  void _scheduleReconnect() {
    _cancelReconnect();
    final attempt = _status.reconnectAttempt + 1;
    final exponent = math.min(attempt - 1, 5);
    final delay = _reconnectBaseDelay * math.pow(2, exponent).toDouble();
    final capped = delay > _reconnectMaxDelay ? _reconnectMaxDelay : delay;
    _emitStatus(
      _status.copyWith(
        reconnectAttempt: attempt,
        error: 'Reconnecting in ${capped.inSeconds}s – ${_config.port}',
      ),
    );
    _reconnectTimer = Timer(capped, () {
      if (_active && !_connecting && !(_status.isConnected)) {
        unawaited(connect());
      }
    });
  }

  void _startStaleTimer() {
    _staleTimer?.cancel();
    _staleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_status.isConnected) return;
      final lastReceivedAt = _status.lastReceivedAt;
      if (lastReceivedAt == null) return;
      final stale = _now().difference(lastReceivedAt) > _staleTimeout;
      if (stale != _status.stale) {
        _emitStatus(_status.copyWith(stale: stale));
      }
    });
  }

  void _stopStaleTimer() {
    _staleTimer?.cancel();
    _staleTimer = null;
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _emitStatus(ScaleStatus status) {
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _cancelReconnect();
    _stopStaleTimer();
    final transport = _transport;
    _transport = null;
    await _dataSubscription?.cancel();
    _dataSubscription = null;
    await transport?.disconnect();
    _emitStatus(const ScaleStatus(state: ScaleConnectionState.disconnected));
  }

  @override
  Future<void> stop() async {
    _active = false;
    await disconnect();
    _cancelReconnect();
    if (!_weightController.isClosed) await _weightController.close();
    if (!_statusController.isClosed) await _statusController.close();
    if (!_rawController.isClosed) await _rawController.close();
  }

  @override
  Future<ScaleConnectionResult> testConnection({ScaleConfig? config}) async {
    final targetConfig = config ?? _config;
    final isSamePort = targetConfig.port == _config.port;
    final wasConnected = _status.isConnected;

    if (isSamePort && _transport != null) {
      final old = _transport!;
      _transport = null;
      await _dataSubscription?.cancel();
      _dataSubscription = null;
      await old.disconnect();
    }

    final probe = _transportFactory();
    try {
      final result = await probe.connect(targetConfig);
      await probe.disconnect();
      if (isSamePort && wasConnected && _active && !_manualDisconnect) {
        await connect();
      }
      return ScaleConnectionResult(
        success: result.success,
        error: result.error,
      );
    } on Object catch (e) {
      await probe.disconnect();
      if (isSamePort && wasConnected && _active && !_manualDisconnect) {
        await connect();
      }
      return ScaleConnectionResult(success: false, error: '$e');
    }
  }

  @override
  Future<List<String>> discoverPorts() async {
    try {
      return await _transportFactory().listAvailablePorts();
    } on Object {
      return const <String>[];
    }
  }
}
