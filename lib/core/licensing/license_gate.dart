import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weighbridge/app/di/injection.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/presentation/license_activation_screen.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';
import 'package:weighbridge/app/app.dart';

class LicenseGate extends StatefulWidget {
  final Injection injection;
  final LicenseService licenseService;

  const LicenseGate({
    super.key,
    required this.injection,
    required this.licenseService,
  });

  @override
  State<LicenseGate> createState() => _LicenseGateState();
}

class _LicenseGateState extends State<LicenseGate> {
  LicenseStatus _licenseStatus = LicenseStatus.notActivated;
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _validateLicense();
    _authSubscription = widget.injection.authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        _validateLicense();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _validateLicense() async {
    final status = await widget.licenseService.validate();
    if (mounted) {
      setState(() {
        _licenseStatus = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_licenseStatus == LicenseStatus.valid) {
      return WeighbridgeApp(injection: widget.injection);
    }

    return LicenseActivationScreen(
      licenseService: widget.licenseService,
      authBloc: widget.injection.authBloc,
      licenseStatus: _licenseStatus,
    );
  }
}
