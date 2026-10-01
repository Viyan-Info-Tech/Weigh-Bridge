import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/database/daos/scale_settings_dao.dart';
import 'package:weighbridge/core/hardware/scale/data/scale_config_adapter.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_models.dart';

void main() {
  late AppDatabase db;
  late ScaleSettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ScaleSettingsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Scale settings persistence', () {
    test('getSettings returns defaults on a fresh database', () async {
      final settings = await dao.getSettings();
      expect(settings.port, 'COM3');
      expect(settings.baudRate, 9600);
      expect(settings.dataBits, 8);
      expect(settings.parity, 0);
      expect(settings.stopBits, 1);
      expect(settings.protocol, 'unconfigured');
      expect(settings.enabled, isTrue);
    });

    test(
      'updateSettings persists and round-trips through the adapter',
      () async {
        await dao.getSettings();
        await dao.updateSettings(
          ScaleConfigAdapter.toCompanion(
            const ScaleConfig(
              port: 'COM7',
              baudRate: 19200,
              dataBits: 7,
              parity: ScaleParity.even,
              stopBits: 2,
              enabled: false,
            ),
          ),
        );

        final row = await dao.getSettings();
        expect(row.port, 'COM7');
        expect(row.baudRate, 19200);
        expect(row.dataBits, 7);
        expect(row.parity, 2);
        expect(row.stopBits, 2);
        expect(row.enabled, isFalse);

        final config = ScaleConfigAdapter.fromRow(row);
        expect(config.port, 'COM7');
        expect(config.baudRate, 19200);
        expect(config.dataBits, 7);
        expect(config.parity, ScaleParity.even);
        expect(config.stopBits, 2);
        expect(config.enabled, isFalse);
        expect(config.protocol, ScaleProtocolType.unconfigured);
      },
    );

    test('adapter maps unknown parity and protocol fallbacks safely', () {
      final config = ScaleConfigAdapter.fromRow(
        ScaleSetting(
          id: 1,
          port: 'COM3',
          baudRate: 9600,
          dataBits: 8,
          parity: 99,
          stopBits: 1,
          protocol: 'made-up-protocol',
          enabled: true,
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      expect(config.parity, ScaleParity.none);
      expect(config.protocol, ScaleProtocolType.unconfigured);
    });
  });
}
