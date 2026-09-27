import 'dart:async';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../domain/scale_models.dart';
import '../domain/serial_transport.dart';

/// [SerialTransport] backed by flutter_libserialport (libserialport).
class FlutterLibSerialPortTransport implements SerialTransport {
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<List<int>>? _subscription;
  final StreamController<List<int>> _controller =
      StreamController<List<int>>.broadcast();
  bool _connected = false;

  @override
  Stream<List<int>> get dataStream => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<SerialConnectionResult> connect(ScaleConfig config) async {
    await disconnect();

    try {
      final port = SerialPort(config.port);
      if (!port.openReadWrite()) {
        if (!port.openRead()) {
          final error =
              SerialPort.lastError?.message ?? 'Failed to open ${config.port}';
          port.dispose();
          return SerialConnectionResult(success: false, error: error);
        }
      }

      final portConfig = SerialPortConfig();
      portConfig.baudRate = config.baudRate;
      portConfig.bits = config.dataBits;
      portConfig.parity = switch (config.parity) {
        ScaleParity.none => SerialPortParity.none,
        ScaleParity.odd => SerialPortParity.odd,
        ScaleParity.even => SerialPortParity.even,
      };
      portConfig.stopBits = config.stopBits;
      portConfig.setFlowControl(SerialPortFlowControl.none);
      portConfig.dtr = SerialPortDtr.on;
      portConfig.rts = SerialPortRts.on;
      port.config = portConfig;
      port.flush();

      _port = port;
      _connected = true;

      final reader = SerialPortReader(port);
      _reader = reader;
      _subscription = reader.stream.listen(
        _controller.add,
        onError: _onReadError,
        onDone: _onReadDone,
      );
      return const SerialConnectionResult(success: true);
    } on Object catch (e) {
      await disconnect();
      return SerialConnectionResult(success: false, error: '$e');
    }
  }

  void _onReadError(Object error, StackTrace stackTrace) {
    if (!_controller.isClosed) {
      _controller.addError(SerialTransportDisconnected('$error'), stackTrace);
    }
  }

  void _onReadDone() {
    _connected = false;
    if (!_controller.isClosed) {
      _controller.addError(
        const SerialTransportDisconnected('Serial port closed'),
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    final reader = _reader;
    _reader = null;
    reader?.close();
    final port = _port;
    _port = null;
    _connected = false;
    if (port != null) {
      try {
        port.close();
      } on Object {
        // Port may already be closed by the OS.
      }
      port.dispose();
    }
    // Yield to let Windows OS kernel release the serial port COM handle
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<String>> listAvailablePorts() async {
    try {
      return SerialPort.availablePorts;
    } on Object {
      return const <String>[];
    }
  }
}
