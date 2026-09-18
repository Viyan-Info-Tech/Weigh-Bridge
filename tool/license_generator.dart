// ViyanInfo offline license signing tool.
//
// This tool runs on ViyanInfo's issuing machine ONLY. It holds the Ed25519
// private key and produces signed .dat license files that the Weighbridge
// client verifies with the embedded public key (lib/core/licensing/data/
// constants/keys.dart). The private key must NEVER be placed inside the
// application repository.
//
// Usage:
//   dart run tool/license_generator.dart generate-keypair
//   dart run tool/license_generator.dart issue \
//       --private-key <64-byte-hex> \
//       --machine-hash <sha256-hex> \
//       [--customer-id <id>] [--customer-name "Name"] \
//       [--license-type annual] [--months 12 | --expiry 2027-09-18] \
//       [--product VIYAN-WEIGHBRIDGE] [--output license.dat]
//   dart run tool/license_generator.dart verify \
//       --license-file license.dat --public-key <32-byte-hex>

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';

const String _kDefaultProduct = 'VIYAN-WEIGHBRIDGE';
const int _kDefaultLicenseVersion = 1;
const int _kDefaultMonths = 12;

void main(List<String> args) {
  if (args.isEmpty) {
    _printUsage();
    return;
  }

  switch (args.first) {
    case 'generate-keypair':
      _handleGenerateKeypair(args.sublist(1));
    case 'issue':
      _handleIssue(args.sublist(1));
    case 'verify':
      _handleVerify(args.sublist(1));
    default:
      _printUsage();
  }
}

void _printUsage() {
  stdout.writeln('''
ViyanInfo License Generator

Commands:
  generate-keypair [--output <file>]
      Generates a new Ed25519 keypair. Prints both keys and, if --output is
      given, writes the private key hex to that file.

  issue --private-key <hex> --machine-hash <hex> [options]
      Creates and signs a license file.

      Required:
        --private-key   64-byte Ed25519 private key as hex
        --machine-hash  Machine hash reported by the client (64 hex chars)

      Optional:
        --customer-id   Customer identifier (default: empty)
        --customer-name Customer display name (default: empty)
        --license-type  License type (default: annual)
        --months        Validity in whole months (default: 12)
        --expiry        Exact expiry date as YYYY-MM-DD (overrides --months)
        --product       Product id (default: VIYAN-WEIGHBRIDGE)
        --output        Output file path (default: license.dat)

  verify --license-file <path> --public-key <hex>
      Loads a license file and verifies its signature offline using the given
      public key (must match the client's embedded key).
''');
}

// ---- hex helpers -----------------------------------------------------------

String bytesToHex(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

Uint8List hexToBytes(String hex) {
  final clean = hex.trim();
  if (clean.isEmpty || clean.length.isOdd) {
    throw FormatException('Invalid hex string');
  }
  final result = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

// ---- keypair --------------------------------------------------------------

void _handleGenerateKeypair(List<String> args) {
  String? outputPath;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--output' && i + 1 < args.length) {
      outputPath = args[i + 1];
      i++;
    }
  }

  final keyPair = generateKey();
  final publicKeyHex = bytesToHex(keyPair.publicKey.bytes);
  final privateKeyHex = bytesToHex(keyPair.privateKey.bytes);

  stdout.writeln('Public key (embed in keys.dart, safe to share):');
  stdout.writeln('  $publicKeyHex');
  stdout.writeln();
  stdout.writeln('Private key (KEEP SECRET, 64 bytes = seed + public):');
  stdout.writeln('  $privateKeyHex');
  stdout.writeln();

  if (outputPath != null) {
    final file = File(outputPath);
    file.writeAsStringSync('private=$privateKeyHex\npublic=$publicKeyHex\n');
    stdout.writeln('Private key written to: $outputPath (do not commit this '
        'file to version control).');
  }
}

// ---- issue ----------------------------------------------------------------

