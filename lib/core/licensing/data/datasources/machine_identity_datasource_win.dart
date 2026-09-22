import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource.dart';

class WindowsMachineIdentityDatasource extends MachineIdentityDatasource {
  static const MethodChannel _channel = MethodChannel('viyan.machine.identity');

  @override
  Future<List<String>> getIdentifiers() async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getMachineIdentifiers',
      );
      if (result == null) return [];
      final parsed = Map<String, dynamic>.from(JsonDecoder().convert(result));
      return [
        parsed['machineGuid'] as String? ?? '',
        parsed['processorId'] as String? ?? '',
        parsed['baseBoardId'] as String? ?? '',
        parsed['windowsId'] as String? ?? '',
      ];
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    }
  }
}

class StubMachineIdentityDatasource extends MachineIdentityDatasource {
  final List<String> identifiers;

  StubMachineIdentityDatasource({required this.identifiers});

  @override
  Future<List<String>> getIdentifiers() async => identifiers;
}
