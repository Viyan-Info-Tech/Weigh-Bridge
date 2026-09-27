import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/hardware/scale/data/scale_service_impl.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_models.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_service.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_status.dart';
import 'package:weighbridge/core/hardware/scale/domain/serial_transport.dart';

class _FakeTransport implements SerialTransport {
  _FakeTransport({
    this.connectResult = const SerialConnectionResult(success: true),
  });

  final SerialConnectionResult connectResult;
  Object? thrownError;

  final StreamController<List<int>> _data =
      StreamController<List<int>>.broadcast();
  int connectCalls = 0;
  int disconnectCalls = 0;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Stream<List<int>> get dataStream => _data.stream;

  @override
  Future<SerialConnectionResult> connect(ScaleConfig config) async {
    connectCalls++;
    if (thrownError != null) {
      throw thrownError!;
    }
    if (connectResult.success) _connected = true;
    return connectResult;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _connected = false;
  }

  @override
  Future<List<String>> listAvailablePorts() async => const <String>['COM9'];

  void emit(List<int> bytes) => _data.add(bytes);

  void emitLine(String line) => _data.add(line.codeUnits + const <int>[0x0A]);

  void simulateError(Object error) => _data.addError(error);
}

/// Trivially parses ASCII lines: `<weight> [S]`, where `S` marks a stable
/// reading. Used only to exercise the service pipeline.
class _NumberProtocol implements ScaleProtocol {
  @override
  String get name => 'test-number';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.unconfigured;

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    final parts = frame.asciiValue.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.length > 2) return null;
    final weight = double.tryParse(parts[0]);
    if (weight == null) return null;
    return ParsedScaleFrame(
      weightKg: weight,
      stable: parts.length > 1 && parts[1] == 'S',
    );
  }
}

void main() {
  late DateTime currentTime;
  late List<_FakeTransport> transports;
  late ScaleServiceImpl service;
  late StreamSubscription<ScaleReading> weightSub;
  final List<double> seenWeights = <double>[];

  ScaleServiceImpl buildService({
    SerialConnectionResult connectResult = const SerialConnectionResult(
      success: true,
    ),
    bool enabled = true,
  }) {
    transports = <_FakeTransport>[];
    return ScaleServiceImpl(
      transportFactory: () {
        final transport = _FakeTransport(connectResult: connectResult);
        transports.add(transport);
        return transport;
      },
      config: ScaleConfig(port: 'COM3', baudRate: 9600, enabled: enabled),
      protocol: _NumberProtocol(),
      frameTerminator: FrameTerminator.lineFeed,
      staleTimeout: const Duration(seconds: 2),
      reconnectBaseDelay: const Duration(milliseconds: 20),
      reconnectMaxDelay: const Duration(milliseconds: 200),
      now: () => currentTime,
    );
  }

  void startCollector() {
    weightSub = service.weightStream.listen((r) => seenWeights.add(r.weightKg));
  }

  Future<void> waitForWeights(
    int count, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (seenWeights.length < count && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  setUp(() {
    currentTime = DateTime(2026, 1, 1, 12, 0, 0);
    seenWeights.clear();
  });

  tearDown(() async {
    await weightSub.cancel();
    await service.stop();
  });

  group('ScaleServiceImpl', () {
    test('connects, parses a frame and emits a reading', () async {
      service = buildService();
      startCollector();
      await service.connect();
      expect(service.currentStatus.state, ScaleConnectionState.connected);

      transports.single.emitLine('1234.5 S');
      await waitForWeights(1);

      expect(seenWeights, [1234.5]);
      expect(service.currentStatus.currentWeightKg, 1234.5);
      expect(service.currentStatus.stable, isTrue);
    });

    test('rejects invalid, garbage and oversized frames', () async {
      service = buildService();
      startCollector();
      await service.connect();
      final transport = transports.single;

      transport.emitLine('abc'); // garbage
      transport.emitLine('not.a.number'); // garbage
      transport.emitLine('99999999'); // beyond max plausible
      transport.emitLine('42.5'); // first valid
      await waitForWeights(1);

      expect(seenWeights, [42.5]);
      expect(service.currentStatus.currentWeightKg, 42.5);
    });

    test('de-duplicates identical successive readings within 250ms', () async {
      service = buildService();
      startCollector();
      await service.connect();
      final transport = transports.single;

      transport.emitLine('100 S');
      transport.emitLine('100 S');
      transport.emitLine('100.1 S');
      await waitForWeights(2);

      expect(seenWeights, [100, 100.1]);
    });

    test('marks reading stale after timeout when no data arrives', () async {
      service = buildService();
      await service.connect();
      final transport = transports.single;

      final staleFrames = <ScaleStatus>[];
      final sub = service.statusStream.listen((s) {
        if (s.stale) staleFrames.add(s);
      });

      transport.emitLine('100 S');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(service.currentStatus.stale, isFalse);

      currentTime = currentTime.add(const Duration(seconds: 3));
      await Future<void>.delayed(const Duration(milliseconds: 1300));

      expect(staleFrames, isNotEmpty);
      expect(service.currentStatus.stale, isTrue);
      await sub.cancel();
    });

    test('enters reconnecting state and retries on connect failure', () async {
      service = buildService(
        connectResult: const SerialConnectionResult(
          success: false,
          error: 'port busy',
        ),
      );
      final statuses = <ScaleStatus>[];
      final sub = service.statusStream.listen(statuses.add);

      await service.connect();
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(
        statuses.any((s) => s.state == ScaleConnectionState.reconnecting),
        isTrue,
      );
      expect(service.currentStatus.reconnectAttempt, greaterThan(1));
      expect(
        transports.map((t) => t.connectCalls).reduce((a, b) => a + b),
        greaterThan(1),
      );
      await sub.cancel();
    });

    test('manual disconnect stops reconnection attempts', () async {
      service = buildService(
        connectResult: const SerialConnectionResult(
          success: false,
          error: 'no port',
        ),
      );
      await service.connect();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await service.disconnect();
      final callsAtDisconnect = transports
          .map((t) => t.connectCalls)
          .reduce((a, b) => a + b);
      expect(service.currentStatus.state, ScaleConnectionState.disconnected);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      final callsLater = transports
          .map((t) => t.connectCalls)
          .reduce((a, b) => a + b);
      expect(callsLater, callsAtDisconnect);
    });

    test('start honours the enabled flag', () async {
      service = buildService(enabled: false);
      await service.start();
      expect(service.currentStatus.state, ScaleConnectionState.disconnected);
      expect(transports, isEmpty);
    });

    test('testConnection opens a separate probe transport', () async {
      service = buildService();
      await service.connect();

      final result = await service.testConnection(
        config: const ScaleConfig(port: 'COM5', baudRate: 19200),
      );
      expect(result.success, isTrue);

      final probe = transports.last;
      expect(probe.connectCalls, 1);
      expect(probe.disconnectCalls, greaterThan(0));
      expect(service.currentStatus.state, ScaleConnectionState.connected);
    });

    test('discoverPorts lists available ports', () async {
      service = buildService();
      final ports = await service.discoverPorts();
      expect(ports, ['COM9']);
    });
  });
}
