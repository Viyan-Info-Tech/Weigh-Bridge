import 'dart:async';

import '../domain/scale_models.dart';
import '../domain/scale_service.dart';
import '../domain/scale_status.dart';

/// Simulated [ScaleService] for development/debugging and for running the app
/// on machines without a weigh indicator.
///
/// Activated with the `USE_FAKE_SCALE` build flag. Its [weightStream] and
/// [statusStream] can be driven from test code.
class FakeScaleService implements ScaleService {
  FakeScaleService({ScaleConfig? config}) : _config = config ?? const ScaleConfig();

  ScaleConfig _config;
  ScaleStatus _status = const ScaleStatus();

  final StreamController<ScaleReading> _weightController =
      StreamController<ScaleReading>.broadcast();
  final StreamController<ScaleStatus> _statusController =
      StreamController<ScaleStatus>.broadcast();
  final StreamController<List<int>> _rawController =
      StreamController<List<int>>.broadcast();

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
    await connect();
  }

  @override
  Future<void> connect({ScaleConfig? config}) async {
    if (config != null) _config = config;
    _emit(const ScaleStatus(
      state: ScaleConnectionState.connecting,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _emit(const ScaleStatus(state: ScaleConnectionState.connected));
  }

  @override
  Future<void> disconnect() async {
    _emit(const ScaleStatus(state: ScaleConnectionState.disconnected));
  }

  @override
  Future<void> stop() async {
    await disconnect();
    await _weightController.close();
    await _statusController.close();
    await _rawController.close();
  }

  @override
  Future<ScaleConnectionResult> testConnection({ScaleConfig? config}) async {
    final result = const ScaleConnectionResult(success: true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return result;
  }

  @override
  Future<List<String>> discoverPorts() async {
    return const <String>['COM3', 'COM4', 'COM5'];
  }

  /// Test/manual hook: publish a simulated reading.
  void simulateReading(double weightKg, {bool stable = true}) {
    final receivedAt = DateTime.now();
    final reading = ScaleReading(
      weightKg: weightKg,
      stable: stable,
      isMotion: !stable,
      receivedAt: receivedAt,
    );
    _weightController.add(reading);
    _emit(ScaleStatus(
      state: ScaleConnectionState.connected,
      currentWeightKg: weightKg,
      stable: stable,
      isMotion: !stable,
      lastReceivedAt: receivedAt,
    ));
  }

  /// Test/manual hook: simulate the port dropping.
  void simulateDisconnect({String? reason}) {
    _emit(ScaleStatus(
      state: ScaleConnectionState.disconnected,
      error: reason ?? 'Simulated disconnect',
    ));
  }

  /// Test/manual hook: forward raw bytes to the diagnostics stream.
  void simulateRawBytes(List<int> bytes) {
    _rawController.add(bytes);
  }

  void _emit(ScaleStatus status) {
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}