void _handleIssue(List<String> args) {
  final options = _parseOptions(args);

  final privateKeyHex = options['private-key'];
  final machineHash = options['machine-hash'];
  if (privateKeyHex == null || machineHash == null) {
    stderr.writeln('Error: --private-key and --machine-hash are required.');
    exitCode = 1;
    return;
  }

  PrivateKey privateKey;
  try {
    final bytes = hexToBytes(privateKeyHex);
    if (bytes.length != PrivateKeySize) {
      stderr.writeln('Error: --private-key must be exactly '
          '${PrivateKeySize * 2} hex chars (found ${bytes.length * 2}).');
      exitCode = 1;
      return;
    }
    privateKey = PrivateKey(bytes);
  } on FormatException catch (e) {
    stderr.writeln('Error: invalid --private-key hex: ${e.message}');
    exitCode = 1;
    return;
  }

  if (machineHash.length != 64) {
    stderr.writeln('Error: --machine-hash must be a 64-char SHA-256 hex '
        'value (found ${machineHash.length} chars).');
    exitCode = 1;
    return;
  }

  DateTime expiresAt;
  if (options['expiry'] != null) {
    try {
      expiresAt = DateTime.parse(options['expiry']!).toUtc();
    } on FormatException {
      stderr.writeln('Error: --expiry must be YYYY-MM-DD.');
      exitCode = 1;
      return;
    }
  } else {
    final months =
        int.tryParse(options['months'] ?? '') ?? _kDefaultMonths;
    expiresAt = DateTime.now().toUtc().add(Duration(days: months * 30));
  }

  final issuedAt = DateTime.now().toUtc();

  final license = License(
    licenseId: _newLicenseId(),
    productId: options['product'] ?? _kDefaultProduct,
    customerId: options['customer-id'] ?? '',
    customerName: options['customer-name'] ?? '',
    machineHash: machineHash,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
    licenseType: options['license-type'] ?? 'annual',
    licenseVersion: _kDefaultLicenseVersion,
    signature: '',
  );

  final model = LicenseModel(license: license, rawJson: '');
  final payload = model.payloadJson;
  final signature = sign(
    privateKey,
    Uint8List.fromList(utf8.encode(payload)),
  );

  final signed = Map<String, dynamic>.from(license.toPayload())
    ..['signature'] = bytesToHex(signature);

  final outputPath = options['output'] ?? 'license.dat';
  File(outputPath).writeAsStringSync(jsonEncode(signed));

  stdout.writeln('License written to: $outputPath');
  stdout.writeln('  licenseId:     ${license.licenseId}');
  stdout.writeln('  productId:     ${license.productId}');
  stdout.writeln('  machineHash:   ${license.machineHash}');
  stdout.writeln('  customer:      '
      '${license.customerName.isEmpty ? '-' : license.customerName}');
  stdout.writeln('  issuedAt:      ${license.issuedAt.toIso8601String()}');
  stdout.writeln('  expiresAt:     ${license.expiresAt.toIso8601String()}');
  stdout.writeln('  licenseType:   ${license.licenseType}');
  stdout.writeln('  licenseVersion: ${license.licenseVersion}');
}

// ---- verify ---------------------------------------------------------------

void _handleVerify(List<String> args) {
  final options = _parseOptions(args);

  final licensePath = options['license-file'];
  final publicKeyHex = options['public-key'];
  if (licensePath == null || publicKeyHex == null) {
    stderr.writeln('Error: --license-file and --public-key are required.');
    exitCode = 1;
    return;
  }

  try {
    final jsonString = File(licensePath).readAsStringSync();
    final model = LicenseModel.fromJson(jsonString);
    final valid = model.verifySignature(publicKeyHex);

    if (valid) {
      final l = model.license;
      stdout.writeln('Signature:   VALID');
      stdout.writeln('Product:     ${l.productId}');
      stdout.writeln('Machine:     ${l.machineHash}');
      stdout.writeln('Expires:     ${l.expiresAt.toIso8601String()}');
      stdout.writeln('Expired:     ${l.isExpired}');
      stdout.writeln('Customer:    ${l.customerName}');
    } else {
      stderr.writeln('Signature:   INVALID');
      exitCode = 1;
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: malformed license file: ${e.message}');
    exitCode = 1;
  } on IOException catch (e) {
    stderr.writeln('Error: could not read license file: $e');
    exitCode = 1;
  }
}

// ---- helpers --------------------------------------------------------------

Map<String, String?> _parseOptions(List<String> args) {
  final options = <String, String?>{};
  for (var i = 0; i < args.length; i += 2) {
    final key = args[i];
    if (!key.startsWith('--')) {
      continue;
    }
    final value = i + 1 < args.length ? args[i + 1] : null;
    options[key.substring(2)] = value;
  }
  return options;
}

String _newLicenseId() {
  final rng = Random.secure();
  final randomHex = bytesToHex(
    List<int>.generate(8, (_) => rng.nextInt(256)),
  );
  return 'WB-${DateTime.now().toUtc().millisecondsSinceEpoch}-$randomHex';
}