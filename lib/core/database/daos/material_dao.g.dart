// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_dao.dart';

// ignore_for_file: type=lint
mixin _$MaterialDaoMixin on DatabaseAccessor<AppDatabase> {
  $MaterialsTable get materials => attachedDatabase.materials;
  $WeighmentsTable get weighments => attachedDatabase.weighments;
  MaterialDaoManager get managers => MaterialDaoManager(this);
}

class MaterialDaoManager {
  final _$MaterialDaoMixin _db;
  MaterialDaoManager(this._db);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db.attachedDatabase, _db.weighments);
}
