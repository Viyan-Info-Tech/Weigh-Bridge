import 'scale_models.dart';
import 'scale_status.dart';

/// A single validated reading from the weigh indicator.
class ScaleReading {
  final double weightKg;
  final bool stable;
  final bool isMotion;
  final bool isOverload;
  final DateTime receivedAt;

  const ScaleReading({
    required this.weightKg,
    this.stable = false,
    this.isMotion = false,
    this.isOverload = false,
    required this.receivedAt,
  });
}

/// Outcome of a one-off connection test (`Test Connection` in settings).
class ScaleConnectionResult {
  const ScaleConnectionResult({required this.success, this.error});

  final bool success;
  final String? error;
}

/// The façade the rest of the app talks to. Concrete connection logic lives
/// behind [SerialTransport] and frame interpretation behind [ScaleProtocol];
/// this service owns lifecycle, reconnection, staleness and validation.
abstract interface class ScaleService {
  /// Validated, de-duplicated readings. Bill screen subscribes here.
  Stream<ScaleReading> get weightStream;

  /// Connection state + last reading snapshot. Diagnostics UI subscribes here.
  Stream<ScaleStatus> get statusStream;

  /// Every raw chunk received from the port (pre-parsing), for diagnostics.
  Stream<List<int>> get rawBytesStream;

  ScaleStatus get currentStatus;

  ScaleConfig get config;

  /// Starts the service: auto-connects when the persisted config is enabled.
  Future<void> start();

  /// Connects (or re-connects) using [config] if provided.
  Future<void> connect({ScaleConfig? config});

  /// Manually disconnects. Disables automatic reconnection until
  /// [connect] or [start] is invoked again.
  Future<void> disconnect();

  /// Tears the service down (app shutdown): closes port, timers and streams.
  Future<void> stop();

  /// Tries opening the port without entering the reconnect loop.
  Future<ScaleConnectionResult> testConnection({ScaleConfig? config});

  /// Ports currently visible to the OS, for the settings diagnostics panel.
  Future<List<String>> discoverPorts();
}
