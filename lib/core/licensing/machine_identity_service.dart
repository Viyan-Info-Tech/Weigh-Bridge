import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource.dart';

class MachineIdentityService {
  final MachineIdentityDatasource _datasource;

  MachineIdentityService(this._datasource);

  Future<String> getMachineHash() async {
    final rawIdentifiers = await _datasource.getIdentifiers();
    final normalized = rawIdentifiers
        .map((id) => _normalize(id))
        .where((id) => id.isNotEmpty)
        .toList();
    if (normalized.isEmpty) {
      final platformId = _getPlatformFallback();
      normalized.add(platformId);
    }
    final combined = normalized.join('|');
    final bytes = Uint8List.fromList(utf8.encode(combined));
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _normalize(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _getPlatformFallback() {
    return 'fallback-${DateTime.now().millisecondsSinceEpoch}';
  }
}
