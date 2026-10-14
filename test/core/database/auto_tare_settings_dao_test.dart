import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/database/daos/auto_tare_settings_dao.dart';
import 'package:weighbridge/features/bill/data/datasources/auto_tare_local_datasource.dart';
import 'package:weighbridge/features/bill/data/repositories/auto_tare_repository_impl.dart';

void main() {
  late AppDatabase db;
  late AutoTareSettingsDao dao;
  late AutoTareRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AutoTareSettingsDao(db);
    repository = AutoTareRepositoryImpl(AutoTareLocalDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('Auto tare daily persistence', () {
    test('a day with no stored value reports Not Set', () async {
      expect(await dao.getForDate(DateTime(2026, 10, 1)), isNull);
      expect(await repository.getAutoTare(DateTime(2026, 10, 1)), isNull);
    });

    test('saves and reads back the tare for the day', () async {
      await repository.saveAutoTare(date: DateTime(2026, 10, 1), tareKg: 8000);

      final entry = await repository.getAutoTare(DateTime(2026, 10, 1));
      expect(entry, isNotNull);
      expect(entry!.tareKg, 8000);
      expect(entry.tareDate, DateTime(2026, 10, 1));
    });

    test('the lookup ignores the time of day', () async {
      await repository.saveAutoTare(
        date: DateTime(2026, 10, 1, 6, 30),
        tareKg: 8100,
      );

      final entry = await repository.getAutoTare(DateTime(2026, 10, 1, 22, 15));
      expect(entry!.tareKg, 8100);
    });

    test("yesterday's tare is never reused for a new day", () async {
      await repository.saveAutoTare(date: DateTime(2026, 9, 30), tareKg: 8000);

      expect(await repository.getAutoTare(DateTime(2026, 10, 1)), isNull);
      final historical = await repository.getAutoTare(DateTime(2026, 9, 30));
      expect(historical!.tareKg, 8000);
    });

    test('saving again replaces the value for the same day only', () async {
      await repository.saveAutoTare(date: DateTime(2026, 10, 1), tareKg: 8000);
      await repository.saveAutoTare(date: DateTime(2026, 10, 2), tareKg: 4000);
      await repository.saveAutoTare(date: DateTime(2026, 10, 1), tareKg: 8150);

      expect(
        (await repository.getAutoTare(DateTime(2026, 10, 1)))!.tareKg,
        8150,
      );
      expect(
        (await repository.getAutoTare(DateTime(2026, 10, 2)))!.tareKg,
        4000,
      );
    });

    test(
      'saving the identical value again updates instead of colliding',
      () async {
        await repository.saveAutoTare(
          date: DateTime(2026, 10, 1),
          tareKg: 8000,
        );
        await repository.saveAutoTare(
          date: DateTime(2026, 10, 1),
          tareKg: 8000,
        );

        final rows = await db.select(db.autoTareSettings).get();
        expect(rows, hasLength(1));
        expect(rows.single.tareKg, 8000);
      },
    );

    test('delete removes the value for that day only', () async {
      await repository.saveAutoTare(date: DateTime(2026, 10, 1), tareKg: 8000);
      await repository.saveAutoTare(date: DateTime(2026, 10, 2), tareKg: 4000);

      await repository.deleteAutoTare(DateTime(2026, 10, 1));

      expect(await repository.getAutoTare(DateTime(2026, 10, 1)), isNull);
      expect(
        (await repository.getAutoTare(DateTime(2026, 10, 2)))!.tareKg,
        4000,
      );
    });

    test('changing auto tare leaves already saved bills untouched', () async {
      await db.billDao.insertWeighment(
        WeighmentsCompanion.insert(
          billNumber: 'WB-00014',
          vehicleNumber: 'TN32AT0014',
          firstWeightKg: 20000,
          firstWeightType: const Value('GROSS'),
          secondWeightKg: const Value(8000),
          secondWeightType: const Value('TARE'),
          netWeightKg: const Value(12000),
          weightUnit: const Value('kg'),
        ),
      );

      await repository.saveAutoTare(date: DateTime(2026, 10, 1), tareKg: 8150);

      final bill = await db.billDao.getWeighmentByBillNumber('WB-00014');
      expect(bill!.secondWeightKg, 8000);
      expect(bill.netWeightKg, 12000);
    });
  });
}
