import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_event.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';

class LicenseActivationScreen extends StatefulWidget {
  final LicenseService licenseService;
  final AuthBloc authBloc;
  final LicenseStatus? licenseStatus;

  const LicenseActivationScreen({
    super.key,
    required this.licenseService,
    required this.authBloc,
    this.licenseStatus,
  });

  @override
  State<LicenseActivationScreen> createState() =>
      _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  String _machineId = '';
  String? _licenseFileContent;
  String _statusMessage = '';
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _loadMachineId();
    if (widget.licenseStatus != null) {
      _statusMessage = _messageForStatus(widget.licenseStatus!);
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
      allowedExtensions: ['dat'],
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
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Could not read the selected file.';
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
    });

    try {
      await widget.licenseService.saveLicense(_licenseFileContent!);
      final status = await widget.licenseService.validate();

      if (mounted) {
        setState(() {
          _statusMessage = _messageForStatus(status);
          _isActivating = false;
        });

        if (status == LicenseStatus.valid) {
          widget.authBloc.add(const AppStarted());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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
        return 'This computer has not been activated.\nPlease contact ViyanInfo.';
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
                  'This computer is not activated.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.licenseStatus == LicenseStatus.valid
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.licenseStatus == LicenseStatus.valid
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
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
                    onPressed: _isActivating || _licenseFileContent == null
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
                        : const Text('Activate'),
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
                      'This computer is not activated.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (_statusMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: _isActivating || _licenseFileContent == null
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
                            : const Text('Activate'),
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
