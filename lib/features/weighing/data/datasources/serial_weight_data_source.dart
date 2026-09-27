import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialWeightDataSource {
  static const int baudRate = 2400;

  SerialPort? _port;
  SerialPortReader? _reader;

  StreamSubscription<Uint8List>? _subscription;

  final StreamController<double> _weightController =
      StreamController<double>.broadcast();
  final StreamController<String> _rawFrameController =
      StreamController<String>.broadcast();

  Stream<double> get weightStream => _weightController.stream;
  Stream<String> get rawFrameStream => _rawFrameController.stream;

  String _buffer = '';

  Future<void> connect({required String portName}) async {
    await disconnect();

    final port = SerialPort(portName);

    final config = SerialPortConfig()
      ..baudRate = baudRate
      ..bits = 8
      ..parity = 0
      ..stopBits = 1
      ..rts = 0
      ..cts = 0
      ..dtr = 0
      ..dsr = 0;

    port.config = config;

    if (!port.openRead()) {
      final error = SerialPort.lastError?.message ?? 'Unknown error';
      port.dispose();
      throw Exception('Failed to open $portName: $error');
    }

    _port = port;

    _reader = SerialPortReader(port);

    _subscription = _reader!.stream.listen(
      _onData,
      onError: (Object error, StackTrace stackTrace) {
        // Handle serial errors
      },
    );
  }

  void _onData(Uint8List data) {
    final text = ascii.decode(data, allowInvalid: true);

    _buffer += text;

    _processBuffer();
  }

  void _processBuffer() {
    while (true) {
      final startIndex = _buffer.indexOf('\x02');

      if (startIndex == -1) {
        // No complete frame start yet.
        _buffer = '';
        return;
      }

      final endIndex = _buffer.indexOf('\x03', startIndex + 1);

      if (endIndex == -1) {
        // Wait for more serial data.
        if (startIndex > 0) {
          _buffer = _buffer.substring(startIndex);
        }
        return;
      }

      final frame = _buffer.substring(startIndex + 1, endIndex);

      _buffer = _buffer.substring(endIndex + 1);

      if (!_rawFrameController.isClosed) {
        _rawFrameController.add(frame);
      }
      _parseWeight(frame);
    }
  }

  void _parseWeight(String frame) {
    final value = frame.trim();

    final weight = double.tryParse(value);

    if (weight == null) {
      return;
    }

    if (!_weightController.isClosed) {
      _weightController.add(weight);
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;

    _reader = null;

    if (_port != null) {
      try {
        _port!.close();
        _port!.dispose();
      } catch (_) {}
    }

    _port = null;
    _buffer = '';
  }

  Future<void> dispose() async {
    await disconnect();
    await _weightController.close();
    await _rawFrameController.close();
  }
}
