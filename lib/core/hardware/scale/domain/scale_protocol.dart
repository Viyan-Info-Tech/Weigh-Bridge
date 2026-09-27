import 'dart:typed_data';

import 'scale_models.dart';

/// A chunk of raw bytes that constitutes one complete unit of indicator
/// output, as sliced out of the incoming stream by [FrameDecoder].
class ScaleFrame {
  ScaleFrame(List<int> bytes, {required this.receivedAt})
    : bytes = Uint8List.fromList(bytes);

  final Uint8List bytes;
  final DateTime receivedAt;

  String get asciiValue => String.fromCharCodes(bytes).trim();
}

/// The outcome of interpreting one [ScaleFrame] with a [ScaleProtocol].
///
/// Because the concrete protocol family is not yet known, the parser is a
/// replaceable strategy. A frame is only accepted when [isValid] is true.
class ParsedScaleFrame {
  final double? weightKg;
  final bool stable;
  final bool isMotion;
  final bool isOverload;

  const ParsedScaleFrame({
    this.weightKg,
    this.stable = false,
    this.isMotion = false,
    this.isOverload = false,
  });

  /// Rejects garbage and non-finite weights before they
  /// ever reach the bill screen. Accepts finite numbers including negative indicator readings.
  bool get isValid => weightKg != null && weightKg!.isFinite && !isOverload;
}

/// Decodes a single raw [ScaleFrame] into a validated [ParsedScaleFrame].
///
/// Implementations are added once the weigh indicator model and its output
/// format are confirmed. Nothing in the scaffold assumes a particular format.
abstract interface class ScaleProtocol {
  String get name;

  ScaleProtocolType get protocolType;

  /// Returns `null` when the frame cannot be understood.
  ParsedScaleFrame? parse(ScaleFrame frame);
}

/// How incoming bytes are sliced into complete [ScaleFrame]s.
enum FrameTerminator {
  /// Automatically slices by CRLF, LF, CR, or STX/ETX.
  auto,

  /// Frames are terminated by a single line feed (`\n`).
  lineFeed,

  /// Frames are terminated by a single carriage return (`\r`).
  carriageReturn,

  /// Frames are delimited by STX/ETX control characters.
  stxEtx,

  /// No slicing; every chunk delivered by the transport is one frame.
  none,
}

/// Splits a raw byte stream into frames using a generic framing rule.
///
/// Framing is kept intentionally simple and configurable; it does not imply
/// any concrete indicator protocol. It also guards against an indicator that
/// never sends its terminator by bounding the internal buffer.
class FrameDecoder {
  FrameDecoder({this.terminator = FrameTerminator.auto});

  final FrameTerminator terminator;
  final List<int> _buffer = <int>[];

  static const int maxBufferLength = 8192;

  /// Feeds an incoming chunk and returns any complete frames it contains.
  List<ScaleFrame> feed(List<int> chunk, DateTime receivedAt) {
    final frames = <ScaleFrame>[];
    if (chunk.isEmpty) return frames;

    _buffer.addAll(chunk);
    switch (terminator) {
      case FrameTerminator.none:
        if (_buffer.isNotEmpty) {
          frames.add(ScaleFrame(List.of(_buffer), receivedAt: receivedAt));
          _buffer.clear();
        }
      case FrameTerminator.auto:
        _sliceAuto(receivedAt, frames);
      case FrameTerminator.lineFeed:
        _sliceByLine(receivedAt, frames);
      case FrameTerminator.carriageReturn:
        _sliceByCr(receivedAt, frames);
      case FrameTerminator.stxEtx:
        _sliceByStxEtx(receivedAt, frames);
    }
    return frames;
  }

  void _sliceAuto(DateTime receivedAt, List<ScaleFrame> frames) {
    var start = 0;
    for (var i = 0; i < _buffer.length; i++) {
      final b = _buffer[i];
      if (b == 0x03) {
        // ETX
        final stxIndex = _buffer.sublist(start, i).lastIndexOf(0x02);
        final frameStart = stxIndex >= 0 ? start + stxIndex + 1 : start;
        if (i > frameStart) {
          frames.add(
            ScaleFrame(_buffer.sublist(frameStart, i), receivedAt: receivedAt),
          );
        }
        start = i + 1;
      } else if (b == 0x0A || b == 0x0D) {
        // LF or CR
        if (i > start) {
          var s = start;
          while (s < i &&
              (_buffer[s] == 0x02 ||
                  _buffer[s] == 0x0A ||
                  _buffer[s] == 0x0D)) {
            s++;
          }
          if (i > s) {
            frames.add(
              ScaleFrame(_buffer.sublist(s, i), receivedAt: receivedAt),
            );
          }
        }
        start = i + 1;
      }
    }
    _trimBuffer(start);
  }

  void _sliceByLine(DateTime receivedAt, List<ScaleFrame> frames) {
    var start = 0;
    for (var i = 0; i < _buffer.length; i++) {
      if (_buffer[i] == 0x0A) {
        if (i > start) {
          frames.add(
            ScaleFrame(_buffer.sublist(start, i), receivedAt: receivedAt),
          );
        }
        start = i + 1;
      }
    }
    _trimBuffer(start);
  }

  void _sliceByCr(DateTime receivedAt, List<ScaleFrame> frames) {
    var start = 0;
    for (var i = 0; i < _buffer.length; i++) {
      if (_buffer[i] == 0x0D) {
        if (i > start) {
          frames.add(
            ScaleFrame(_buffer.sublist(start, i), receivedAt: receivedAt),
          );
        }
        start = i + 1;
      }
    }
    _trimBuffer(start);
  }

  void _sliceByStxEtx(DateTime receivedAt, List<ScaleFrame> frames) {
    var start = 0;
    while (start < _buffer.length) {
      if (_buffer[start] != 0x02) {
        start++;
        continue;
      }
      final end = _indexOf(_buffer, 0x03, start + 1);
      if (end < 0) break;
      if (end > start + 1) {
        frames.add(
          ScaleFrame(_buffer.sublist(start + 1, end), receivedAt: receivedAt),
        );
      }
      start = end + 1;
    }
    _trimBuffer(start);
  }

  void _trimBuffer(int start) {
    if (start >= _buffer.length) {
      _buffer.clear();
    } else if (_buffer.length - start > maxBufferLength) {
      _buffer.removeRange(0, start);
      _buffer.removeRange(0, _buffer.length - maxBufferLength);
    } else {
      _buffer.removeRange(0, start);
    }
  }

  int _indexOf(List<int> data, int value, int fromIndex) {
    for (var i = fromIndex; i < data.length; i++) {
      if (data[i] == value) return i;
    }
    return -1;
  }

  void clear() {
    _buffer.clear();
  }
}
