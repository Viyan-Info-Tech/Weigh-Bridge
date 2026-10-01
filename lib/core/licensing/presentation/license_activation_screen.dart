import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_event.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';

class LicenseActivationScreen extends StatefulWidget {
  final LicenseService licenseService;
  final AuthBloc authBloc;
  final LicenseStatus? licenseStatus;
  final VoidCallback? onActivated;

  const LicenseActivationScreen({
    super.key,
    required this.licenseService,
    required this.authBloc,
    this.licenseStatus,
    this.onActivated,
  });

  @override
  State<LicenseActivationScreen> createState() =>
      _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  String _machineId = '';
  String? _licenseFileContent;
  String _statusMessage = '';
  LicenseStatus? _currentStatus;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.licenseStatus;
    _loadMachineId();
    if (_currentStatus != null) {
      _statusMessage = _messageForStatus(_currentStatus!);
    }
  }

  @override
  void didUpdateWidget(covariant LicenseActivationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.licenseStatus != widget.licenseStatus) {
      setState(() {
        _currentStatus = widget.licenseStatus;
        if (_currentStatus != null) {
          _statusMessage = _messageForStatus(_currentStatus!);
        }
      });
    }
  }

  Future<void> _loadMachineId() async {
    final hash = await widget.licenseService.getMachineHash();
    if (mounted) {
      setState(() {
        _machineId = hash;
      });
    }
  }

  Future<void> _selectLicenseFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['license', 'dat'],
    );
    if (file != null) {
      final path = file.path;
      if (path != null) {
        try {
          final content = await File(path).readAsString();
          if (mounted) {
            setState(() {
              _licenseFileContent = content;
              _statusMessage = '';
              _currentStatus = null;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Could not read the selected file.';
              _currentStatus = null;
            });
          }
        }
      }
    }
  }

  Future<void> _activate() async {
    if (_licenseFileContent == null) return;

    setState(() {
      _isActivating = true;
      _statusMessage = '';
      _currentStatus = null;
    });

    try {
      await widget.licenseService.saveLicense(_licenseFileContent!);
      final status = await widget.licenseService.validate();

      if (mounted) {
        setState(() {
          _currentStatus = status;
          _statusMessage = _messageForStatus(status);
          _isActivating = false;
        });

        if (status == LicenseStatus.valid) {
          widget.authBloc.add(const AppStarted());
          widget.onActivated?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStatus = null;
          _statusMessage = 'The license file could not be processed.';
          _isActivating = false;
        });
      }
    }
  }

  Future<void> _copyMachineId() async {
    await Clipboard.setData(ClipboardData(text: _machineId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine ID copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _messageForStatus(LicenseStatus status) {
    switch (status) {
      case LicenseStatus.valid:
        return 'License activated successfully';
      case LicenseStatus.notActivated:
        return 'This computer has not been activated.\nPlease contact ViyanInfo to obtain a license.';
      case LicenseStatus.invalidSignature:
        return 'The license file could not be verified.\nPlease obtain a valid license file from ViyanInfo.';
      case LicenseStatus.wrongMachine:
        return 'This license is registered to another computer.\nPlease contact ViyanInfo if this computer has been replaced.';
      case LicenseStatus.wrongProduct:
        return 'This license is not for this product.\nPlease contact ViyanInfo.';
      case LicenseStatus.expired:
        return 'Your ViyanInfo license has expired.\nPlease contact ViyanInfo for renewal.';
      case LicenseStatus.clockRollbackDetected:
        return 'Clock rollback detected.\nPlease contact ViyanInfo.';
      case LicenseStatus.malformedLicense:
        return 'The license file is malformed.\nPlease obtain a valid license file from ViyanInfo.';
    }
  }

  String _getDisplayId() {
    if (_machineId.length != 64) return _machineId;
    final groups = <String>[];
    for (var i = 0; i < _machineId.length; i += 4) {
      groups.add(_machineId.substring(i, i + 4));
    }
    return groups.join('-');
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact ViyanInfo',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          _buildContactRow(
            icon: Icons.phone_outlined,
            value: '+91 6379723465',
            onTap: () => _copyContactValue('+91 6379723465'),
          ),
          _buildContactRow(
            icon: Icons.email_outlined,
            value: 'viyanninfo@gmail.com',
            onTap: () => _copyContactValue('viyanninfo@gmail.com'),
          ),
          _buildContactRow(
            icon: Icons.email_outlined,
            value: 'rithiknathan@gmail.com',
            onTap: () => _copyContactValue('rithiknathan@gmail.com'),
          ),
          _buildContactRow(
            icon: Icons.language_outlined,
            value: 'www.viyaninfo.com',
            trailingIcon: Icons.open_in_new,
            onTap: _openWebsite,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.content_copy,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0F52BA)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(trailingIcon, size: 14, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyContactValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$value copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openWebsite() async {
    const url = 'www.viyaninfo.com';
    const formattedUrl = 'https://www.viyaninfo.com';
    bool launched = false;

    if (kIsWeb || !Platform.isWindows) {
      try {
        final uri = Uri.parse(formattedUrl);
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    } else {
      try {
        final result = await Process.run('rundll32', [
          'url.dll,FileProtocolHandler',
          formattedUrl,
        ]);
        launched = result.exitCode == 0;
      } catch (_) {}
    }

    if (!launched) {
      try {
        final uri = Uri.parse(formattedUrl);
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              children: [
                Expanded(flex: 58, child: _buildBrandingPanel()),
                Expanded(flex: 42, child: _buildFormPanel()),
              ],
            );
          }
          return _buildCompactPanel();
        },
      ),
    );
  }

  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F52BA), Color(0xFF0D3B82)],
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Viyan\nWeighbridge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Secure Desktop Weighbridge Management',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isSuccess = _currentStatus == LicenseStatus.valid;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Viyan Weighbridge',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F52BA),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentStatus == LicenseStatus.valid
                      ? 'License is active and verified.'
                      : 'This computer is not activated.',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildStatusBanner(),
                ],
                const SizedBox(height: 20),
                _buildContactCard(),
                const SizedBox(height: 24),
                const Text(
                  'Machine ID',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    _getDisplayId(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _machineId.isNotEmpty ? _copyMachineId : null,
                  child: const Text('Copy Machine ID'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please provide this Machine ID to ViyanInfo\nto obtain a license.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'License File',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isActivating ? null : _selectLicenseFile,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: Text(
                    _licenseFileContent != null
                        ? 'License Selected'
                        : 'Select License File',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isActivating ||
                            _licenseFileContent == null ||
                            _currentStatus == LicenseStatus.valid
                        ? null
                        : _activate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B82),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isActivating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentStatus == LicenseStatus.valid
                                ? 'Activated'
                                : 'Activate',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPanel() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Viyan Weighbridge',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F52BA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentStatus == LicenseStatus.valid
                          ? 'License is active and verified.'
                          : 'This computer is not activated.',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (_statusMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildStatusBanner(),
                    ],
                    const SizedBox(height: 20),
                    _buildContactCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Machine ID'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Text(
                        _getDisplayId(),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _machineId.isNotEmpty ? _copyMachineId : null,
                      child: const Text('Copy Machine ID'),
                    ),
                    const Text(
                      'Please provide this Machine ID to ViyanInfo\nto obtain a license.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('License File'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _isActivating ? null : _selectLicenseFile,
                      icon: const Icon(Icons.folder_open_rounded),
                      label: Text(
                        _licenseFileContent != null
                            ? 'License Selected'
                            : 'Select License File',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isActivating ||
                                _licenseFileContent == null ||
                                _currentStatus == LicenseStatus.valid
                            ? null
                            : _activate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B82),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isActivating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _currentStatus == LicenseStatus.valid
                                    ? 'Activated'
                                    : 'Activate',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }
}
