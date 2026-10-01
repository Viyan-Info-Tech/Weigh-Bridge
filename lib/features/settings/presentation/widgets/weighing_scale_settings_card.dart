import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/scale_settings_dao.dart';
import '../../../../core/hardware/scale/data/scale_config_adapter.dart';
import '../../../../core/hardware/scale/domain/scale_models.dart';
import '../../../../core/hardware/scale/domain/scale_service.dart';
import '../../../../core/hardware/scale/domain/scale_status.dart';
import 'live_scale_console.dart';
import 'settings_form_field.dart';

/// Industrial-grade card for configuring and diagnosing the weigh scale
/// connection. Talks directly to [ScaleSettingsDao] and [ScaleService].
class WeighingScaleSettingsCard extends StatefulWidget {
  const WeighingScaleSettingsCard({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<WeighingScaleSettingsCard> createState() =>
      _WeighingScaleSettingsCardState();
}

class _WeighingScaleSettingsCardState extends State<WeighingScaleSettingsCard> {
  final TextEditingController _portController = TextEditingController();

  int _baudRate = 2400;
  int _dataBits = 8;
  int _parityIndex = 0; // 0 = None (Standard), 1 = Odd, 2 = Even
  int _stopBits = 1;
  ScaleProtocolType _protocolType = ScaleProtocolType.universal;
  bool _enabled = true;

  bool _loading = true;
  bool _saving = false;
  bool _testing = false;
  bool _isScanningPorts = false;

  ScaleService? _scale;
  ScaleSettingsDao? _dao;
  StreamSubscription<ScaleStatus>? _statusSubscription;
  StreamSubscription<List<int>>? _rawBytesSubscription;
  ScaleStatus _status = const ScaleStatus();
  bool _subscribed = false;

  String _latestRawAscii = '';
  String _latestRawHex = '';
  int _receivedPackets = 0;
  final List<int> _rawBuffer = <int>[];

  List<String> _availablePorts = <String>[];
  bool? _testOk;
  String? _testResult;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    try {
      _scale = context.read<ScaleService>();
    } catch (_) {
      _scale = null;
    }
    try {
      final database = context.read<AppDatabase>();
      _dao = ScaleSettingsDao(database);
    } catch (_) {
      _dao = null;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final row = await _dao?.getSettings();
      final config = row == null ? null : ScaleConfigAdapter.fromRow(row);
      if (config != null) {
        _portController.text = config.port;
        _baudRate = config.baudRate;
        _dataBits = config.dataBits;
        _parityIndex = _parityToIndex(config.parity);
        _stopBits = config.stopBits;
        _protocolType = config.protocol == ScaleProtocolType.unconfigured
            ? ScaleProtocolType.universal
            : config.protocol;
        _enabled = config.enabled;
      }
    } on Object {
      // Fall back to defaults if table is unavailable
    }

    final scale = _scale;
    if (scale != null && !_subscribed) {
      _subscribed = true;
      _statusSubscription = scale.statusStream.listen((status) {
        if (mounted) setState(() => _status = status);
      });
      _rawBytesSubscription = scale.rawBytesStream.listen((bytes) {
        if (!mounted || bytes.isEmpty) return;
        _receivedPackets++;
        _rawBuffer.addAll(bytes);
        if (_rawBuffer.length > 32) {
          _rawBuffer.removeRange(0, _rawBuffer.length - 32);
        }
        final hex = _rawBuffer
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(' ');
        final ascii = _rawBuffer.map((b) {
          if (b == 0x02) return '<STX>';
          if (b == 0x03) return '<ETX>';
          if (b == 0x0D) return '<CR>';
          if (b == 0x0A) return '<LF>';
          if (b >= 32 && b <= 126) return String.fromCharCode(b);
          return '.';
        }).join();
        setState(() {
          _latestRawHex = hex;
          _latestRawAscii = ascii;
        });
      });
      _status = scale.currentStatus;
    }

    unawaited(_discoverPorts());
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _discoverPorts() async {
    if (_isScanningPorts) return;
    setState(() => _isScanningPorts = true);
    try {
      final ports = await _scale?.discoverPorts() ?? const <String>[];
      if (mounted) {
        setState(() {
          _availablePorts = ports;
          _isScanningPorts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isScanningPorts = false);
    }
  }

  @override
  void dispose() {
    _portController.dispose();
    unawaited(_statusSubscription?.cancel());
    unawaited(_rawBytesSubscription?.cancel());
    super.dispose();
  }

  ScaleConfig get _config => ScaleConfig(
    port: _portController.text.trim().isEmpty
        ? 'COM3'
        : _portController.text.trim(),
    baudRate: _baudRate,
    dataBits: _dataBits,
    parity: _parityFromIndex(_parityIndex),
    stopBits: _stopBits,
    protocol: _protocolType,
    enabled: _enabled,
  );

  Future<void> _saveAndConnect() async {
    final dao = _dao;
    setState(() {
      _saving = true;
      _message = null;
      _messageIsError = false;
    });
    try {
      await dao?.updateSettings(ScaleConfigAdapter.toCompanion(_config));
      final scale = _scale;
      if (scale != null) {
        await scale.connect(config: _config);
      }
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Scale settings saved and connection initiated.';
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = '$e';
        _messageIsError = true;
      });
    }
  }

  Future<void> _testConnection() async {
    final scale = _scale;
    setState(() {
      _testing = true;
      _testResult = null;
      _testOk = null;
    });
    final result = await scale?.testConnection(config: _config);
    if (!mounted) return;
    setState(() {
      _testing = false;
      if (result != null) {
        _testOk = result.success;
        _testResult =
            result.error ??
            (result.success
                ? 'Port ${_config.port} opened successfully. Serial carrier active.'
                : 'Connection failed on port ${_config.port}.');
      } else {
        _testOk = false;
        _testResult = 'Scale service is not available.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.precision_manufacturing_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF0D3B82),
      title: 'Weighing Scale Interface',
      subtitle:
          'Serial RS-232 / USB connection parameters & live indicator telemetry',
      child: _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D3B82)),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Live Industrial Scale Console ──
                LiveScaleConsole(
                  status: _status,
                  port: _portController.text.trim().isEmpty
                      ? 'COM3'
                      : _portController.text.trim(),
                  baudRate: _baudRate,
                  dataBits: _dataBits,
                  parity: _parityFromIndex(_parityIndex),
                  stopBits: _stopBits,
                  protocolLabel: _protocolType.label,
                  latestRawAscii: _latestRawAscii,
                  latestRawHex: _latestRawHex,
                  receivedPackets: _receivedPackets,
                ),

                const SizedBox(height: 18),

                // ── Hardware Interface Enable Toggle Card ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _enabled
                        ? const Color(0xFF0D3B82).withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _enabled
                          ? const Color(0xFF0D3B82).withValues(alpha: 0.3)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _enabled
                              ? const Color(0xFF0D3B82)
                              : const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.sensors_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weighbridge Serial Interface',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _enabled
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _enabled
                                  ? 'Active - live weight readings will be captured into bill tickets'
                                  : 'Disabled - scale polling is halted, manual entry only',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: !widget.isEditing
                            ? null
                            : (v) => setState(() => _enabled = v),
                        activeThumbColor: const Color(0xFF0D3B82),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return _enabled
                                ? const Color(0xFF0D3B82)
                                : const Color(0xFF94A3B8);
                          }
                          return null;
                        }),
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return _enabled
                                ? const Color(
                                    0xFF0D3B82,
                                  ).withValues(alpha: 0.35)
                                : const Color(0xFFCBD5E1);
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Port Configuration Section ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.usb_rounded,
                          size: 15,
                          color: Color(0xFF0D3B82),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Serial Port (COM / USB)',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _isScanningPorts ? null : _discoverPorts,
                      icon: _isScanningPorts
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0D3B82),
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 14),
                      label: Text(
                        _isScanningPorts ? 'Scanning...' : 'Scan Ports',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0D3B82),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Port Input field
                SettingsFormTextField(
                  label: '',
                  hint: 'e.g. COM3 or /dev/ttyUSB0',
                  controller: _portController,
                  enabled: widget.isEditing,
                  isEditing: widget.isEditing,
                  onChanged: (_) => setState(() {}),
                ),

                // Discovered ports quick-select chips
                if (_availablePorts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Detected on system:',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      for (final port in _availablePorts) ...[
                        _PortChip(
                          port: port,
                          isSelected:
                              _portController.text.trim().toUpperCase() ==
                              port.toUpperCase(),
                          isEnabled: widget.isEditing,
                          onSelected: () {
                            setState(() {
                              _portController.text = port;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(
                    'No active serial ports detected. Connect your USB-RS232 adapter and click "Scan Ports".',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // ── Serial Protocol Parameters Grid ──
                const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: Color(0xFF0D3B82),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Serial Protocol Parameters',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 580;

                    final baudField = _SelectField<int>(
                      label: 'Baud Rate',
                      value: _baudRate,
                      enabled: widget.isEditing,
                      items: const [
                        (2400, '2400 bps'),
                        (4800, '4800 bps'),
                        (9600, '9600 bps (Standard)'),
                        (19200, '19200 bps'),
                        (38400, '38400 bps'),
                        (57600, '57600 bps'),
                        (115200, '115200 bps'),
                      ],
                      onChanged: (v) =>
                          setState(() => _baudRate = v ?? _baudRate),
                    );

                    final dataBitsField = _SelectField<int>(
                      label: 'Data Bits',
                      value: _dataBits,
                      enabled: widget.isEditing,
                      items: const [(8, '8 bits (Standard)'), (7, '7 bits')],
                      onChanged: (v) =>
                          setState(() => _dataBits = v ?? _dataBits),
                    );

                    final parityField = _SelectField<int>(
                      label: 'Parity',
                      value: _parityIndex,
                      enabled: widget.isEditing,
                      items: const [
                        (0, 'None (Standard)'),
                        (1, 'Odd'),
                        (2, 'Even'),
                      ],
                      onChanged: (v) =>
                          setState(() => _parityIndex = v ?? _parityIndex),
                    );

                    final stopBitsField = _SelectField<int>(
                      label: 'Stop Bits',
                      value: _stopBits,
                      enabled: widget.isEditing,
                      items: const [(1, '1 bit (Standard)'), (2, '2 bits')],
                      onChanged: (v) =>
                          setState(() => _stopBits = v ?? _stopBits),
                    );

                    final protocolField = _SelectField<ScaleProtocolType>(
                      label: 'Scale Indicator Protocol',
                      value: _protocolType,
                      enabled: widget.isEditing,
                      items: const [
                        (
                          ScaleProtocolType.universal,
                          'Auto-Detect / Universal (Recommended)',
                        ),
                        (
                          ScaleProtocolType.asciiContinuous,
                          'Continuous ASCII Stream',
                        ),
                        (ScaleProtocolType.yaohua, 'Yaohua XK3190 / D2008'),
                        (ScaleProtocolType.toledo, 'Mettler Toledo Continuous'),
                        (ScaleProtocolType.avery, 'Avery Weigh-Tronix'),
                        (ScaleProtocolType.cardinal, 'Cardinal / Detecto'),
                      ],
                      onChanged: (v) =>
                          setState(() => _protocolType = v ?? _protocolType),
                    );

                    if (isWide) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: baudField),
                              const SizedBox(width: 12),
                              Expanded(child: dataBitsField),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: parityField),
                              const SizedBox(width: 12),
                              Expanded(child: stopBitsField),
                            ],
                          ),
                          const SizedBox(height: 12),
                          protocolField,
                        ],
                      );
                    }

                    return Column(
                      children: [
                        baudField,
                        const SizedBox(height: 12),
                        dataBitsField,
                        const SizedBox(height: 12),
                        parityField,
                        const SizedBox(height: 12),
                        stopBitsField,
                        const SizedBox(height: 12),
                        protocolField,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── Action Buttons ──
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _saving || _testing ? null : _saveAndConnect,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save & Connect'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        elevation: 0,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving || _testing ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0D3B82),
                                ),
                              ),
                            )
                          : const Icon(Icons.network_check_rounded, size: 18),
                      label: const Text('Test Connection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D3B82),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Diagnostic / Test Results Alert ──
                if (_testResult != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testOk == true
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _testOk == true
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _testOk == true
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          size: 18,
                          color: _testOk == true
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _testOk == true
                                    ? 'Connection Test Successful'
                                    : 'Connection Test Failed',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _testOk == true
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _testResult!,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: _testOk == true
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Save Feedback Alert ──
                if (_message != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _messageIsError
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _messageIsError
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _messageIsError
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 16,
                          color: _messageIsError
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _messageIsError
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                // ── Hardware Integration Callout ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.developer_board_rounded,
                        size: 18,
                        color: Color(0xFF0D3B82),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Continuous Stream Protocol Support',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Supports standard continuous ASCII stream formats from Avery Weigh-Tronix, Cardinal, Toledo, Eagle, Sansui, and universal weighbridge indicators.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                height: 1.4,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static int _parityToIndex(ScaleParity parity) => switch (parity) {
    ScaleParity.none => 0,
    ScaleParity.odd => 1,
    ScaleParity.even => 2,
  };

  static ScaleParity _parityFromIndex(int index) => switch (index) {
    1 => ScaleParity.odd,
    2 => ScaleParity.even,
    _ => ScaleParity.none,
  };
}

class _PortChip extends StatelessWidget {
  const _PortChip({
    required this.port,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
  });

  final String port;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onSelected : null,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D3B82)
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              port,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          softWrap: true,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF8FAFC)
                : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B82),
                width: 1.5,
              ),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item.$1,
                  child: Text(item.$2, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
