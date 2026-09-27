import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/hardware/scale/domain/scale_service.dart';
import '../../data/datasources/serial_weight_data_source.dart';

class SerialWeightTestPage extends StatefulWidget {
  const SerialWeightTestPage({super.key});

  @override
  State<SerialWeightTestPage> createState() => _SerialWeightTestPageState();
}

class _SerialWeightTestPageState extends State<SerialWeightTestPage> {
  final SerialWeightDataSource _dataSource = SerialWeightDataSource();

  StreamSubscription<double>? _weightSubscription;
  StreamSubscription<String>? _frameSubscription;

  double? _weight;
  String _latestFrame = '';
  String _status = 'Disconnected';
  bool _isConnecting = false;
  int _receivedFrameCount = 0;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _status = 'Releasing background port & connecting to COM3...';
    });

    try {
      // Disconnect background ScaleService if active to avoid port conflict
      try {
        final scaleService = context.read<ScaleService>();
        await scaleService.disconnect();
      } catch (_) {}

      await _dataSource.connect(portName: 'COM3');

      _weightSubscription?.cancel();
      _frameSubscription?.cancel();

      _weightSubscription = _dataSource.weightStream.listen((weight) {
        if (!mounted) return;
        setState(() {
          _weight = weight;
          _status = 'Connected (Receiving Live Frames)';
        });
      });

      _frameSubscription = _dataSource.rawFrameStream.listen((frame) {
        if (!mounted) return;
        setState(() {
          _latestFrame = frame;
          _receivedFrameCount++;
        });
      });

      if (mounted) {
        setState(() {
          _isConnecting = false;
          _status = 'Connected - waiting for weight frames from COM3';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _status = 'Connection failed: $e';
      });
    }
  }

  Future<void> _disconnect() async {
    await _weightSubscription?.cancel();
    _weightSubscription = null;
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    await _dataSource.disconnect();

    if (mounted) {
      setState(() {
        _status = 'Disconnected';
      });
    }
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    _frameSubscription?.cancel();
    _dataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status.startsWith('Connected');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'COM3 Serial Protocol Hardware Test',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/bill'),
            icon: const Icon(
              Icons.arrow_forward,
              color: Color(0xFF38BDF8),
              size: 18,
            ),
            label: const Text(
              'Go to Weighbridge Bill App',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Protocol Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBadge('Port', 'COM3'),
                      _buildInfoBadge('Baud', '2400'),
                      _buildInfoBadge('Data', '8N1'),
                      _buildInfoBadge('Framing', 'STX / ETX'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main Weight Display Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isConnected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF475569),
                      width: 2,
                    ),
                    boxShadow: [
                      if (isConnected)
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Status Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _status,
                            style: TextStyle(
                              color: isConnected
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFCA5A5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Live Weight Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _weight != null
                                ? _weight!.toStringAsFixed(0)
                                : '--',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: _weight != null
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'kg',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Raw Frame payload inspector
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Raw Frame (between STX & ETX): ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _latestFrame.isNotEmpty
                                  ? '"$_latestFrame"'
                                  : 'None received yet',
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                color: Color(0xFFF59E0B),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Frames: $_receivedFrameCount',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isConnecting ? null : _connect,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Connect / Reconnect COM3'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _disconnect,
                      icon: const Icon(Icons.stop),
                      label: const Text('Disconnect Port'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCBD5E1),
                        side: const BorderSide(color: Color(0xFF475569)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
