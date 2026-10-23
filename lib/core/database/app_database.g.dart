// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('operator'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String passwordHash;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    passwordHash,
    role,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? role,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeighmentsTable extends Weighments
    with TableInfo<$WeighmentsTable, Weighment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeighmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _billNumberMeta = const VerificationMeta(
    'billNumber',
  );
  @override
  late final GeneratedColumn<String> billNumber = GeneratedColumn<String>(
    'bill_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _vehicleNumberMeta = const VerificationMeta(
    'vehicleNumber',
  );
  @override
  late final GeneratedColumn<String> vehicleNumber = GeneratedColumn<String>(
    'vehicle_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstWeightKgMeta = const VerificationMeta(
    'firstWeightKg',
  );
  @override
  late final GeneratedColumn<double> firstWeightKg = GeneratedColumn<double>(
    'first_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstWeightTypeMeta = const VerificationMeta(
    'firstWeightType',
  );
  @override
  late final GeneratedColumn<String> firstWeightType = GeneratedColumn<String>(
    'first_weight_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GROSS'),
  );
  static const VerificationMeta _secondWeightKgMeta = const VerificationMeta(
    'secondWeightKg',
  );
  @override
  late final GeneratedColumn<double> secondWeightKg = GeneratedColumn<double>(
    'second_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondWeightTypeMeta = const VerificationMeta(
    'secondWeightType',
  );
  @override
  late final GeneratedColumn<String> secondWeightType = GeneratedColumn<String>(
    'second_weight_type',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netWeightKgMeta = const VerificationMeta(
    'netWeightKg',
  );
  @override
  late final GeneratedColumn<double> netWeightKg = GeneratedColumn<double>(
    'net_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<int> materialId = GeneratedColumn<int>(
    'material_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargesMeta = const VerificationMeta(
    'charges',
  );
  @override
  late final GeneratedColumn<double> charges = GeneratedColumn<double>(
    'charges',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousWeighmentIdMeta =
      const VerificationMeta('previousWeighmentId');
  @override
  late final GeneratedColumn<int> previousWeighmentId = GeneratedColumn<int>(
    'previous_weighment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightUnitMeta = const VerificationMeta(
    'weightUnit',
  );
  @override
  late final GeneratedColumn<String> weightUnit = GeneratedColumn<String>(
    'weight_unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ton'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billNumber,
    vehicleNumber,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    netWeightKg,
    material,
    materialId,
    charges,
    previousWeighmentId,
    description,
    remarks,
    mobileNumber,
    weightUnit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weighments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Weighment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_number')) {
      context.handle(
        _billNumberMeta,
        billNumber.isAcceptableOrUnknown(data['bill_number']!, _billNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_billNumberMeta);
    }
    if (data.containsKey('vehicle_number')) {
      context.handle(
        _vehicleNumberMeta,
        vehicleNumber.isAcceptableOrUnknown(
          data['vehicle_number']!,
          _vehicleNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleNumberMeta);
    }
    if (data.containsKey('first_weight_kg')) {
      context.handle(
        _firstWeightKgMeta,
        firstWeightKg.isAcceptableOrUnknown(
          data['first_weight_kg']!,
          _firstWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstWeightKgMeta);
    }
    if (data.containsKey('first_weight_type')) {
      context.handle(
        _firstWeightTypeMeta,
        firstWeightType.isAcceptableOrUnknown(
          data['first_weight_type']!,
          _firstWeightTypeMeta,
        ),
      );
    }
    if (data.containsKey('second_weight_kg')) {
      context.handle(
        _secondWeightKgMeta,
        secondWeightKg.isAcceptableOrUnknown(
          data['second_weight_kg']!,
          _secondWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('second_weight_type')) {
      context.handle(
        _secondWeightTypeMeta,
        secondWeightType.isAcceptableOrUnknown(
          data['second_weight_type']!,
          _secondWeightTypeMeta,
        ),
      );
    }
    if (data.containsKey('net_weight_kg')) {
      context.handle(
        _netWeightKgMeta,
        netWeightKg.isAcceptableOrUnknown(
          data['net_weight_kg']!,
          _netWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    }
    if (data.containsKey('charges')) {
      context.handle(
        _chargesMeta,
        charges.isAcceptableOrUnknown(data['charges']!, _chargesMeta),
      );
    }
    if (data.containsKey('previous_weighment_id')) {
      context.handle(
        _previousWeighmentIdMeta,
        previousWeighmentId.isAcceptableOrUnknown(
          data['previous_weighment_id']!,
          _previousWeighmentIdMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    }
    if (data.containsKey('weight_unit')) {
      context.handle(
        _weightUnitMeta,
        weightUnit.isAcceptableOrUnknown(data['weight_unit']!, _weightUnitMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Weighment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Weighment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      billNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_number'],
      )!,
      vehicleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number'],
      )!,
      firstWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}first_weight_kg'],
      )!,
      firstWeightType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_weight_type'],
      )!,
      secondWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}second_weight_kg'],
      ),
      secondWeightType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_weight_type'],
      ),
      netWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_weight_kg'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}material_id'],
      ),
      charges: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charges'],
      ),
      previousWeighmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_weighment_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      ),
      weightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeighmentsTable createAlias(String alias) {
    return $WeighmentsTable(attachedDatabase, alias);
  }
}

class Weighment extends DataClass implements Insertable<Weighment> {
  final int id;
  final String billNumber;
  final String vehicleNumber;
  final double firstWeightKg;
  final String firstWeightType;
  final double? secondWeightKg;
  final String? secondWeightType;
  final double? netWeightKg;

  /// Material name + vehicle type snapshot stored with the weighment
  /// (e.g. `Auto - Empty`).
  ///
  /// The value is denormalised on purpose: a saved bill must keep printing
  /// exactly what the operator selected even after the material master is
  /// edited or deactivated later. Nullable so legacy rows (schema 30-32)
  /// and tare-only weighments stay valid.
  final String? material;

  /// Stable reference to the material master row chosen on the form
  /// (schema 33). Nullable: legacy rows and tare-only weighments have none.
  ///
  /// No foreign-key constraint is declared so the schema-33 migration can be
  /// a plain additive `ALTER TABLE ADD COLUMN` instead of a table rebuild;
  /// deletion of referenced materials is blocked in the DAO instead.
  final int? materialId;

  /// Manually entered charges for this weighment, in rupees.
  ///
  /// Nullable so legacy rows (created before this column existed) stay valid;
  /// NULL renders as an empty value in the form and zero total in reports.
  final double? charges;

  /// Id of the earlier weighment this bill completes (second-weight flow).
  ///
  /// Set only when the bill was created in SECOND WEIGHT mode: it points at
  /// the single-weight bill whose previous weight was reused. Nullable so
  /// every normal bill (and all legacy rows) simply read back NULL. No
  /// foreign-key constraint is declared so the schema-35 migration is a plain
  /// additive `ALTER TABLE ADD COLUMN`; the referenced bill is immutable
  /// history and is never deleted by the application.
  final int? previousWeighmentId;

  /// Legacy weighment description (schema 30).
  ///
  /// No longer part of the weighment workflow: the UI, receipt, PDF, and
  /// application data flow never read or write it. The column is deliberately
  /// kept in the schema so no migration or schema-version bump is needed and
  /// description values already stored on existing weighment rows stay intact.
  final String? description;
  final String? remarks;
  final String? mobileNumber;
  final String weightUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Weighment({
    required this.id,
    required this.billNumber,
    required this.vehicleNumber,
    required this.firstWeightKg,
    required this.firstWeightType,
    this.secondWeightKg,
    this.secondWeightType,
    this.netWeightKg,
    this.material,
    this.materialId,
    this.charges,
    this.previousWeighmentId,
    this.description,
    this.remarks,
    this.mobileNumber,
    required this.weightUnit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_number'] = Variable<String>(billNumber);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
    map['first_weight_kg'] = Variable<double>(firstWeightKg);
    map['first_weight_type'] = Variable<String>(firstWeightType);
    if (!nullToAbsent || secondWeightKg != null) {
      map['second_weight_kg'] = Variable<double>(secondWeightKg);
    }
    if (!nullToAbsent || secondWeightType != null) {
      map['second_weight_type'] = Variable<String>(secondWeightType);
    }
    if (!nullToAbsent || netWeightKg != null) {
      map['net_weight_kg'] = Variable<double>(netWeightKg);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    if (!nullToAbsent || materialId != null) {
      map['material_id'] = Variable<int>(materialId);
    }
    if (!nullToAbsent || charges != null) {
      map['charges'] = Variable<double>(charges);
    }
    if (!nullToAbsent || previousWeighmentId != null) {
      map['previous_weighment_id'] = Variable<int>(previousWeighmentId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || mobileNumber != null) {
      map['mobile_number'] = Variable<String>(mobileNumber);
    }
    map['weight_unit'] = Variable<String>(weightUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeighmentsCompanion toCompanion(bool nullToAbsent) {
    return WeighmentsCompanion(
      id: Value(id),
      billNumber: Value(billNumber),
      vehicleNumber: Value(vehicleNumber),
      firstWeightKg: Value(firstWeightKg),
      firstWeightType: Value(firstWeightType),
      secondWeightKg: secondWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(secondWeightKg),
      secondWeightType: secondWeightType == null && nullToAbsent
          ? const Value.absent()
          : Value(secondWeightType),
      netWeightKg: netWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(netWeightKg),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
      materialId: materialId == null && nullToAbsent
          ? const Value.absent()
          : Value(materialId),
      charges: charges == null && nullToAbsent
          ? const Value.absent()
          : Value(charges),
      previousWeighmentId: previousWeighmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousWeighmentId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      mobileNumber: mobileNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(mobileNumber),
      weightUnit: Value(weightUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Weighment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Weighment(
      id: serializer.fromJson<int>(json['id']),
      billNumber: serializer.fromJson<String>(json['billNumber']),
      vehicleNumber: serializer.fromJson<String>(json['vehicleNumber']),
      firstWeightKg: serializer.fromJson<double>(json['firstWeightKg']),
      firstWeightType: serializer.fromJson<String>(json['firstWeightType']),
      secondWeightKg: serializer.fromJson<double?>(json['secondWeightKg']),
      secondWeightType: serializer.fromJson<String?>(json['secondWeightType']),
      netWeightKg: serializer.fromJson<double?>(json['netWeightKg']),
      material: serializer.fromJson<String?>(json['material']),
      materialId: serializer.fromJson<int?>(json['materialId']),
      charges: serializer.fromJson<double?>(json['charges']),
      previousWeighmentId: serializer.fromJson<int?>(
        json['previousWeighmentId'],
      ),
      description: serializer.fromJson<String?>(json['description']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      mobileNumber: serializer.fromJson<String?>(json['mobileNumber']),
      weightUnit: serializer.fromJson<String>(json['weightUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billNumber': serializer.toJson<String>(billNumber),
      'vehicleNumber': serializer.toJson<String>(vehicleNumber),
      'firstWeightKg': serializer.toJson<double>(firstWeightKg),
      'firstWeightType': serializer.toJson<String>(firstWeightType),
      'secondWeightKg': serializer.toJson<double?>(secondWeightKg),
      'secondWeightType': serializer.toJson<String?>(secondWeightType),
      'netWeightKg': serializer.toJson<double?>(netWeightKg),
      'material': serializer.toJson<String?>(material),
      'materialId': serializer.toJson<int?>(materialId),
      'charges': serializer.toJson<double?>(charges),
      'previousWeighmentId': serializer.toJson<int?>(previousWeighmentId),
      'description': serializer.toJson<String?>(description),
      'remarks': serializer.toJson<String?>(remarks),
      'mobileNumber': serializer.toJson<String?>(mobileNumber),
      'weightUnit': serializer.toJson<String>(weightUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Weighment copyWith({
    int? id,
    String? billNumber,
    String? vehicleNumber,
    double? firstWeightKg,
    String? firstWeightType,
    Value<double?> secondWeightKg = const Value.absent(),
    Value<String?> secondWeightType = const Value.absent(),
    Value<double?> netWeightKg = const Value.absent(),
    Value<String?> material = const Value.absent(),
    Value<int?> materialId = const Value.absent(),
    Value<double?> charges = const Value.absent(),
    Value<int?> previousWeighmentId = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> mobileNumber = const Value.absent(),
    String? weightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Weighment(
    id: id ?? this.id,
    billNumber: billNumber ?? this.billNumber,
    vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    firstWeightKg: firstWeightKg ?? this.firstWeightKg,
    firstWeightType: firstWeightType ?? this.firstWeightType,
    secondWeightKg: secondWeightKg.present
        ? secondWeightKg.value
        : this.secondWeightKg,
    secondWeightType: secondWeightType.present
        ? secondWeightType.value
        : this.secondWeightType,
    netWeightKg: netWeightKg.present ? netWeightKg.value : this.netWeightKg,
    material: material.present ? material.value : this.material,
    materialId: materialId.present ? materialId.value : this.materialId,
    charges: charges.present ? charges.value : this.charges,
    previousWeighmentId: previousWeighmentId.present
        ? previousWeighmentId.value
        : this.previousWeighmentId,
    description: description.present ? description.value : this.description,
    remarks: remarks.present ? remarks.value : this.remarks,
    mobileNumber: mobileNumber.present ? mobileNumber.value : this.mobileNumber,
    weightUnit: weightUnit ?? this.weightUnit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Weighment copyWithCompanion(WeighmentsCompanion data) {
    return Weighment(
      id: data.id.present ? data.id.value : this.id,
      billNumber: data.billNumber.present
          ? data.billNumber.value
          : this.billNumber,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
      firstWeightKg: data.firstWeightKg.present
          ? data.firstWeightKg.value
          : this.firstWeightKg,
      firstWeightType: data.firstWeightType.present
          ? data.firstWeightType.value
          : this.firstWeightType,
      secondWeightKg: data.secondWeightKg.present
          ? data.secondWeightKg.value
          : this.secondWeightKg,
      secondWeightType: data.secondWeightType.present
          ? data.secondWeightType.value
          : this.secondWeightType,
      netWeightKg: data.netWeightKg.present
          ? data.netWeightKg.value
          : this.netWeightKg,
      material: data.material.present ? data.material.value : this.material,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      charges: data.charges.present ? data.charges.value : this.charges,
      previousWeighmentId: data.previousWeighmentId.present
          ? data.previousWeighmentId.value
          : this.previousWeighmentId,
      description: data.description.present
          ? data.description.value
          : this.description,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Weighment(')
          ..write('id: $id, ')
          ..write('billNumber: $billNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('firstWeightType: $firstWeightType, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('secondWeightType: $secondWeightType, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('material: $material, ')
          ..write('materialId: $materialId, ')
          ..write('charges: $charges, ')
          ..write('previousWeighmentId: $previousWeighmentId, ')
          ..write('description: $description, ')
          ..write('remarks: $remarks, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billNumber,
    vehicleNumber,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    netWeightKg,
    material,
    materialId,
    charges,
    previousWeighmentId,
    description,
    remarks,
    mobileNumber,
    weightUnit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weighment &&
          other.id == this.id &&
          other.billNumber == this.billNumber &&
          other.vehicleNumber == this.vehicleNumber &&
          other.firstWeightKg == this.firstWeightKg &&
          other.firstWeightType == this.firstWeightType &&
          other.secondWeightKg == this.secondWeightKg &&
          other.secondWeightType == this.secondWeightType &&
          other.netWeightKg == this.netWeightKg &&
          other.material == this.material &&
          other.materialId == this.materialId &&
          other.charges == this.charges &&
          other.previousWeighmentId == this.previousWeighmentId &&
          other.description == this.description &&
          other.remarks == this.remarks &&
          other.mobileNumber == this.mobileNumber &&
          other.weightUnit == this.weightUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeighmentsCompanion extends UpdateCompanion<Weighment> {
  final Value<int> id;
  final Value<String> billNumber;
  final Value<String> vehicleNumber;
  final Value<double> firstWeightKg;
  final Value<String> firstWeightType;
  final Value<double?> secondWeightKg;
  final Value<String?> secondWeightType;
  final Value<double?> netWeightKg;
  final Value<String?> material;
  final Value<int?> materialId;
  final Value<double?> charges;
  final Value<int?> previousWeighmentId;
  final Value<String?> description;
  final Value<String?> remarks;
  final Value<String?> mobileNumber;
  final Value<String> weightUnit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeighmentsCompanion({
    this.id = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.firstWeightKg = const Value.absent(),
    this.firstWeightType = const Value.absent(),
    this.secondWeightKg = const Value.absent(),
    this.secondWeightType = const Value.absent(),
    this.netWeightKg = const Value.absent(),
    this.material = const Value.absent(),
    this.materialId = const Value.absent(),
    this.charges = const Value.absent(),
    this.previousWeighmentId = const Value.absent(),
    this.description = const Value.absent(),
    this.remarks = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeighmentsCompanion.insert({
    this.id = const Value.absent(),
    required String billNumber,
    required String vehicleNumber,
    required double firstWeightKg,
    this.firstWeightType = const Value.absent(),
    this.secondWeightKg = const Value.absent(),
    this.secondWeightType = const Value.absent(),
    this.netWeightKg = const Value.absent(),
    this.material = const Value.absent(),
    this.materialId = const Value.absent(),
    this.charges = const Value.absent(),
    this.previousWeighmentId = const Value.absent(),
    this.description = const Value.absent(),
    this.remarks = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : billNumber = Value(billNumber),
       vehicleNumber = Value(vehicleNumber),
       firstWeightKg = Value(firstWeightKg);
  static Insertable<Weighment> custom({
    Expression<int>? id,
    Expression<String>? billNumber,
    Expression<String>? vehicleNumber,
    Expression<double>? firstWeightKg,
    Expression<String>? firstWeightType,
    Expression<double>? secondWeightKg,
    Expression<String>? secondWeightType,
    Expression<double>? netWeightKg,
    Expression<String>? material,
    Expression<int>? materialId,
    Expression<double>? charges,
    Expression<int>? previousWeighmentId,
    Expression<String>? description,
    Expression<String>? remarks,
    Expression<String>? mobileNumber,
    Expression<String>? weightUnit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billNumber != null) 'bill_number': billNumber,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (firstWeightKg != null) 'first_weight_kg': firstWeightKg,
      if (firstWeightType != null) 'first_weight_type': firstWeightType,
      if (secondWeightKg != null) 'second_weight_kg': secondWeightKg,
      if (secondWeightType != null) 'second_weight_type': secondWeightType,
      if (netWeightKg != null) 'net_weight_kg': netWeightKg,
      if (material != null) 'material': material,
      if (materialId != null) 'material_id': materialId,
      if (charges != null) 'charges': charges,
      if (previousWeighmentId != null)
        'previous_weighment_id': previousWeighmentId,
      if (description != null) 'description': description,
      if (remarks != null) 'remarks': remarks,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeighmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? billNumber,
    Value<String>? vehicleNumber,
    Value<double>? firstWeightKg,
    Value<String>? firstWeightType,
    Value<double?>? secondWeightKg,
    Value<String?>? secondWeightType,
    Value<double?>? netWeightKg,
    Value<String?>? material,
    Value<int?>? materialId,
    Value<double?>? charges,
    Value<int?>? previousWeighmentId,
    Value<String?>? description,
    Value<String?>? remarks,
    Value<String?>? mobileNumber,
    Value<String>? weightUnit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeighmentsCompanion(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      firstWeightType: firstWeightType ?? this.firstWeightType,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      secondWeightType: secondWeightType ?? this.secondWeightType,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      material: material ?? this.material,
      materialId: materialId ?? this.materialId,
      charges: charges ?? this.charges,
      previousWeighmentId: previousWeighmentId ?? this.previousWeighmentId,
      description: description ?? this.description,
      remarks: remarks ?? this.remarks,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      weightUnit: weightUnit ?? this.weightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billNumber.present) {
      map['bill_number'] = Variable<String>(billNumber.value);
    }
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
    }
    if (firstWeightKg.present) {
      map['first_weight_kg'] = Variable<double>(firstWeightKg.value);
    }
    if (firstWeightType.present) {
      map['first_weight_type'] = Variable<String>(firstWeightType.value);
    }
    if (secondWeightKg.present) {
      map['second_weight_kg'] = Variable<double>(secondWeightKg.value);
    }
    if (secondWeightType.present) {
      map['second_weight_type'] = Variable<String>(secondWeightType.value);
    }
    if (netWeightKg.present) {
      map['net_weight_kg'] = Variable<double>(netWeightKg.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<int>(materialId.value);
    }
    if (charges.present) {
      map['charges'] = Variable<double>(charges.value);
    }
    if (previousWeighmentId.present) {
      map['previous_weighment_id'] = Variable<int>(previousWeighmentId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(weightUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeighmentsCompanion(')
          ..write('id: $id, ')
          ..write('billNumber: $billNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('firstWeightType: $firstWeightType, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('secondWeightType: $secondWeightType, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('material: $material, ')
          ..write('materialId: $materialId, ')
          ..write('charges: $charges, ')
          ..write('previousWeighmentId: $previousWeighmentId, ')
          ..write('description: $description, ')
          ..write('remarks: $remarks, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, Material> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleTypeMeta = const VerificationMeta(
    'vehicleType',
  );
  @override
  late final GeneratedColumn<String> vehicleType = GeneratedColumn<String>(
    'vehicle_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    vehicleType,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Material> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('vehicle_type')) {
      context.handle(
        _vehicleTypeMeta,
        vehicleType.isAcceptableOrUnknown(
          data['vehicle_type']!,
          _vehicleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleTypeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Material map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Material(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      vehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class Material extends DataClass implements Insertable<Material> {
  final int id;
  final String name;

  /// One of [MaterialVehicleTypes.all]: `Empty` or `Load`.
  final String vehicleType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Material({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['vehicle_type'] = Variable<String>(vehicleType);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      name: Value(name),
      vehicleType: Value(vehicleType),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Material.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Material(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      vehicleType: serializer.fromJson<String>(json['vehicleType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'vehicleType': serializer.toJson<String>(vehicleType),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Material copyWith({
    int? id,
    String? name,
    String? vehicleType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Material(
    id: id ?? this.id,
    name: name ?? this.name,
    vehicleType: vehicleType ?? this.vehicleType,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      vehicleType: data.vehicleType.present
          ? data.vehicleType.value
          : this.vehicleType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Material(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, vehicleType, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.name == this.name &&
          other.vehicleType == this.vehicleType &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> vehicleType;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String vehicleType,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       vehicleType = Value(vehicleType);
  static Insertable<Material> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? vehicleType,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? vehicleType,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(vehicleType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weightUnitMeta = const VerificationMeta(
    'weightUnit',
  );
  @override
  late final GeneratedColumn<String> weightUnit = GeneratedColumn<String>(
    'weight_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ton'),
  );
  static const VerificationMeta _billPrefixMeta = const VerificationMeta(
    'billPrefix',
  );
  @override
  late final GeneratedColumn<String> billPrefix = GeneratedColumn<String>(
    'bill_prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WB'),
  );
  static const VerificationMeta _billStartingNumberMeta =
      const VerificationMeta('billStartingNumber');
  @override
  late final GeneratedColumn<int> billStartingNumber = GeneratedColumn<int>(
    'bill_starting_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _billNumberDigitsMeta = const VerificationMeta(
    'billNumberDigits',
  );
  @override
  late final GeneratedColumn<int> billNumberDigits = GeneratedColumn<int>(
    'bill_number_digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('VIYAN WEIGHBRIDGE'),
  );
  static const VerificationMeta _businessSubtitleMeta = const VerificationMeta(
    'businessSubtitle',
  );
  @override
  late final GeneratedColumn<String> businessSubtitle = GeneratedColumn<String>(
    'business_subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTextMeta = const VerificationMeta(
    'serviceText',
  );
  @override
  late final GeneratedColumn<String> serviceText = GeneratedColumn<String>(
    'service_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptTitleMeta = const VerificationMeta(
    'receiptTitle',
  );
  @override
  late final GeneratedColumn<String> receiptTitle = GeneratedColumn<String>(
    'receipt_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WEIGHMENT RECEIPT'),
  );
  static const VerificationMeta _showSerialNumberMeta = const VerificationMeta(
    'showSerialNumber',
  );
  @override
  late final GeneratedColumn<bool> showSerialNumber = GeneratedColumn<bool>(
    'show_serial_number',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_serial_number" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showDateMeta = const VerificationMeta(
    'showDate',
  );
  @override
  late final GeneratedColumn<bool> showDate = GeneratedColumn<bool>(
    'show_date',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_date" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showTimeMeta = const VerificationMeta(
    'showTime',
  );
  @override
  late final GeneratedColumn<bool> showTime = GeneratedColumn<bool>(
    'show_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_time" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showVehicleNumberMeta = const VerificationMeta(
    'showVehicleNumber',
  );
  @override
  late final GeneratedColumn<bool> showVehicleNumber = GeneratedColumn<bool>(
    'show_vehicle_number',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_vehicle_number" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showGrossWeightMeta = const VerificationMeta(
    'showGrossWeight',
  );
  @override
  late final GeneratedColumn<bool> showGrossWeight = GeneratedColumn<bool>(
    'show_gross_weight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_gross_weight" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showTareWeightMeta = const VerificationMeta(
    'showTareWeight',
  );
  @override
  late final GeneratedColumn<bool> showTareWeight = GeneratedColumn<bool>(
    'show_tare_weight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_tare_weight" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showNetWeightMeta = const VerificationMeta(
    'showNetWeight',
  );
  @override
  late final GeneratedColumn<bool> showNetWeight = GeneratedColumn<bool>(
    'show_net_weight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_net_weight" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showRemarksMeta = const VerificationMeta(
    'showRemarks',
  );
  @override
  late final GeneratedColumn<bool> showRemarks = GeneratedColumn<bool>(
    'show_remarks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_remarks" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showFooterNoteMeta = const VerificationMeta(
    'showFooterNote',
  );
  @override
  late final GeneratedColumn<bool> showFooterNote = GeneratedColumn<bool>(
    'show_footer_note',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_footer_note" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _footerNoteMeta = const VerificationMeta(
    'footerNote',
  );
  @override
  late final GeneratedColumn<String> footerNote = GeneratedColumn<String>(
    'footer_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printCpiMeta = const VerificationMeta(
    'printCpi',
  );
  @override
  late final GeneratedColumn<int> printCpi = GeneratedColumn<int>(
    'print_cpi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12),
  );
  static const VerificationMeta _printLpiMeta = const VerificationMeta(
    'printLpi',
  );
  @override
  late final GeneratedColumn<int> printLpi = GeneratedColumn<int>(
    'print_lpi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _printPaperWidthMmMeta = const VerificationMeta(
    'printPaperWidthMm',
  );
  @override
  late final GeneratedColumn<double> printPaperWidthMm =
      GeneratedColumn<double>(
        'print_paper_width_mm',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _printPaperLengthMmMeta =
      const VerificationMeta('printPaperLengthMm');
  @override
  late final GeneratedColumn<double> printPaperLengthMm =
      GeneratedColumn<double>(
        'print_paper_length_mm',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _printLeftOffsetMmMeta = const VerificationMeta(
    'printLeftOffsetMm',
  );
  @override
  late final GeneratedColumn<double> printLeftOffsetMm =
      GeneratedColumn<double>(
        'print_left_offset_mm',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _printTopOffsetMmMeta = const VerificationMeta(
    'printTopOffsetMm',
  );
  @override
  late final GeneratedColumn<double> printTopOffsetMm = GeneratedColumn<double>(
    'print_top_offset_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _printColumnWidthMmMeta =
      const VerificationMeta('printColumnWidthMm');
  @override
  late final GeneratedColumn<double> printColumnWidthMm =
      GeneratedColumn<double>(
        'print_column_width_mm',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _printFieldGridMeta = const VerificationMeta(
    'printFieldGrid',
  );
  @override
  late final GeneratedColumn<String> printFieldGrid = GeneratedColumn<String>(
    'print_field_grid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printWeightUnitMeta = const VerificationMeta(
    'printWeightUnit',
  );
  @override
  late final GeneratedColumn<bool> printWeightUnit = GeneratedColumn<bool>(
    'print_weight_unit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("print_weight_unit" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weightUnit,
    billPrefix,
    billStartingNumber,
    billNumberDigits,
    businessName,
    businessSubtitle,
    serviceText,
    address,
    phoneNumber,
    email,
    gstin,
    logoPath,
    receiptTitle,
    showSerialNumber,
    showDate,
    showTime,
    showVehicleNumber,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showRemarks,
    showFooterNote,
    footerNote,
    printCpi,
    printLpi,
    printPaperWidthMm,
    printPaperLengthMm,
    printLeftOffsetMm,
    printTopOffsetMm,
    printColumnWidthMm,
    printFieldGrid,
    printWeightUnit,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight_unit')) {
      context.handle(
        _weightUnitMeta,
        weightUnit.isAcceptableOrUnknown(data['weight_unit']!, _weightUnitMeta),
      );
    }
    if (data.containsKey('bill_prefix')) {
      context.handle(
        _billPrefixMeta,
        billPrefix.isAcceptableOrUnknown(data['bill_prefix']!, _billPrefixMeta),
      );
    }
    if (data.containsKey('bill_starting_number')) {
      context.handle(
        _billStartingNumberMeta,
        billStartingNumber.isAcceptableOrUnknown(
          data['bill_starting_number']!,
          _billStartingNumberMeta,
        ),
      );
    }
    if (data.containsKey('bill_number_digits')) {
      context.handle(
        _billNumberDigitsMeta,
        billNumberDigits.isAcceptableOrUnknown(
          data['bill_number_digits']!,
          _billNumberDigitsMeta,
        ),
      );
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('business_subtitle')) {
      context.handle(
        _businessSubtitleMeta,
        businessSubtitle.isAcceptableOrUnknown(
          data['business_subtitle']!,
          _businessSubtitleMeta,
        ),
      );
    }
    if (data.containsKey('service_text')) {
      context.handle(
        _serviceTextMeta,
        serviceText.isAcceptableOrUnknown(
          data['service_text']!,
          _serviceTextMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('receipt_title')) {
      context.handle(
        _receiptTitleMeta,
        receiptTitle.isAcceptableOrUnknown(
          data['receipt_title']!,
          _receiptTitleMeta,
        ),
      );
    }
    if (data.containsKey('show_serial_number')) {
      context.handle(
        _showSerialNumberMeta,
        showSerialNumber.isAcceptableOrUnknown(
          data['show_serial_number']!,
          _showSerialNumberMeta,
        ),
      );
    }
    if (data.containsKey('show_date')) {
      context.handle(
        _showDateMeta,
        showDate.isAcceptableOrUnknown(data['show_date']!, _showDateMeta),
      );
    }
    if (data.containsKey('show_time')) {
      context.handle(
        _showTimeMeta,
        showTime.isAcceptableOrUnknown(data['show_time']!, _showTimeMeta),
      );
    }
    if (data.containsKey('show_vehicle_number')) {
      context.handle(
        _showVehicleNumberMeta,
        showVehicleNumber.isAcceptableOrUnknown(
          data['show_vehicle_number']!,
          _showVehicleNumberMeta,
        ),
      );
    }
    if (data.containsKey('show_gross_weight')) {
      context.handle(
        _showGrossWeightMeta,
        showGrossWeight.isAcceptableOrUnknown(
          data['show_gross_weight']!,
          _showGrossWeightMeta,
        ),
      );
    }
    if (data.containsKey('show_tare_weight')) {
      context.handle(
        _showTareWeightMeta,
        showTareWeight.isAcceptableOrUnknown(
          data['show_tare_weight']!,
          _showTareWeightMeta,
        ),
      );
    }
    if (data.containsKey('show_net_weight')) {
      context.handle(
        _showNetWeightMeta,
        showNetWeight.isAcceptableOrUnknown(
          data['show_net_weight']!,
          _showNetWeightMeta,
        ),
      );
    }
    if (data.containsKey('show_remarks')) {
      context.handle(
        _showRemarksMeta,
        showRemarks.isAcceptableOrUnknown(
          data['show_remarks']!,
          _showRemarksMeta,
        ),
      );
    }
    if (data.containsKey('show_footer_note')) {
      context.handle(
        _showFooterNoteMeta,
        showFooterNote.isAcceptableOrUnknown(
          data['show_footer_note']!,
          _showFooterNoteMeta,
        ),
      );
    }
    if (data.containsKey('footer_note')) {
      context.handle(
        _footerNoteMeta,
        footerNote.isAcceptableOrUnknown(data['footer_note']!, _footerNoteMeta),
      );
    }
    if (data.containsKey('print_cpi')) {
      context.handle(
        _printCpiMeta,
        printCpi.isAcceptableOrUnknown(data['print_cpi']!, _printCpiMeta),
      );
    }
    if (data.containsKey('print_lpi')) {
      context.handle(
        _printLpiMeta,
        printLpi.isAcceptableOrUnknown(data['print_lpi']!, _printLpiMeta),
      );
    }
    if (data.containsKey('print_paper_width_mm')) {
      context.handle(
        _printPaperWidthMmMeta,
        printPaperWidthMm.isAcceptableOrUnknown(
          data['print_paper_width_mm']!,
          _printPaperWidthMmMeta,
        ),
      );
    }
    if (data.containsKey('print_paper_length_mm')) {
      context.handle(
        _printPaperLengthMmMeta,
        printPaperLengthMm.isAcceptableOrUnknown(
          data['print_paper_length_mm']!,
          _printPaperLengthMmMeta,
        ),
      );
    }
    if (data.containsKey('print_left_offset_mm')) {
      context.handle(
        _printLeftOffsetMmMeta,
        printLeftOffsetMm.isAcceptableOrUnknown(
          data['print_left_offset_mm']!,
          _printLeftOffsetMmMeta,
        ),
      );
    }
    if (data.containsKey('print_top_offset_mm')) {
      context.handle(
        _printTopOffsetMmMeta,
        printTopOffsetMm.isAcceptableOrUnknown(
          data['print_top_offset_mm']!,
          _printTopOffsetMmMeta,
        ),
      );
    }
    if (data.containsKey('print_column_width_mm')) {
      context.handle(
        _printColumnWidthMmMeta,
        printColumnWidthMm.isAcceptableOrUnknown(
          data['print_column_width_mm']!,
          _printColumnWidthMmMeta,
        ),
      );
    }
    if (data.containsKey('print_field_grid')) {
      context.handle(
        _printFieldGridMeta,
        printFieldGrid.isAcceptableOrUnknown(
          data['print_field_grid']!,
          _printFieldGridMeta,
        ),
      );
    }
    if (data.containsKey('print_weight_unit')) {
      context.handle(
        _printWeightUnitMeta,
        printWeightUnit.isAcceptableOrUnknown(
          data['print_weight_unit']!,
          _printWeightUnitMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_unit'],
      )!,
      billPrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_prefix'],
      )!,
      billStartingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_starting_number'],
      )!,
      billNumberDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_number_digits'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      businessSubtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_subtitle'],
      ),
      serviceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_text'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      receiptTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_title'],
      )!,
      showSerialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_serial_number'],
      )!,
      showDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_date'],
      )!,
      showTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_time'],
      )!,
      showVehicleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_vehicle_number'],
      )!,
      showGrossWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_gross_weight'],
      )!,
      showTareWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_tare_weight'],
      )!,
      showNetWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_net_weight'],
      )!,
      showRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_remarks'],
      )!,
      showFooterNote: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_footer_note'],
      )!,
      footerNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}footer_note'],
      ),
      printCpi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}print_cpi'],
      )!,
      printLpi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}print_lpi'],
      )!,
      printPaperWidthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}print_paper_width_mm'],
      )!,
      printPaperLengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}print_paper_length_mm'],
      )!,
      printLeftOffsetMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}print_left_offset_mm'],
      )!,
      printTopOffsetMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}print_top_offset_mm'],
      )!,
      printColumnWidthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}print_column_width_mm'],
      )!,
      printFieldGrid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}print_field_grid'],
      ),
      printWeightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}print_weight_unit'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String weightUnit;
  final String billPrefix;
  final int billStartingNumber;
  final int billNumberDigits;
  final String businessName;
  final String? businessSubtitle;
  final String? serviceText;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? gstin;
  final String? logoPath;
  final String receiptTitle;
  final bool showSerialNumber;
  final bool showDate;
  final bool showTime;
  final bool showVehicleNumber;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showRemarks;
  final bool showFooterNote;
  final String? footerNote;

  /// Characters per inch: 10 or 12.
  final int printCpi;

  /// Lines per inch: 6 or 8.
  final int printLpi;

  /// Custom paper width in mm; 0 = use the size reported by the printer driver.
  final double printPaperWidthMm;

  /// Custom paper length in mm; 0 = use the size reported by the printer driver.
  final double printPaperLengthMm;

  /// Fine horizontal nudge in mm added to the driver's printable-area offset.
  final double printLeftOffsetMm;

  /// Fine vertical nudge in mm added to the driver's printable-area offset.
  final double printTopOffsetMm;

  /// Distance in mm between the two copies' origins; 0 = half the paper.
  final double printColumnWidthMm;

  /// JSON grid of per-field character positions (columns/lines).
  final String? printFieldGrid;

  /// Print the weight unit with the value (`80.000 ton`) when the pre-printed
  /// form does not carry its own unit.
  final bool printWeightUnit;
  final DateTime updatedAt;
  const AppSetting({
    required this.id,
    required this.weightUnit,
    required this.billPrefix,
    required this.billStartingNumber,
    required this.billNumberDigits,
    required this.businessName,
    this.businessSubtitle,
    this.serviceText,
    this.address,
    this.phoneNumber,
    this.email,
    this.gstin,
    this.logoPath,
    required this.receiptTitle,
    required this.showSerialNumber,
    required this.showDate,
    required this.showTime,
    required this.showVehicleNumber,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showRemarks,
    required this.showFooterNote,
    this.footerNote,
    required this.printCpi,
    required this.printLpi,
    required this.printPaperWidthMm,
    required this.printPaperLengthMm,
    required this.printLeftOffsetMm,
    required this.printTopOffsetMm,
    required this.printColumnWidthMm,
    this.printFieldGrid,
    required this.printWeightUnit,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight_unit'] = Variable<String>(weightUnit);
    map['bill_prefix'] = Variable<String>(billPrefix);
    map['bill_starting_number'] = Variable<int>(billStartingNumber);
    map['bill_number_digits'] = Variable<int>(billNumberDigits);
    map['business_name'] = Variable<String>(businessName);
    if (!nullToAbsent || businessSubtitle != null) {
      map['business_subtitle'] = Variable<String>(businessSubtitle);
    }
    if (!nullToAbsent || serviceText != null) {
      map['service_text'] = Variable<String>(serviceText);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['receipt_title'] = Variable<String>(receiptTitle);
    map['show_serial_number'] = Variable<bool>(showSerialNumber);
    map['show_date'] = Variable<bool>(showDate);
    map['show_time'] = Variable<bool>(showTime);
    map['show_vehicle_number'] = Variable<bool>(showVehicleNumber);
    map['show_gross_weight'] = Variable<bool>(showGrossWeight);
    map['show_tare_weight'] = Variable<bool>(showTareWeight);
    map['show_net_weight'] = Variable<bool>(showNetWeight);
    map['show_remarks'] = Variable<bool>(showRemarks);
    map['show_footer_note'] = Variable<bool>(showFooterNote);
    if (!nullToAbsent || footerNote != null) {
      map['footer_note'] = Variable<String>(footerNote);
    }
    map['print_cpi'] = Variable<int>(printCpi);
    map['print_lpi'] = Variable<int>(printLpi);
    map['print_paper_width_mm'] = Variable<double>(printPaperWidthMm);
    map['print_paper_length_mm'] = Variable<double>(printPaperLengthMm);
    map['print_left_offset_mm'] = Variable<double>(printLeftOffsetMm);
    map['print_top_offset_mm'] = Variable<double>(printTopOffsetMm);
    map['print_column_width_mm'] = Variable<double>(printColumnWidthMm);
    if (!nullToAbsent || printFieldGrid != null) {
      map['print_field_grid'] = Variable<String>(printFieldGrid);
    }
    map['print_weight_unit'] = Variable<bool>(printWeightUnit);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      weightUnit: Value(weightUnit),
      billPrefix: Value(billPrefix),
      billStartingNumber: Value(billStartingNumber),
      billNumberDigits: Value(billNumberDigits),
      businessName: Value(businessName),
      businessSubtitle: businessSubtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(businessSubtitle),
      serviceText: serviceText == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceText),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      receiptTitle: Value(receiptTitle),
      showSerialNumber: Value(showSerialNumber),
      showDate: Value(showDate),
      showTime: Value(showTime),
      showVehicleNumber: Value(showVehicleNumber),
      showGrossWeight: Value(showGrossWeight),
      showTareWeight: Value(showTareWeight),
      showNetWeight: Value(showNetWeight),
      showRemarks: Value(showRemarks),
      showFooterNote: Value(showFooterNote),
      footerNote: footerNote == null && nullToAbsent
          ? const Value.absent()
          : Value(footerNote),
      printCpi: Value(printCpi),
      printLpi: Value(printLpi),
      printPaperWidthMm: Value(printPaperWidthMm),
      printPaperLengthMm: Value(printPaperLengthMm),
      printLeftOffsetMm: Value(printLeftOffsetMm),
      printTopOffsetMm: Value(printTopOffsetMm),
      printColumnWidthMm: Value(printColumnWidthMm),
      printFieldGrid: printFieldGrid == null && nullToAbsent
          ? const Value.absent()
          : Value(printFieldGrid),
      printWeightUnit: Value(printWeightUnit),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      weightUnit: serializer.fromJson<String>(json['weightUnit']),
      billPrefix: serializer.fromJson<String>(json['billPrefix']),
      billStartingNumber: serializer.fromJson<int>(json['billStartingNumber']),
      billNumberDigits: serializer.fromJson<int>(json['billNumberDigits']),
      businessName: serializer.fromJson<String>(json['businessName']),
      businessSubtitle: serializer.fromJson<String?>(json['businessSubtitle']),
      serviceText: serializer.fromJson<String?>(json['serviceText']),
      address: serializer.fromJson<String?>(json['address']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      email: serializer.fromJson<String?>(json['email']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      receiptTitle: serializer.fromJson<String>(json['receiptTitle']),
      showSerialNumber: serializer.fromJson<bool>(json['showSerialNumber']),
      showDate: serializer.fromJson<bool>(json['showDate']),
      showTime: serializer.fromJson<bool>(json['showTime']),
      showVehicleNumber: serializer.fromJson<bool>(json['showVehicleNumber']),
      showGrossWeight: serializer.fromJson<bool>(json['showGrossWeight']),
      showTareWeight: serializer.fromJson<bool>(json['showTareWeight']),
      showNetWeight: serializer.fromJson<bool>(json['showNetWeight']),
      showRemarks: serializer.fromJson<bool>(json['showRemarks']),
      showFooterNote: serializer.fromJson<bool>(json['showFooterNote']),
      footerNote: serializer.fromJson<String?>(json['footerNote']),
      printCpi: serializer.fromJson<int>(json['printCpi']),
      printLpi: serializer.fromJson<int>(json['printLpi']),
      printPaperWidthMm: serializer.fromJson<double>(json['printPaperWidthMm']),
      printPaperLengthMm: serializer.fromJson<double>(
        json['printPaperLengthMm'],
      ),
      printLeftOffsetMm: serializer.fromJson<double>(json['printLeftOffsetMm']),
      printTopOffsetMm: serializer.fromJson<double>(json['printTopOffsetMm']),
      printColumnWidthMm: serializer.fromJson<double>(
        json['printColumnWidthMm'],
      ),
      printFieldGrid: serializer.fromJson<String?>(json['printFieldGrid']),
      printWeightUnit: serializer.fromJson<bool>(json['printWeightUnit']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightUnit': serializer.toJson<String>(weightUnit),
      'billPrefix': serializer.toJson<String>(billPrefix),
      'billStartingNumber': serializer.toJson<int>(billStartingNumber),
      'billNumberDigits': serializer.toJson<int>(billNumberDigits),
      'businessName': serializer.toJson<String>(businessName),
      'businessSubtitle': serializer.toJson<String?>(businessSubtitle),
      'serviceText': serializer.toJson<String?>(serviceText),
      'address': serializer.toJson<String?>(address),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'email': serializer.toJson<String?>(email),
      'gstin': serializer.toJson<String?>(gstin),
      'logoPath': serializer.toJson<String?>(logoPath),
      'receiptTitle': serializer.toJson<String>(receiptTitle),
      'showSerialNumber': serializer.toJson<bool>(showSerialNumber),
      'showDate': serializer.toJson<bool>(showDate),
      'showTime': serializer.toJson<bool>(showTime),
      'showVehicleNumber': serializer.toJson<bool>(showVehicleNumber),
      'showGrossWeight': serializer.toJson<bool>(showGrossWeight),
      'showTareWeight': serializer.toJson<bool>(showTareWeight),
      'showNetWeight': serializer.toJson<bool>(showNetWeight),
      'showRemarks': serializer.toJson<bool>(showRemarks),
      'showFooterNote': serializer.toJson<bool>(showFooterNote),
      'footerNote': serializer.toJson<String?>(footerNote),
      'printCpi': serializer.toJson<int>(printCpi),
      'printLpi': serializer.toJson<int>(printLpi),
      'printPaperWidthMm': serializer.toJson<double>(printPaperWidthMm),
      'printPaperLengthMm': serializer.toJson<double>(printPaperLengthMm),
      'printLeftOffsetMm': serializer.toJson<double>(printLeftOffsetMm),
      'printTopOffsetMm': serializer.toJson<double>(printTopOffsetMm),
      'printColumnWidthMm': serializer.toJson<double>(printColumnWidthMm),
      'printFieldGrid': serializer.toJson<String?>(printFieldGrid),
      'printWeightUnit': serializer.toJson<bool>(printWeightUnit),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    int? id,
    String? weightUnit,
    String? billPrefix,
    int? billStartingNumber,
    int? billNumberDigits,
    String? businessName,
    Value<String?> businessSubtitle = const Value.absent(),
    Value<String?> serviceText = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> logoPath = const Value.absent(),
    String? receiptTitle,
    bool? showSerialNumber,
    bool? showDate,
    bool? showTime,
    bool? showVehicleNumber,
    bool? showGrossWeight,
    bool? showTareWeight,
    bool? showNetWeight,
    bool? showRemarks,
    bool? showFooterNote,
    Value<String?> footerNote = const Value.absent(),
    int? printCpi,
    int? printLpi,
    double? printPaperWidthMm,
    double? printPaperLengthMm,
    double? printLeftOffsetMm,
    double? printTopOffsetMm,
    double? printColumnWidthMm,
    Value<String?> printFieldGrid = const Value.absent(),
    bool? printWeightUnit,
    DateTime? updatedAt,
  }) => AppSetting(
    id: id ?? this.id,
    weightUnit: weightUnit ?? this.weightUnit,
    billPrefix: billPrefix ?? this.billPrefix,
    billStartingNumber: billStartingNumber ?? this.billStartingNumber,
    billNumberDigits: billNumberDigits ?? this.billNumberDigits,
    businessName: businessName ?? this.businessName,
    businessSubtitle: businessSubtitle.present
        ? businessSubtitle.value
        : this.businessSubtitle,
    serviceText: serviceText.present ? serviceText.value : this.serviceText,
    address: address.present ? address.value : this.address,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    email: email.present ? email.value : this.email,
    gstin: gstin.present ? gstin.value : this.gstin,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    receiptTitle: receiptTitle ?? this.receiptTitle,
    showSerialNumber: showSerialNumber ?? this.showSerialNumber,
    showDate: showDate ?? this.showDate,
    showTime: showTime ?? this.showTime,
    showVehicleNumber: showVehicleNumber ?? this.showVehicleNumber,
    showGrossWeight: showGrossWeight ?? this.showGrossWeight,
    showTareWeight: showTareWeight ?? this.showTareWeight,
    showNetWeight: showNetWeight ?? this.showNetWeight,
    showRemarks: showRemarks ?? this.showRemarks,
    showFooterNote: showFooterNote ?? this.showFooterNote,
    footerNote: footerNote.present ? footerNote.value : this.footerNote,
    printCpi: printCpi ?? this.printCpi,
    printLpi: printLpi ?? this.printLpi,
    printPaperWidthMm: printPaperWidthMm ?? this.printPaperWidthMm,
    printPaperLengthMm: printPaperLengthMm ?? this.printPaperLengthMm,
    printLeftOffsetMm: printLeftOffsetMm ?? this.printLeftOffsetMm,
    printTopOffsetMm: printTopOffsetMm ?? this.printTopOffsetMm,
    printColumnWidthMm: printColumnWidthMm ?? this.printColumnWidthMm,
    printFieldGrid: printFieldGrid.present
        ? printFieldGrid.value
        : this.printFieldGrid,
    printWeightUnit: printWeightUnit ?? this.printWeightUnit,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      billPrefix: data.billPrefix.present
          ? data.billPrefix.value
          : this.billPrefix,
      billStartingNumber: data.billStartingNumber.present
          ? data.billStartingNumber.value
          : this.billStartingNumber,
      billNumberDigits: data.billNumberDigits.present
          ? data.billNumberDigits.value
          : this.billNumberDigits,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      businessSubtitle: data.businessSubtitle.present
          ? data.businessSubtitle.value
          : this.businessSubtitle,
      serviceText: data.serviceText.present
          ? data.serviceText.value
          : this.serviceText,
      address: data.address.present ? data.address.value : this.address,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      email: data.email.present ? data.email.value : this.email,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      receiptTitle: data.receiptTitle.present
          ? data.receiptTitle.value
          : this.receiptTitle,
      showSerialNumber: data.showSerialNumber.present
          ? data.showSerialNumber.value
          : this.showSerialNumber,
      showDate: data.showDate.present ? data.showDate.value : this.showDate,
      showTime: data.showTime.present ? data.showTime.value : this.showTime,
      showVehicleNumber: data.showVehicleNumber.present
          ? data.showVehicleNumber.value
          : this.showVehicleNumber,
      showGrossWeight: data.showGrossWeight.present
          ? data.showGrossWeight.value
          : this.showGrossWeight,
      showTareWeight: data.showTareWeight.present
          ? data.showTareWeight.value
          : this.showTareWeight,
      showNetWeight: data.showNetWeight.present
          ? data.showNetWeight.value
          : this.showNetWeight,
      showRemarks: data.showRemarks.present
          ? data.showRemarks.value
          : this.showRemarks,
      showFooterNote: data.showFooterNote.present
          ? data.showFooterNote.value
          : this.showFooterNote,
      footerNote: data.footerNote.present
          ? data.footerNote.value
          : this.footerNote,
      printCpi: data.printCpi.present ? data.printCpi.value : this.printCpi,
      printLpi: data.printLpi.present ? data.printLpi.value : this.printLpi,
      printPaperWidthMm: data.printPaperWidthMm.present
          ? data.printPaperWidthMm.value
          : this.printPaperWidthMm,
      printPaperLengthMm: data.printPaperLengthMm.present
          ? data.printPaperLengthMm.value
          : this.printPaperLengthMm,
      printLeftOffsetMm: data.printLeftOffsetMm.present
          ? data.printLeftOffsetMm.value
          : this.printLeftOffsetMm,
      printTopOffsetMm: data.printTopOffsetMm.present
          ? data.printTopOffsetMm.value
          : this.printTopOffsetMm,
      printColumnWidthMm: data.printColumnWidthMm.present
          ? data.printColumnWidthMm.value
          : this.printColumnWidthMm,
      printFieldGrid: data.printFieldGrid.present
          ? data.printFieldGrid.value
          : this.printFieldGrid,
      printWeightUnit: data.printWeightUnit.present
          ? data.printWeightUnit.value
          : this.printWeightUnit,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('billPrefix: $billPrefix, ')
          ..write('billStartingNumber: $billStartingNumber, ')
          ..write('billNumberDigits: $billNumberDigits, ')
          ..write('businessName: $businessName, ')
          ..write('businessSubtitle: $businessSubtitle, ')
          ..write('serviceText: $serviceText, ')
          ..write('address: $address, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('gstin: $gstin, ')
          ..write('logoPath: $logoPath, ')
          ..write('receiptTitle: $receiptTitle, ')
          ..write('showSerialNumber: $showSerialNumber, ')
          ..write('showDate: $showDate, ')
          ..write('showTime: $showTime, ')
          ..write('showVehicleNumber: $showVehicleNumber, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showRemarks: $showRemarks, ')
          ..write('showFooterNote: $showFooterNote, ')
          ..write('footerNote: $footerNote, ')
          ..write('printCpi: $printCpi, ')
          ..write('printLpi: $printLpi, ')
          ..write('printPaperWidthMm: $printPaperWidthMm, ')
          ..write('printPaperLengthMm: $printPaperLengthMm, ')
          ..write('printLeftOffsetMm: $printLeftOffsetMm, ')
          ..write('printTopOffsetMm: $printTopOffsetMm, ')
          ..write('printColumnWidthMm: $printColumnWidthMm, ')
          ..write('printFieldGrid: $printFieldGrid, ')
          ..write('printWeightUnit: $printWeightUnit, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    weightUnit,
    billPrefix,
    billStartingNumber,
    billNumberDigits,
    businessName,
    businessSubtitle,
    serviceText,
    address,
    phoneNumber,
    email,
    gstin,
    logoPath,
    receiptTitle,
    showSerialNumber,
    showDate,
    showTime,
    showVehicleNumber,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showRemarks,
    showFooterNote,
    footerNote,
    printCpi,
    printLpi,
    printPaperWidthMm,
    printPaperLengthMm,
    printLeftOffsetMm,
    printTopOffsetMm,
    printColumnWidthMm,
    printFieldGrid,
    printWeightUnit,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.weightUnit == this.weightUnit &&
          other.billPrefix == this.billPrefix &&
          other.billStartingNumber == this.billStartingNumber &&
          other.billNumberDigits == this.billNumberDigits &&
          other.businessName == this.businessName &&
          other.businessSubtitle == this.businessSubtitle &&
          other.serviceText == this.serviceText &&
          other.address == this.address &&
          other.phoneNumber == this.phoneNumber &&
          other.email == this.email &&
          other.gstin == this.gstin &&
          other.logoPath == this.logoPath &&
          other.receiptTitle == this.receiptTitle &&
          other.showSerialNumber == this.showSerialNumber &&
          other.showDate == this.showDate &&
          other.showTime == this.showTime &&
          other.showVehicleNumber == this.showVehicleNumber &&
          other.showGrossWeight == this.showGrossWeight &&
          other.showTareWeight == this.showTareWeight &&
          other.showNetWeight == this.showNetWeight &&
          other.showRemarks == this.showRemarks &&
          other.showFooterNote == this.showFooterNote &&
          other.footerNote == this.footerNote &&
          other.printCpi == this.printCpi &&
          other.printLpi == this.printLpi &&
          other.printPaperWidthMm == this.printPaperWidthMm &&
          other.printPaperLengthMm == this.printPaperLengthMm &&
          other.printLeftOffsetMm == this.printLeftOffsetMm &&
          other.printTopOffsetMm == this.printTopOffsetMm &&
          other.printColumnWidthMm == this.printColumnWidthMm &&
          other.printFieldGrid == this.printFieldGrid &&
          other.printWeightUnit == this.printWeightUnit &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> weightUnit;
  final Value<String> billPrefix;
  final Value<int> billStartingNumber;
  final Value<int> billNumberDigits;
  final Value<String> businessName;
  final Value<String?> businessSubtitle;
  final Value<String?> serviceText;
  final Value<String?> address;
  final Value<String?> phoneNumber;
  final Value<String?> email;
  final Value<String?> gstin;
  final Value<String?> logoPath;
  final Value<String> receiptTitle;
  final Value<bool> showSerialNumber;
  final Value<bool> showDate;
  final Value<bool> showTime;
  final Value<bool> showVehicleNumber;
  final Value<bool> showGrossWeight;
  final Value<bool> showTareWeight;
  final Value<bool> showNetWeight;
  final Value<bool> showRemarks;
  final Value<bool> showFooterNote;
  final Value<String?> footerNote;
  final Value<int> printCpi;
  final Value<int> printLpi;
  final Value<double> printPaperWidthMm;
  final Value<double> printPaperLengthMm;
  final Value<double> printLeftOffsetMm;
  final Value<double> printTopOffsetMm;
  final Value<double> printColumnWidthMm;
  final Value<String?> printFieldGrid;
  final Value<bool> printWeightUnit;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.billPrefix = const Value.absent(),
    this.billStartingNumber = const Value.absent(),
    this.billNumberDigits = const Value.absent(),
    this.businessName = const Value.absent(),
    this.businessSubtitle = const Value.absent(),
    this.serviceText = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.gstin = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.receiptTitle = const Value.absent(),
    this.showSerialNumber = const Value.absent(),
    this.showDate = const Value.absent(),
    this.showTime = const Value.absent(),
    this.showVehicleNumber = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showRemarks = const Value.absent(),
    this.showFooterNote = const Value.absent(),
    this.footerNote = const Value.absent(),
    this.printCpi = const Value.absent(),
    this.printLpi = const Value.absent(),
    this.printPaperWidthMm = const Value.absent(),
    this.printPaperLengthMm = const Value.absent(),
    this.printLeftOffsetMm = const Value.absent(),
    this.printTopOffsetMm = const Value.absent(),
    this.printColumnWidthMm = const Value.absent(),
    this.printFieldGrid = const Value.absent(),
    this.printWeightUnit = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.billPrefix = const Value.absent(),
    this.billStartingNumber = const Value.absent(),
    this.billNumberDigits = const Value.absent(),
    this.businessName = const Value.absent(),
    this.businessSubtitle = const Value.absent(),
    this.serviceText = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.gstin = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.receiptTitle = const Value.absent(),
    this.showSerialNumber = const Value.absent(),
    this.showDate = const Value.absent(),
    this.showTime = const Value.absent(),
    this.showVehicleNumber = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showRemarks = const Value.absent(),
    this.showFooterNote = const Value.absent(),
    this.footerNote = const Value.absent(),
    this.printCpi = const Value.absent(),
    this.printLpi = const Value.absent(),
    this.printPaperWidthMm = const Value.absent(),
    this.printPaperLengthMm = const Value.absent(),
    this.printLeftOffsetMm = const Value.absent(),
    this.printTopOffsetMm = const Value.absent(),
    this.printColumnWidthMm = const Value.absent(),
    this.printFieldGrid = const Value.absent(),
    this.printWeightUnit = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? weightUnit,
    Expression<String>? billPrefix,
    Expression<int>? billStartingNumber,
    Expression<int>? billNumberDigits,
    Expression<String>? businessName,
    Expression<String>? businessSubtitle,
    Expression<String>? serviceText,
    Expression<String>? address,
    Expression<String>? phoneNumber,
    Expression<String>? email,
    Expression<String>? gstin,
    Expression<String>? logoPath,
    Expression<String>? receiptTitle,
    Expression<bool>? showSerialNumber,
    Expression<bool>? showDate,
    Expression<bool>? showTime,
    Expression<bool>? showVehicleNumber,
    Expression<bool>? showGrossWeight,
    Expression<bool>? showTareWeight,
    Expression<bool>? showNetWeight,
    Expression<bool>? showRemarks,
    Expression<bool>? showFooterNote,
    Expression<String>? footerNote,
    Expression<int>? printCpi,
    Expression<int>? printLpi,
    Expression<double>? printPaperWidthMm,
    Expression<double>? printPaperLengthMm,
    Expression<double>? printLeftOffsetMm,
    Expression<double>? printTopOffsetMm,
    Expression<double>? printColumnWidthMm,
    Expression<String>? printFieldGrid,
    Expression<bool>? printWeightUnit,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (billPrefix != null) 'bill_prefix': billPrefix,
      if (billStartingNumber != null)
        'bill_starting_number': billStartingNumber,
      if (billNumberDigits != null) 'bill_number_digits': billNumberDigits,
      if (businessName != null) 'business_name': businessName,
      if (businessSubtitle != null) 'business_subtitle': businessSubtitle,
      if (serviceText != null) 'service_text': serviceText,
      if (address != null) 'address': address,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (gstin != null) 'gstin': gstin,
      if (logoPath != null) 'logo_path': logoPath,
      if (receiptTitle != null) 'receipt_title': receiptTitle,
      if (showSerialNumber != null) 'show_serial_number': showSerialNumber,
      if (showDate != null) 'show_date': showDate,
      if (showTime != null) 'show_time': showTime,
      if (showVehicleNumber != null) 'show_vehicle_number': showVehicleNumber,
      if (showGrossWeight != null) 'show_gross_weight': showGrossWeight,
      if (showTareWeight != null) 'show_tare_weight': showTareWeight,
      if (showNetWeight != null) 'show_net_weight': showNetWeight,
      if (showRemarks != null) 'show_remarks': showRemarks,
      if (showFooterNote != null) 'show_footer_note': showFooterNote,
      if (footerNote != null) 'footer_note': footerNote,
      if (printCpi != null) 'print_cpi': printCpi,
      if (printLpi != null) 'print_lpi': printLpi,
      if (printPaperWidthMm != null) 'print_paper_width_mm': printPaperWidthMm,
      if (printPaperLengthMm != null)
        'print_paper_length_mm': printPaperLengthMm,
      if (printLeftOffsetMm != null) 'print_left_offset_mm': printLeftOffsetMm,
      if (printTopOffsetMm != null) 'print_top_offset_mm': printTopOffsetMm,
      if (printColumnWidthMm != null)
        'print_column_width_mm': printColumnWidthMm,
      if (printFieldGrid != null) 'print_field_grid': printFieldGrid,
      if (printWeightUnit != null) 'print_weight_unit': printWeightUnit,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? weightUnit,
    Value<String>? billPrefix,
    Value<int>? billStartingNumber,
    Value<int>? billNumberDigits,
    Value<String>? businessName,
    Value<String?>? businessSubtitle,
    Value<String?>? serviceText,
    Value<String?>? address,
    Value<String?>? phoneNumber,
    Value<String?>? email,
    Value<String?>? gstin,
    Value<String?>? logoPath,
    Value<String>? receiptTitle,
    Value<bool>? showSerialNumber,
    Value<bool>? showDate,
    Value<bool>? showTime,
    Value<bool>? showVehicleNumber,
    Value<bool>? showGrossWeight,
    Value<bool>? showTareWeight,
    Value<bool>? showNetWeight,
    Value<bool>? showRemarks,
    Value<bool>? showFooterNote,
    Value<String?>? footerNote,
    Value<int>? printCpi,
    Value<int>? printLpi,
    Value<double>? printPaperWidthMm,
    Value<double>? printPaperLengthMm,
    Value<double>? printLeftOffsetMm,
    Value<double>? printTopOffsetMm,
    Value<double>? printColumnWidthMm,
    Value<String?>? printFieldGrid,
    Value<bool>? printWeightUnit,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      weightUnit: weightUnit ?? this.weightUnit,
      billPrefix: billPrefix ?? this.billPrefix,
      billStartingNumber: billStartingNumber ?? this.billStartingNumber,
      billNumberDigits: billNumberDigits ?? this.billNumberDigits,
      businessName: businessName ?? this.businessName,
      businessSubtitle: businessSubtitle ?? this.businessSubtitle,
      serviceText: serviceText ?? this.serviceText,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      logoPath: logoPath ?? this.logoPath,
      receiptTitle: receiptTitle ?? this.receiptTitle,
      showSerialNumber: showSerialNumber ?? this.showSerialNumber,
      showDate: showDate ?? this.showDate,
      showTime: showTime ?? this.showTime,
      showVehicleNumber: showVehicleNumber ?? this.showVehicleNumber,
      showGrossWeight: showGrossWeight ?? this.showGrossWeight,
      showTareWeight: showTareWeight ?? this.showTareWeight,
      showNetWeight: showNetWeight ?? this.showNetWeight,
      showRemarks: showRemarks ?? this.showRemarks,
      showFooterNote: showFooterNote ?? this.showFooterNote,
      footerNote: footerNote ?? this.footerNote,
      printCpi: printCpi ?? this.printCpi,
      printLpi: printLpi ?? this.printLpi,
      printPaperWidthMm: printPaperWidthMm ?? this.printPaperWidthMm,
      printPaperLengthMm: printPaperLengthMm ?? this.printPaperLengthMm,
      printLeftOffsetMm: printLeftOffsetMm ?? this.printLeftOffsetMm,
      printTopOffsetMm: printTopOffsetMm ?? this.printTopOffsetMm,
      printColumnWidthMm: printColumnWidthMm ?? this.printColumnWidthMm,
      printFieldGrid: printFieldGrid ?? this.printFieldGrid,
      printWeightUnit: printWeightUnit ?? this.printWeightUnit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(weightUnit.value);
    }
    if (billPrefix.present) {
      map['bill_prefix'] = Variable<String>(billPrefix.value);
    }
    if (billStartingNumber.present) {
      map['bill_starting_number'] = Variable<int>(billStartingNumber.value);
    }
    if (billNumberDigits.present) {
      map['bill_number_digits'] = Variable<int>(billNumberDigits.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (businessSubtitle.present) {
      map['business_subtitle'] = Variable<String>(businessSubtitle.value);
    }
    if (serviceText.present) {
      map['service_text'] = Variable<String>(serviceText.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (receiptTitle.present) {
      map['receipt_title'] = Variable<String>(receiptTitle.value);
    }
    if (showSerialNumber.present) {
      map['show_serial_number'] = Variable<bool>(showSerialNumber.value);
    }
    if (showDate.present) {
      map['show_date'] = Variable<bool>(showDate.value);
    }
    if (showTime.present) {
      map['show_time'] = Variable<bool>(showTime.value);
    }
    if (showVehicleNumber.present) {
      map['show_vehicle_number'] = Variable<bool>(showVehicleNumber.value);
    }
    if (showGrossWeight.present) {
      map['show_gross_weight'] = Variable<bool>(showGrossWeight.value);
    }
    if (showTareWeight.present) {
      map['show_tare_weight'] = Variable<bool>(showTareWeight.value);
    }
    if (showNetWeight.present) {
      map['show_net_weight'] = Variable<bool>(showNetWeight.value);
    }
    if (showRemarks.present) {
      map['show_remarks'] = Variable<bool>(showRemarks.value);
    }
    if (showFooterNote.present) {
      map['show_footer_note'] = Variable<bool>(showFooterNote.value);
    }
    if (footerNote.present) {
      map['footer_note'] = Variable<String>(footerNote.value);
    }
    if (printCpi.present) {
      map['print_cpi'] = Variable<int>(printCpi.value);
    }
    if (printLpi.present) {
      map['print_lpi'] = Variable<int>(printLpi.value);
    }
    if (printPaperWidthMm.present) {
      map['print_paper_width_mm'] = Variable<double>(printPaperWidthMm.value);
    }
    if (printPaperLengthMm.present) {
      map['print_paper_length_mm'] = Variable<double>(printPaperLengthMm.value);
    }
    if (printLeftOffsetMm.present) {
      map['print_left_offset_mm'] = Variable<double>(printLeftOffsetMm.value);
    }
    if (printTopOffsetMm.present) {
      map['print_top_offset_mm'] = Variable<double>(printTopOffsetMm.value);
    }
    if (printColumnWidthMm.present) {
      map['print_column_width_mm'] = Variable<double>(printColumnWidthMm.value);
    }
    if (printFieldGrid.present) {
      map['print_field_grid'] = Variable<String>(printFieldGrid.value);
    }
    if (printWeightUnit.present) {
      map['print_weight_unit'] = Variable<bool>(printWeightUnit.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('billPrefix: $billPrefix, ')
          ..write('billStartingNumber: $billStartingNumber, ')
          ..write('billNumberDigits: $billNumberDigits, ')
          ..write('businessName: $businessName, ')
          ..write('businessSubtitle: $businessSubtitle, ')
          ..write('serviceText: $serviceText, ')
          ..write('address: $address, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('gstin: $gstin, ')
          ..write('logoPath: $logoPath, ')
          ..write('receiptTitle: $receiptTitle, ')
          ..write('showSerialNumber: $showSerialNumber, ')
          ..write('showDate: $showDate, ')
          ..write('showTime: $showTime, ')
          ..write('showVehicleNumber: $showVehicleNumber, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showRemarks: $showRemarks, ')
          ..write('showFooterNote: $showFooterNote, ')
          ..write('footerNote: $footerNote, ')
          ..write('printCpi: $printCpi, ')
          ..write('printLpi: $printLpi, ')
          ..write('printPaperWidthMm: $printPaperWidthMm, ')
          ..write('printPaperLengthMm: $printPaperLengthMm, ')
          ..write('printLeftOffsetMm: $printLeftOffsetMm, ')
          ..write('printTopOffsetMm: $printTopOffsetMm, ')
          ..write('printColumnWidthMm: $printColumnWidthMm, ')
          ..write('printFieldGrid: $printFieldGrid, ')
          ..write('printWeightUnit: $printWeightUnit, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScaleSettingsTable extends ScaleSettings
    with TableInfo<$ScaleSettingsTable, ScaleSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScaleSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<String> port = GeneratedColumn<String>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COM3'),
  );
  static const VerificationMeta _baudRateMeta = const VerificationMeta(
    'baudRate',
  );
  @override
  late final GeneratedColumn<int> baudRate = GeneratedColumn<int>(
    'baud_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9600),
  );
  static const VerificationMeta _dataBitsMeta = const VerificationMeta(
    'dataBits',
  );
  @override
  late final GeneratedColumn<int> dataBits = GeneratedColumn<int>(
    'data_bits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _parityMeta = const VerificationMeta('parity');
  @override
  late final GeneratedColumn<int> parity = GeneratedColumn<int>(
    'parity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stopBitsMeta = const VerificationMeta(
    'stopBits',
  );
  @override
  late final GeneratedColumn<int> stopBits = GeneratedColumn<int>(
    'stop_bits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unconfigured'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    port,
    baudRate,
    dataBits,
    parity,
    stopBits,
    protocol,
    enabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scale_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScaleSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('baud_rate')) {
      context.handle(
        _baudRateMeta,
        baudRate.isAcceptableOrUnknown(data['baud_rate']!, _baudRateMeta),
      );
    }
    if (data.containsKey('data_bits')) {
      context.handle(
        _dataBitsMeta,
        dataBits.isAcceptableOrUnknown(data['data_bits']!, _dataBitsMeta),
      );
    }
    if (data.containsKey('parity')) {
      context.handle(
        _parityMeta,
        parity.isAcceptableOrUnknown(data['parity']!, _parityMeta),
      );
    }
    if (data.containsKey('stop_bits')) {
      context.handle(
        _stopBitsMeta,
        stopBits.isAcceptableOrUnknown(data['stop_bits']!, _stopBitsMeta),
      );
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScaleSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScaleSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}port'],
      )!,
      baudRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baud_rate'],
      )!,
      dataBits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}data_bits'],
      )!,
      parity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parity'],
      )!,
      stopBits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stop_bits'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScaleSettingsTable createAlias(String alias) {
    return $ScaleSettingsTable(attachedDatabase, alias);
  }
}

class ScaleSetting extends DataClass implements Insertable<ScaleSetting> {
  final int id;
  final String port;
  final int baudRate;
  final int dataBits;
  final int parity;
  final int stopBits;
  final String protocol;
  final bool enabled;
  final DateTime updatedAt;
  const ScaleSetting({
    required this.id,
    required this.port,
    required this.baudRate,
    required this.dataBits,
    required this.parity,
    required this.stopBits,
    required this.protocol,
    required this.enabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['port'] = Variable<String>(port);
    map['baud_rate'] = Variable<int>(baudRate);
    map['data_bits'] = Variable<int>(dataBits);
    map['parity'] = Variable<int>(parity);
    map['stop_bits'] = Variable<int>(stopBits);
    map['protocol'] = Variable<String>(protocol);
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScaleSettingsCompanion toCompanion(bool nullToAbsent) {
    return ScaleSettingsCompanion(
      id: Value(id),
      port: Value(port),
      baudRate: Value(baudRate),
      dataBits: Value(dataBits),
      parity: Value(parity),
      stopBits: Value(stopBits),
      protocol: Value(protocol),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScaleSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScaleSetting(
      id: serializer.fromJson<int>(json['id']),
      port: serializer.fromJson<String>(json['port']),
      baudRate: serializer.fromJson<int>(json['baudRate']),
      dataBits: serializer.fromJson<int>(json['dataBits']),
      parity: serializer.fromJson<int>(json['parity']),
      stopBits: serializer.fromJson<int>(json['stopBits']),
      protocol: serializer.fromJson<String>(json['protocol']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'port': serializer.toJson<String>(port),
      'baudRate': serializer.toJson<int>(baudRate),
      'dataBits': serializer.toJson<int>(dataBits),
      'parity': serializer.toJson<int>(parity),
      'stopBits': serializer.toJson<int>(stopBits),
      'protocol': serializer.toJson<String>(protocol),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScaleSetting copyWith({
    int? id,
    String? port,
    int? baudRate,
    int? dataBits,
    int? parity,
    int? stopBits,
    String? protocol,
    bool? enabled,
    DateTime? updatedAt,
  }) => ScaleSetting(
    id: id ?? this.id,
    port: port ?? this.port,
    baudRate: baudRate ?? this.baudRate,
    dataBits: dataBits ?? this.dataBits,
    parity: parity ?? this.parity,
    stopBits: stopBits ?? this.stopBits,
    protocol: protocol ?? this.protocol,
    enabled: enabled ?? this.enabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScaleSetting copyWithCompanion(ScaleSettingsCompanion data) {
    return ScaleSetting(
      id: data.id.present ? data.id.value : this.id,
      port: data.port.present ? data.port.value : this.port,
      baudRate: data.baudRate.present ? data.baudRate.value : this.baudRate,
      dataBits: data.dataBits.present ? data.dataBits.value : this.dataBits,
      parity: data.parity.present ? data.parity.value : this.parity,
      stopBits: data.stopBits.present ? data.stopBits.value : this.stopBits,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScaleSetting(')
          ..write('id: $id, ')
          ..write('port: $port, ')
          ..write('baudRate: $baudRate, ')
          ..write('dataBits: $dataBits, ')
          ..write('parity: $parity, ')
          ..write('stopBits: $stopBits, ')
          ..write('protocol: $protocol, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    port,
    baudRate,
    dataBits,
    parity,
    stopBits,
    protocol,
    enabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScaleSetting &&
          other.id == this.id &&
          other.port == this.port &&
          other.baudRate == this.baudRate &&
          other.dataBits == this.dataBits &&
          other.parity == this.parity &&
          other.stopBits == this.stopBits &&
          other.protocol == this.protocol &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt);
}

class ScaleSettingsCompanion extends UpdateCompanion<ScaleSetting> {
  final Value<int> id;
  final Value<String> port;
  final Value<int> baudRate;
  final Value<int> dataBits;
  final Value<int> parity;
  final Value<int> stopBits;
  final Value<String> protocol;
  final Value<bool> enabled;
  final Value<DateTime> updatedAt;
  const ScaleSettingsCompanion({
    this.id = const Value.absent(),
    this.port = const Value.absent(),
    this.baudRate = const Value.absent(),
    this.dataBits = const Value.absent(),
    this.parity = const Value.absent(),
    this.stopBits = const Value.absent(),
    this.protocol = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScaleSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.port = const Value.absent(),
    this.baudRate = const Value.absent(),
    this.dataBits = const Value.absent(),
    this.parity = const Value.absent(),
    this.stopBits = const Value.absent(),
    this.protocol = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ScaleSetting> custom({
    Expression<int>? id,
    Expression<String>? port,
    Expression<int>? baudRate,
    Expression<int>? dataBits,
    Expression<int>? parity,
    Expression<int>? stopBits,
    Expression<String>? protocol,
    Expression<bool>? enabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (port != null) 'port': port,
      if (baudRate != null) 'baud_rate': baudRate,
      if (dataBits != null) 'data_bits': dataBits,
      if (parity != null) 'parity': parity,
      if (stopBits != null) 'stop_bits': stopBits,
      if (protocol != null) 'protocol': protocol,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScaleSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? port,
    Value<int>? baudRate,
    Value<int>? dataBits,
    Value<int>? parity,
    Value<int>? stopBits,
    Value<String>? protocol,
    Value<bool>? enabled,
    Value<DateTime>? updatedAt,
  }) {
    return ScaleSettingsCompanion(
      id: id ?? this.id,
      port: port ?? this.port,
      baudRate: baudRate ?? this.baudRate,
      dataBits: dataBits ?? this.dataBits,
      parity: parity ?? this.parity,
      stopBits: stopBits ?? this.stopBits,
      protocol: protocol ?? this.protocol,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (port.present) {
      map['port'] = Variable<String>(port.value);
    }
    if (baudRate.present) {
      map['baud_rate'] = Variable<int>(baudRate.value);
    }
    if (dataBits.present) {
      map['data_bits'] = Variable<int>(dataBits.value);
    }
    if (parity.present) {
      map['parity'] = Variable<int>(parity.value);
    }
    if (stopBits.present) {
      map['stop_bits'] = Variable<int>(stopBits.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScaleSettingsCompanion(')
          ..write('id: $id, ')
          ..write('port: $port, ')
          ..write('baudRate: $baudRate, ')
          ..write('dataBits: $dataBits, ')
          ..write('parity: $parity, ')
          ..write('stopBits: $stopBits, ')
          ..write('protocol: $protocol, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $WeighmentsTable weighments = $WeighmentsTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ScaleSettingsTable scaleSettings = $ScaleSettingsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
  late final MaterialDao materialDao = MaterialDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final ScaleSettingsDao scaleSettingsDao = ScaleSettingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    weighments,
    materials,
    appSettings,
    scaleSettings,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      required String passwordHash,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String passwordHash,
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$WeighmentsTableCreateCompanionBuilder =
    WeighmentsCompanion Function({
      Value<int> id,
      required String billNumber,
      required String vehicleNumber,
      required double firstWeightKg,
      Value<String> firstWeightType,
      Value<double?> secondWeightKg,
      Value<String?> secondWeightType,
      Value<double?> netWeightKg,
      Value<String?> material,
      Value<int?> materialId,
      Value<double?> charges,
      Value<int?> previousWeighmentId,
      Value<String?> description,
      Value<String?> remarks,
      Value<String?> mobileNumber,
      Value<String> weightUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WeighmentsTableUpdateCompanionBuilder =
    WeighmentsCompanion Function({
      Value<int> id,
      Value<String> billNumber,
      Value<String> vehicleNumber,
      Value<double> firstWeightKg,
      Value<String> firstWeightType,
      Value<double?> secondWeightKg,
      Value<String?> secondWeightType,
      Value<double?> netWeightKg,
      Value<String?> material,
      Value<int?> materialId,
      Value<double?> charges,
      Value<int?> previousWeighmentId,
      Value<String?> description,
      Value<String?> remarks,
      Value<String?> mobileNumber,
      Value<String> weightUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WeighmentsTableFilterComposer
    extends Composer<_$AppDatabase, $WeighmentsTable> {
  $$WeighmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstWeightType => $composableBuilder(
    column: $table.firstWeightType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondWeightType => $composableBuilder(
    column: $table.secondWeightType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousWeighmentId => $composableBuilder(
    column: $table.previousWeighmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeighmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeighmentsTable> {
  $$WeighmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstWeightType => $composableBuilder(
    column: $table.firstWeightType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondWeightType => $composableBuilder(
    column: $table.secondWeightType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get charges => $composableBuilder(
    column: $table.charges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousWeighmentId => $composableBuilder(
    column: $table.previousWeighmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeighmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeighmentsTable> {
  $$WeighmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstWeightType => $composableBuilder(
    column: $table.firstWeightType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondWeightType => $composableBuilder(
    column: $table.secondWeightType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<int> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get charges =>
      $composableBuilder(column: $table.charges, builder: (column) => column);

  GeneratedColumn<int> get previousWeighmentId => $composableBuilder(
    column: $table.previousWeighmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeighmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeighmentsTable,
          Weighment,
          $$WeighmentsTableFilterComposer,
          $$WeighmentsTableOrderingComposer,
          $$WeighmentsTableAnnotationComposer,
          $$WeighmentsTableCreateCompanionBuilder,
          $$WeighmentsTableUpdateCompanionBuilder,
          (
            Weighment,
            BaseReferences<_$AppDatabase, $WeighmentsTable, Weighment>,
          ),
          Weighment,
          PrefetchHooks Function()
        > {
  $$WeighmentsTableTableManager(_$AppDatabase db, $WeighmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeighmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeighmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeighmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> billNumber = const Value.absent(),
                Value<String> vehicleNumber = const Value.absent(),
                Value<double> firstWeightKg = const Value.absent(),
                Value<String> firstWeightType = const Value.absent(),
                Value<double?> secondWeightKg = const Value.absent(),
                Value<String?> secondWeightType = const Value.absent(),
                Value<double?> netWeightKg = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<int?> materialId = const Value.absent(),
                Value<double?> charges = const Value.absent(),
                Value<int?> previousWeighmentId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> mobileNumber = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion(
                id: id,
                billNumber: billNumber,
                vehicleNumber: vehicleNumber,
                firstWeightKg: firstWeightKg,
                firstWeightType: firstWeightType,
                secondWeightKg: secondWeightKg,
                secondWeightType: secondWeightType,
                netWeightKg: netWeightKg,
                material: material,
                materialId: materialId,
                charges: charges,
                previousWeighmentId: previousWeighmentId,
                description: description,
                remarks: remarks,
                mobileNumber: mobileNumber,
                weightUnit: weightUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String billNumber,
                required String vehicleNumber,
                required double firstWeightKg,
                Value<String> firstWeightType = const Value.absent(),
                Value<double?> secondWeightKg = const Value.absent(),
                Value<String?> secondWeightType = const Value.absent(),
                Value<double?> netWeightKg = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<int?> materialId = const Value.absent(),
                Value<double?> charges = const Value.absent(),
                Value<int?> previousWeighmentId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> mobileNumber = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion.insert(
                id: id,
                billNumber: billNumber,
                vehicleNumber: vehicleNumber,
                firstWeightKg: firstWeightKg,
                firstWeightType: firstWeightType,
                secondWeightKg: secondWeightKg,
                secondWeightType: secondWeightType,
                netWeightKg: netWeightKg,
                material: material,
                materialId: materialId,
                charges: charges,
                previousWeighmentId: previousWeighmentId,
                description: description,
                remarks: remarks,
                mobileNumber: mobileNumber,
                weightUnit: weightUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeighmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeighmentsTable,
      Weighment,
      $$WeighmentsTableFilterComposer,
      $$WeighmentsTableOrderingComposer,
      $$WeighmentsTableAnnotationComposer,
      $$WeighmentsTableCreateCompanionBuilder,
      $$WeighmentsTableUpdateCompanionBuilder,
      (Weighment, BaseReferences<_$AppDatabase, $WeighmentsTable, Weighment>),
      Weighment,
      PrefetchHooks Function()
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      required String name,
      required String vehicleType,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> vehicleType,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$MaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialsTable,
          Material,
          $$MaterialsTableFilterComposer,
          $$MaterialsTableOrderingComposer,
          $$MaterialsTableAnnotationComposer,
          $$MaterialsTableCreateCompanionBuilder,
          $$MaterialsTableUpdateCompanionBuilder,
          (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
          Material,
          PrefetchHooks Function()
        > {
  $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> vehicleType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                name: name,
                vehicleType: vehicleType,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String vehicleType,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                name: name,
                vehicleType: vehicleType,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialsTable,
      Material,
      $$MaterialsTableFilterComposer,
      $$MaterialsTableOrderingComposer,
      $$MaterialsTableAnnotationComposer,
      $$MaterialsTableCreateCompanionBuilder,
      $$MaterialsTableUpdateCompanionBuilder,
      (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
      Material,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> weightUnit,
      Value<String> billPrefix,
      Value<int> billStartingNumber,
      Value<int> billNumberDigits,
      Value<String> businessName,
      Value<String?> businessSubtitle,
      Value<String?> serviceText,
      Value<String?> address,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<String?> gstin,
      Value<String?> logoPath,
      Value<String> receiptTitle,
      Value<bool> showSerialNumber,
      Value<bool> showDate,
      Value<bool> showTime,
      Value<bool> showVehicleNumber,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showRemarks,
      Value<bool> showFooterNote,
      Value<String?> footerNote,
      Value<int> printCpi,
      Value<int> printLpi,
      Value<double> printPaperWidthMm,
      Value<double> printPaperLengthMm,
      Value<double> printLeftOffsetMm,
      Value<double> printTopOffsetMm,
      Value<double> printColumnWidthMm,
      Value<String?> printFieldGrid,
      Value<bool> printWeightUnit,
      Value<DateTime> updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> weightUnit,
      Value<String> billPrefix,
      Value<int> billStartingNumber,
      Value<int> billNumberDigits,
      Value<String> businessName,
      Value<String?> businessSubtitle,
      Value<String?> serviceText,
      Value<String?> address,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<String?> gstin,
      Value<String?> logoPath,
      Value<String> receiptTitle,
      Value<bool> showSerialNumber,
      Value<bool> showDate,
      Value<bool> showTime,
      Value<bool> showVehicleNumber,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showRemarks,
      Value<bool> showFooterNote,
      Value<String?> footerNote,
      Value<int> printCpi,
      Value<int> printLpi,
      Value<double> printPaperWidthMm,
      Value<double> printPaperLengthMm,
      Value<double> printLeftOffsetMm,
      Value<double> printTopOffsetMm,
      Value<double> printColumnWidthMm,
      Value<String?> printFieldGrid,
      Value<bool> printWeightUnit,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billPrefix => $composableBuilder(
    column: $table.billPrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billStartingNumber => $composableBuilder(
    column: $table.billStartingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billNumberDigits => $composableBuilder(
    column: $table.billNumberDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessSubtitle => $composableBuilder(
    column: $table.businessSubtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceText => $composableBuilder(
    column: $table.serviceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptTitle => $composableBuilder(
    column: $table.receiptTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showSerialNumber => $composableBuilder(
    column: $table.showSerialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showDate => $composableBuilder(
    column: $table.showDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showTime => $composableBuilder(
    column: $table.showTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showVehicleNumber => $composableBuilder(
    column: $table.showVehicleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showGrossWeight => $composableBuilder(
    column: $table.showGrossWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showTareWeight => $composableBuilder(
    column: $table.showTareWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showNetWeight => $composableBuilder(
    column: $table.showNetWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showRemarks => $composableBuilder(
    column: $table.showRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showFooterNote => $composableBuilder(
    column: $table.showFooterNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get footerNote => $composableBuilder(
    column: $table.footerNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get printCpi => $composableBuilder(
    column: $table.printCpi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get printLpi => $composableBuilder(
    column: $table.printLpi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get printPaperWidthMm => $composableBuilder(
    column: $table.printPaperWidthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get printPaperLengthMm => $composableBuilder(
    column: $table.printPaperLengthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get printLeftOffsetMm => $composableBuilder(
    column: $table.printLeftOffsetMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get printTopOffsetMm => $composableBuilder(
    column: $table.printTopOffsetMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get printColumnWidthMm => $composableBuilder(
    column: $table.printColumnWidthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printFieldGrid => $composableBuilder(
    column: $table.printFieldGrid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get printWeightUnit => $composableBuilder(
    column: $table.printWeightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billPrefix => $composableBuilder(
    column: $table.billPrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billStartingNumber => $composableBuilder(
    column: $table.billStartingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billNumberDigits => $composableBuilder(
    column: $table.billNumberDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessSubtitle => $composableBuilder(
    column: $table.businessSubtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceText => $composableBuilder(
    column: $table.serviceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptTitle => $composableBuilder(
    column: $table.receiptTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showSerialNumber => $composableBuilder(
    column: $table.showSerialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showDate => $composableBuilder(
    column: $table.showDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showTime => $composableBuilder(
    column: $table.showTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVehicleNumber => $composableBuilder(
    column: $table.showVehicleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showGrossWeight => $composableBuilder(
    column: $table.showGrossWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showTareWeight => $composableBuilder(
    column: $table.showTareWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showNetWeight => $composableBuilder(
    column: $table.showNetWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showRemarks => $composableBuilder(
    column: $table.showRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showFooterNote => $composableBuilder(
    column: $table.showFooterNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get footerNote => $composableBuilder(
    column: $table.footerNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get printCpi => $composableBuilder(
    column: $table.printCpi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get printLpi => $composableBuilder(
    column: $table.printLpi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get printPaperWidthMm => $composableBuilder(
    column: $table.printPaperWidthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get printPaperLengthMm => $composableBuilder(
    column: $table.printPaperLengthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get printLeftOffsetMm => $composableBuilder(
    column: $table.printLeftOffsetMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get printTopOffsetMm => $composableBuilder(
    column: $table.printTopOffsetMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get printColumnWidthMm => $composableBuilder(
    column: $table.printColumnWidthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printFieldGrid => $composableBuilder(
    column: $table.printFieldGrid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get printWeightUnit => $composableBuilder(
    column: $table.printWeightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billPrefix => $composableBuilder(
    column: $table.billPrefix,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billStartingNumber => $composableBuilder(
    column: $table.billStartingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billNumberDigits => $composableBuilder(
    column: $table.billNumberDigits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessSubtitle => $composableBuilder(
    column: $table.businessSubtitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceText => $composableBuilder(
    column: $table.serviceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get receiptTitle => $composableBuilder(
    column: $table.receiptTitle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showSerialNumber => $composableBuilder(
    column: $table.showSerialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showDate =>
      $composableBuilder(column: $table.showDate, builder: (column) => column);

  GeneratedColumn<bool> get showTime =>
      $composableBuilder(column: $table.showTime, builder: (column) => column);

  GeneratedColumn<bool> get showVehicleNumber => $composableBuilder(
    column: $table.showVehicleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showGrossWeight => $composableBuilder(
    column: $table.showGrossWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showTareWeight => $composableBuilder(
    column: $table.showTareWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showNetWeight => $composableBuilder(
    column: $table.showNetWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showRemarks => $composableBuilder(
    column: $table.showRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showFooterNote => $composableBuilder(
    column: $table.showFooterNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get footerNote => $composableBuilder(
    column: $table.footerNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get printCpi =>
      $composableBuilder(column: $table.printCpi, builder: (column) => column);

  GeneratedColumn<int> get printLpi =>
      $composableBuilder(column: $table.printLpi, builder: (column) => column);

  GeneratedColumn<double> get printPaperWidthMm => $composableBuilder(
    column: $table.printPaperWidthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get printPaperLengthMm => $composableBuilder(
    column: $table.printPaperLengthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get printLeftOffsetMm => $composableBuilder(
    column: $table.printLeftOffsetMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get printTopOffsetMm => $composableBuilder(
    column: $table.printTopOffsetMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get printColumnWidthMm => $composableBuilder(
    column: $table.printColumnWidthMm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printFieldGrid => $composableBuilder(
    column: $table.printFieldGrid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get printWeightUnit => $composableBuilder(
    column: $table.printWeightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<String> billPrefix = const Value.absent(),
                Value<int> billStartingNumber = const Value.absent(),
                Value<int> billNumberDigits = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String?> businessSubtitle = const Value.absent(),
                Value<String?> serviceText = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> receiptTitle = const Value.absent(),
                Value<bool> showSerialNumber = const Value.absent(),
                Value<bool> showDate = const Value.absent(),
                Value<bool> showTime = const Value.absent(),
                Value<bool> showVehicleNumber = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showRemarks = const Value.absent(),
                Value<bool> showFooterNote = const Value.absent(),
                Value<String?> footerNote = const Value.absent(),
                Value<int> printCpi = const Value.absent(),
                Value<int> printLpi = const Value.absent(),
                Value<double> printPaperWidthMm = const Value.absent(),
                Value<double> printPaperLengthMm = const Value.absent(),
                Value<double> printLeftOffsetMm = const Value.absent(),
                Value<double> printTopOffsetMm = const Value.absent(),
                Value<double> printColumnWidthMm = const Value.absent(),
                Value<String?> printFieldGrid = const Value.absent(),
                Value<bool> printWeightUnit = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                weightUnit: weightUnit,
                billPrefix: billPrefix,
                billStartingNumber: billStartingNumber,
                billNumberDigits: billNumberDigits,
                businessName: businessName,
                businessSubtitle: businessSubtitle,
                serviceText: serviceText,
                address: address,
                phoneNumber: phoneNumber,
                email: email,
                gstin: gstin,
                logoPath: logoPath,
                receiptTitle: receiptTitle,
                showSerialNumber: showSerialNumber,
                showDate: showDate,
                showTime: showTime,
                showVehicleNumber: showVehicleNumber,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showRemarks: showRemarks,
                showFooterNote: showFooterNote,
                footerNote: footerNote,
                printCpi: printCpi,
                printLpi: printLpi,
                printPaperWidthMm: printPaperWidthMm,
                printPaperLengthMm: printPaperLengthMm,
                printLeftOffsetMm: printLeftOffsetMm,
                printTopOffsetMm: printTopOffsetMm,
                printColumnWidthMm: printColumnWidthMm,
                printFieldGrid: printFieldGrid,
                printWeightUnit: printWeightUnit,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<String> billPrefix = const Value.absent(),
                Value<int> billStartingNumber = const Value.absent(),
                Value<int> billNumberDigits = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String?> businessSubtitle = const Value.absent(),
                Value<String?> serviceText = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> receiptTitle = const Value.absent(),
                Value<bool> showSerialNumber = const Value.absent(),
                Value<bool> showDate = const Value.absent(),
                Value<bool> showTime = const Value.absent(),
                Value<bool> showVehicleNumber = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showRemarks = const Value.absent(),
                Value<bool> showFooterNote = const Value.absent(),
                Value<String?> footerNote = const Value.absent(),
                Value<int> printCpi = const Value.absent(),
                Value<int> printLpi = const Value.absent(),
                Value<double> printPaperWidthMm = const Value.absent(),
                Value<double> printPaperLengthMm = const Value.absent(),
                Value<double> printLeftOffsetMm = const Value.absent(),
                Value<double> printTopOffsetMm = const Value.absent(),
                Value<double> printColumnWidthMm = const Value.absent(),
                Value<String?> printFieldGrid = const Value.absent(),
                Value<bool> printWeightUnit = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                weightUnit: weightUnit,
                billPrefix: billPrefix,
                billStartingNumber: billStartingNumber,
                billNumberDigits: billNumberDigits,
                businessName: businessName,
                businessSubtitle: businessSubtitle,
                serviceText: serviceText,
                address: address,
                phoneNumber: phoneNumber,
                email: email,
                gstin: gstin,
                logoPath: logoPath,
                receiptTitle: receiptTitle,
                showSerialNumber: showSerialNumber,
                showDate: showDate,
                showTime: showTime,
                showVehicleNumber: showVehicleNumber,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showRemarks: showRemarks,
                showFooterNote: showFooterNote,
                footerNote: footerNote,
                printCpi: printCpi,
                printLpi: printLpi,
                printPaperWidthMm: printPaperWidthMm,
                printPaperLengthMm: printPaperLengthMm,
                printLeftOffsetMm: printLeftOffsetMm,
                printTopOffsetMm: printTopOffsetMm,
                printColumnWidthMm: printColumnWidthMm,
                printFieldGrid: printFieldGrid,
                printWeightUnit: printWeightUnit,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ScaleSettingsTableCreateCompanionBuilder =
    ScaleSettingsCompanion Function({
      Value<int> id,
      Value<String> port,
      Value<int> baudRate,
      Value<int> dataBits,
      Value<int> parity,
      Value<int> stopBits,
      Value<String> protocol,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });
typedef $$ScaleSettingsTableUpdateCompanionBuilder =
    ScaleSettingsCompanion Function({
      Value<int> id,
      Value<String> port,
      Value<int> baudRate,
      Value<int> dataBits,
      Value<int> parity,
      Value<int> stopBits,
      Value<String> protocol,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });

class $$ScaleSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ScaleSettingsTable> {
  $$ScaleSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baudRate => $composableBuilder(
    column: $table.baudRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dataBits => $composableBuilder(
    column: $table.dataBits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parity => $composableBuilder(
    column: $table.parity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stopBits => $composableBuilder(
    column: $table.stopBits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScaleSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScaleSettingsTable> {
  $$ScaleSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baudRate => $composableBuilder(
    column: $table.baudRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataBits => $composableBuilder(
    column: $table.dataBits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parity => $composableBuilder(
    column: $table.parity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stopBits => $composableBuilder(
    column: $table.stopBits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScaleSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScaleSettingsTable> {
  $$ScaleSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<int> get baudRate =>
      $composableBuilder(column: $table.baudRate, builder: (column) => column);

  GeneratedColumn<int> get dataBits =>
      $composableBuilder(column: $table.dataBits, builder: (column) => column);

  GeneratedColumn<int> get parity =>
      $composableBuilder(column: $table.parity, builder: (column) => column);

  GeneratedColumn<int> get stopBits =>
      $composableBuilder(column: $table.stopBits, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ScaleSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScaleSettingsTable,
          ScaleSetting,
          $$ScaleSettingsTableFilterComposer,
          $$ScaleSettingsTableOrderingComposer,
          $$ScaleSettingsTableAnnotationComposer,
          $$ScaleSettingsTableCreateCompanionBuilder,
          $$ScaleSettingsTableUpdateCompanionBuilder,
          (
            ScaleSetting,
            BaseReferences<_$AppDatabase, $ScaleSettingsTable, ScaleSetting>,
          ),
          ScaleSetting,
          PrefetchHooks Function()
        > {
  $$ScaleSettingsTableTableManager(_$AppDatabase db, $ScaleSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScaleSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScaleSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScaleSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> port = const Value.absent(),
                Value<int> baudRate = const Value.absent(),
                Value<int> dataBits = const Value.absent(),
                Value<int> parity = const Value.absent(),
                Value<int> stopBits = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScaleSettingsCompanion(
                id: id,
                port: port,
                baudRate: baudRate,
                dataBits: dataBits,
                parity: parity,
                stopBits: stopBits,
                protocol: protocol,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> port = const Value.absent(),
                Value<int> baudRate = const Value.absent(),
                Value<int> dataBits = const Value.absent(),
                Value<int> parity = const Value.absent(),
                Value<int> stopBits = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ScaleSettingsCompanion.insert(
                id: id,
                port: port,
                baudRate: baudRate,
                dataBits: dataBits,
                parity: parity,
                stopBits: stopBits,
                protocol: protocol,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScaleSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScaleSettingsTable,
      ScaleSetting,
      $$ScaleSettingsTableFilterComposer,
      $$ScaleSettingsTableOrderingComposer,
      $$ScaleSettingsTableAnnotationComposer,
      $$ScaleSettingsTableCreateCompanionBuilder,
      $$ScaleSettingsTableUpdateCompanionBuilder,
      (
        ScaleSetting,
        BaseReferences<_$AppDatabase, $ScaleSettingsTable, ScaleSetting>,
      ),
      ScaleSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db, _db.weighments);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ScaleSettingsTableTableManager get scaleSettings =>
      $$ScaleSettingsTableTableManager(_db, _db.scaleSettings);
}
