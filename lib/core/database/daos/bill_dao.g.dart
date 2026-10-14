// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_dao.dart';

// ignore_for_file: type=lint
mixin _$BillDaoMixin on DatabaseAccessor<AppDatabase> {
  $WeighmentsTable get weighments => attachedDatabase.weighments;
  BillDaoManager get managers => BillDaoManager(this);
}

class BillDaoManager {
  final _$BillDaoMixin _db;
  BillDaoManager(this._db);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db.attachedDatabase, _db.weighments);
}
