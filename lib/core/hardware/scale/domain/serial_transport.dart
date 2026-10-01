import 'scale_models.dart';

/// Outcome of a transport-level open attempt.
class SerialConnectionResult {
  const SerialConnectionResult({required this.success, this.error});

  final bool success;
  final String? error;
}

/// Thrown/lost stream event when the serial port closes unexpectedly or the
/// underlying native layer reports an error. Emitted as an error event on
/// [SerialTransport.dataStream] so the service can tear down and reconnect.
class SerialTransportDisconnected implements Exception {
  const SerialTransportDisconnected(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Abstracts the serial I/O from the service layer behind a tiny interface so
/// the scale service can be unit-tested without a real COM port, and so the
/// backend (flutter_libserialport today) can be swapped later.
abstract interface class SerialTransport {
  /// Opens the port described by [config] and starts forwarding bytes to
  /// [dataStream]. Returns the outcome of the open attempt.
  Future<SerialConnectionResult> connect(ScaleConfig config);

  /// Bytes read from the port. May emit a [SerialTransportDisconnected]
  /// error before [isConnected] becomes false.
  Stream<List<int>> get dataStream;

  /// Stops the reader and closes the port. Safe to call when already closed.
  Future<void> disconnect();

  bool get isConnected;

  /// Lists ports available on this machine for the settings diagnostics panel.
  Future<List<String>> listAvailablePorts();
}
