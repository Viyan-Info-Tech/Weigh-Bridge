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
  final String? material;
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

class $AutoTareSettingsTable extends AutoTareSettings
    with TableInfo<$AutoTareSettingsTable, AutoTareSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutoTareSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tareDateMeta = const VerificationMeta(
    'tareDate',
  );
  @override
  late final GeneratedColumn<DateTime> tareDate = GeneratedColumn<DateTime>(
    'tare_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tareKgMeta = const VerificationMeta('tareKg');
  @override
  late final GeneratedColumn<double> tareKg = GeneratedColumn<double>(
    'tare_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    tareDate,
    tareKg,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auto_tare_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AutoTareSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tare_date')) {
      context.handle(
        _tareDateMeta,
        tareDate.isAcceptableOrUnknown(data['tare_date']!, _tareDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tareDateMeta);
    }
    if (data.containsKey('tare_kg')) {
      context.handle(
        _tareKgMeta,
        tareKg.isAcceptableOrUnknown(data['tare_kg']!, _tareKgMeta),
      );
    } else if (isInserting) {
      context.missing(_tareKgMeta);
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
  AutoTareSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutoTareSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tareDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tare_date'],
      )!,
      tareKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tare_kg'],
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
  $AutoTareSettingsTable createAlias(String alias) {
    return $AutoTareSettingsTable(attachedDatabase, alias);
  }
}

class AutoTareSetting extends DataClass implements Insertable<AutoTareSetting> {
  final int id;
  final DateTime tareDate;
  final double tareKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AutoTareSetting({
    required this.id,
    required this.tareDate,
    required this.tareKg,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tare_date'] = Variable<DateTime>(tareDate);
    map['tare_kg'] = Variable<double>(tareKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AutoTareSettingsCompanion toCompanion(bool nullToAbsent) {
    return AutoTareSettingsCompanion(
      id: Value(id),
      tareDate: Value(tareDate),
      tareKg: Value(tareKg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AutoTareSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutoTareSetting(
      id: serializer.fromJson<int>(json['id']),
      tareDate: serializer.fromJson<DateTime>(json['tareDate']),
      tareKg: serializer.fromJson<double>(json['tareKg']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tareDate': serializer.toJson<DateTime>(tareDate),
      'tareKg': serializer.toJson<double>(tareKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AutoTareSetting copyWith({
    int? id,
    DateTime? tareDate,
    double? tareKg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AutoTareSetting(
    id: id ?? this.id,
    tareDate: tareDate ?? this.tareDate,
    tareKg: tareKg ?? this.tareKg,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AutoTareSetting copyWithCompanion(AutoTareSettingsCompanion data) {
    return AutoTareSetting(
      id: data.id.present ? data.id.value : this.id,
      tareDate: data.tareDate.present ? data.tareDate.value : this.tareDate,
      tareKg: data.tareKg.present ? data.tareKg.value : this.tareKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutoTareSetting(')
          ..write('id: $id, ')
          ..write('tareDate: $tareDate, ')
          ..write('tareKg: $tareKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tareDate, tareKg, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutoTareSetting &&
          other.id == this.id &&
          other.tareDate == this.tareDate &&
          other.tareKg == this.tareKg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AutoTareSettingsCompanion extends UpdateCompanion<AutoTareSetting> {
  final Value<int> id;
  final Value<DateTime> tareDate;
  final Value<double> tareKg;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AutoTareSettingsCompanion({
    this.id = const Value.absent(),
    this.tareDate = const Value.absent(),
    this.tareKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AutoTareSettingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime tareDate,
    required double tareKg,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : tareDate = Value(tareDate),
       tareKg = Value(tareKg);
  static Insertable<AutoTareSetting> custom({
    Expression<int>? id,
    Expression<DateTime>? tareDate,
    Expression<double>? tareKg,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tareDate != null) 'tare_date': tareDate,
      if (tareKg != null) 'tare_kg': tareKg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AutoTareSettingsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? tareDate,
    Value<double>? tareKg,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AutoTareSettingsCompanion(
      id: id ?? this.id,
      tareDate: tareDate ?? this.tareDate,
      tareKg: tareKg ?? this.tareKg,
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
    if (tareDate.present) {
      map['tare_date'] = Variable<DateTime>(tareDate.value);
    }
    if (tareKg.present) {
      map['tare_kg'] = Variable<double>(tareKg.value);
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
    return (StringBuffer('AutoTareSettingsCompanion(')
          ..write('id: $id, ')
          ..write('tareDate: $tareDate, ')
          ..write('tareKg: $tareKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VehicleTareRecordsTable extends VehicleTareRecords
    with TableInfo<$VehicleTareRecordsTable, VehicleTareRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleTareRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tareKgMeta = const VerificationMeta('tareKg');
  @override
  late final GeneratedColumn<double> tareKg = GeneratedColumn<double>(
    'tare_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    vehicleNumber,
    tareKg,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_tare_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleTareRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('tare_kg')) {
      context.handle(
        _tareKgMeta,
        tareKg.isAcceptableOrUnknown(data['tare_kg']!, _tareKgMeta),
      );
    } else if (isInserting) {
      context.missing(_tareKgMeta);
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
  VehicleTareRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleTareRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number'],
      )!,
      tareKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tare_kg'],
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
  $VehicleTareRecordsTable createAlias(String alias) {
    return $VehicleTareRecordsTable(attachedDatabase, alias);
  }
}

class VehicleTareRecord extends DataClass
    implements Insertable<VehicleTareRecord> {
  final int id;
  final String vehicleNumber;
  final double tareKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VehicleTareRecord({
    required this.id,
    required this.vehicleNumber,
    required this.tareKg,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
    map['tare_kg'] = Variable<double>(tareKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehicleTareRecordsCompanion toCompanion(bool nullToAbsent) {
    return VehicleTareRecordsCompanion(
      id: Value(id),
      vehicleNumber: Value(vehicleNumber),
      tareKg: Value(tareKg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VehicleTareRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleTareRecord(
      id: serializer.fromJson<int>(json['id']),
      vehicleNumber: serializer.fromJson<String>(json['vehicleNumber']),
      tareKg: serializer.fromJson<double>(json['tareKg']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleNumber': serializer.toJson<String>(vehicleNumber),
      'tareKg': serializer.toJson<double>(tareKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VehicleTareRecord copyWith({
    int? id,
    String? vehicleNumber,
    double? tareKg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VehicleTareRecord(
    id: id ?? this.id,
    vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    tareKg: tareKg ?? this.tareKg,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VehicleTareRecord copyWithCompanion(VehicleTareRecordsCompanion data) {
    return VehicleTareRecord(
      id: data.id.present ? data.id.value : this.id,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
      tareKg: data.tareKg.present ? data.tareKg.value : this.tareKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleTareRecord(')
          ..write('id: $id, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('tareKg: $tareKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleNumber, tareKg, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleTareRecord &&
          other.id == this.id &&
          other.vehicleNumber == this.vehicleNumber &&
          other.tareKg == this.tareKg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehicleTareRecordsCompanion extends UpdateCompanion<VehicleTareRecord> {
  final Value<int> id;
  final Value<String> vehicleNumber;
  final Value<double> tareKg;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VehicleTareRecordsCompanion({
    this.id = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.tareKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehicleTareRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String vehicleNumber,
    required double tareKg,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : vehicleNumber = Value(vehicleNumber),
       tareKg = Value(tareKg);
  static Insertable<VehicleTareRecord> custom({
    Expression<int>? id,
    Expression<String>? vehicleNumber,
    Expression<double>? tareKg,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (tareKg != null) 'tare_kg': tareKg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehicleTareRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? vehicleNumber,
    Value<double>? tareKg,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VehicleTareRecordsCompanion(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      tareKg: tareKg ?? this.tareKg,
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
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
    }
    if (tareKg.present) {
      map['tare_kg'] = Variable<double>(tareKg.value);
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
    return (StringBuffer('VehicleTareRecordsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('tareKg: $tareKg, ')
          ..write('createdAt: $createdAt, ')
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
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ScaleSettingsTable scaleSettings = $ScaleSettingsTable(this);
  late final $AutoTareSettingsTable autoTareSettings = $AutoTareSettingsTable(
    this,
  );
  late final $VehicleTareRecordsTable vehicleTareRecords =
      $VehicleTareRecordsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final ScaleSettingsDao scaleSettingsDao = ScaleSettingsDao(
    this as AppDatabase,
  );
  late final AutoTareSettingsDao autoTareSettingsDao = AutoTareSettingsDao(
    this as AppDatabase,
  );
  late final VehicleTareRecordsDao vehicleTareRecordsDao =
      VehicleTareRecordsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    weighments,
    appSettings,
    scaleSettings,
    autoTareSettings,
    vehicleTareRecords,
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
typedef $$AutoTareSettingsTableCreateCompanionBuilder =
    AutoTareSettingsCompanion Function({
      Value<int> id,
      required DateTime tareDate,
      required double tareKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AutoTareSettingsTableUpdateCompanionBuilder =
    AutoTareSettingsCompanion Function({
      Value<int> id,
      Value<DateTime> tareDate,
      Value<double> tareKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AutoTareSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AutoTareSettingsTable> {
  $$AutoTareSettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get tareDate => $composableBuilder(
    column: $table.tareDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tareKg => $composableBuilder(
    column: $table.tareKg,
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

class $$AutoTareSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AutoTareSettingsTable> {
  $$AutoTareSettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get tareDate => $composableBuilder(
    column: $table.tareDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tareKg => $composableBuilder(
    column: $table.tareKg,
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

class $$AutoTareSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutoTareSettingsTable> {
  $$AutoTareSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get tareDate =>
      $composableBuilder(column: $table.tareDate, builder: (column) => column);

  GeneratedColumn<double> get tareKg =>
      $composableBuilder(column: $table.tareKg, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AutoTareSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AutoTareSettingsTable,
          AutoTareSetting,
          $$AutoTareSettingsTableFilterComposer,
          $$AutoTareSettingsTableOrderingComposer,
          $$AutoTareSettingsTableAnnotationComposer,
          $$AutoTareSettingsTableCreateCompanionBuilder,
          $$AutoTareSettingsTableUpdateCompanionBuilder,
          (
            AutoTareSetting,
            BaseReferences<
              _$AppDatabase,
              $AutoTareSettingsTable,
              AutoTareSetting
            >,
          ),
          AutoTareSetting,
          PrefetchHooks Function()
        > {
  $$AutoTareSettingsTableTableManager(
    _$AppDatabase db,
    $AutoTareSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutoTareSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutoTareSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutoTareSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> tareDate = const Value.absent(),
                Value<double> tareKg = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AutoTareSettingsCompanion(
                id: id,
                tareDate: tareDate,
                tareKg: tareKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime tareDate,
                required double tareKg,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AutoTareSettingsCompanion.insert(
                id: id,
                tareDate: tareDate,
                tareKg: tareKg,
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

typedef $$AutoTareSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AutoTareSettingsTable,
      AutoTareSetting,
      $$AutoTareSettingsTableFilterComposer,
      $$AutoTareSettingsTableOrderingComposer,
      $$AutoTareSettingsTableAnnotationComposer,
      $$AutoTareSettingsTableCreateCompanionBuilder,
      $$AutoTareSettingsTableUpdateCompanionBuilder,
      (
        AutoTareSetting,
        BaseReferences<_$AppDatabase, $AutoTareSettingsTable, AutoTareSetting>,
      ),
      AutoTareSetting,
      PrefetchHooks Function()
    >;
typedef $$VehicleTareRecordsTableCreateCompanionBuilder =
    VehicleTareRecordsCompanion Function({
      Value<int> id,
      required String vehicleNumber,
      required double tareKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VehicleTareRecordsTableUpdateCompanionBuilder =
    VehicleTareRecordsCompanion Function({
      Value<int> id,
      Value<String> vehicleNumber,
      Value<double> tareKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$VehicleTareRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleTareRecordsTable> {
  $$VehicleTareRecordsTableFilterComposer({
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

  ColumnFilters<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tareKg => $composableBuilder(
    column: $table.tareKg,
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

class $$VehicleTareRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleTareRecordsTable> {
  $$VehicleTareRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tareKg => $composableBuilder(
    column: $table.tareKg,
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

class $$VehicleTareRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleTareRecordsTable> {
  $$VehicleTareRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tareKg =>
      $composableBuilder(column: $table.tareKg, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VehicleTareRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleTareRecordsTable,
          VehicleTareRecord,
          $$VehicleTareRecordsTableFilterComposer,
          $$VehicleTareRecordsTableOrderingComposer,
          $$VehicleTareRecordsTableAnnotationComposer,
          $$VehicleTareRecordsTableCreateCompanionBuilder,
          $$VehicleTareRecordsTableUpdateCompanionBuilder,
          (
            VehicleTareRecord,
            BaseReferences<
              _$AppDatabase,
              $VehicleTareRecordsTable,
              VehicleTareRecord
            >,
          ),
          VehicleTareRecord,
          PrefetchHooks Function()
        > {
  $$VehicleTareRecordsTableTableManager(
    _$AppDatabase db,
    $VehicleTareRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleTareRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleTareRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleTareRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vehicleNumber = const Value.absent(),
                Value<double> tareKg = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehicleTareRecordsCompanion(
                id: id,
                vehicleNumber: vehicleNumber,
                tareKg: tareKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vehicleNumber,
                required double tareKg,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehicleTareRecordsCompanion.insert(
                id: id,
                vehicleNumber: vehicleNumber,
                tareKg: tareKg,
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

typedef $$VehicleTareRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleTareRecordsTable,
      VehicleTareRecord,
      $$VehicleTareRecordsTableFilterComposer,
      $$VehicleTareRecordsTableOrderingComposer,
      $$VehicleTareRecordsTableAnnotationComposer,
      $$VehicleTareRecordsTableCreateCompanionBuilder,
      $$VehicleTareRecordsTableUpdateCompanionBuilder,
      (
        VehicleTareRecord,
        BaseReferences<
          _$AppDatabase,
          $VehicleTareRecordsTable,
          VehicleTareRecord
        >,
      ),
      VehicleTareRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db, _db.weighments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ScaleSettingsTableTableManager get scaleSettings =>
      $$ScaleSettingsTableTableManager(_db, _db.scaleSettings);
  $$AutoTareSettingsTableTableManager get autoTareSettings =>
      $$AutoTareSettingsTableTableManager(_db, _db.autoTareSettings);
  $$VehicleTareRecordsTableTableManager get vehicleTareRecords =>
      $$VehicleTareRecordsTableTableManager(_db, _db.vehicleTareRecords);
}
