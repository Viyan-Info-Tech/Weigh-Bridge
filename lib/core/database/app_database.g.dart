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

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstNumberMeta = const VerificationMeta(
    'gstNumber',
  );
  @override
  late final GeneratedColumn<String> gstNumber = GeneratedColumn<String>(
    'gst_number',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    contactPerson,
    mobile,
    email,
    address,
    gstNumber,
    city,
    state,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
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
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('gst_number')) {
      context.handle(
        _gstNumberMeta,
        gstNumber.isAcceptableOrUnknown(data['gst_number']!, _gstNumberMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
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
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      gstNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_number'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
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
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final int id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Party({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || gstNumber != null) {
      map['gst_number'] = Variable<String>(gstNumber);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      gstNumber: gstNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(gstNumber),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      gstNumber: serializer.fromJson<String?>(json['gstNumber']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
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
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'mobile': serializer.toJson<String?>(mobile),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'gstNumber': serializer.toJson<String?>(gstNumber),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Party copyWith({
    int? id,
    String? name,
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> mobile = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> gstNumber = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Party(
    id: id ?? this.id,
    name: name ?? this.name,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    mobile: mobile.present ? mobile.value : this.mobile,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    gstNumber: gstNumber.present ? gstNumber.value : this.gstNumber,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      gstNumber: data.gstNumber.present ? data.gstNumber.value : this.gstNumber,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('gstNumber: $gstNumber, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactPerson,
    mobile,
    email,
    address,
    gstNumber,
    city,
    state,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.mobile == this.mobile &&
          other.email == this.email &&
          other.address == this.address &&
          other.gstNumber == this.gstNumber &&
          other.city == this.city &&
          other.state == this.state &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String?> mobile;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> gstNumber;
  final Value<String?> city;
  final Value<String?> state;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.mobile = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.gstNumber = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PartiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contactPerson = const Value.absent(),
    this.mobile = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.gstNumber = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Party> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? mobile,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? gstNumber,
    Expression<String>? city,
    Expression<String>? state,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (mobile != null) 'mobile': mobile,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (gstNumber != null) 'gst_number': gstNumber,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PartiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contactPerson,
    Value<String?>? mobile,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? gstNumber,
    Value<String?>? city,
    Value<String?>? state,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      city: city ?? this.city,
      state: state ?? this.state,
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
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (gstNumber.present) {
      map['gst_number'] = Variable<String>(gstNumber.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
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
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('gstNumber: $gstNumber, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<int> partyId = GeneratedColumn<int>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _vehicleTypeMeta = const VerificationMeta(
    'vehicleType',
  );
  @override
  late final GeneratedColumn<String> vehicleType = GeneratedColumn<String>(
    'vehicle_type',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverNameMeta = const VerificationMeta(
    'driverName',
  );
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
    'driver_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverPhoneMeta = const VerificationMeta(
    'driverPhone',
  );
  @override
  late final GeneratedColumn<String> driverPhone = GeneratedColumn<String>(
    'driver_phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tareWeightMeta = const VerificationMeta(
    'tareWeight',
  );
  @override
  late final GeneratedColumn<double> tareWeight = GeneratedColumn<double>(
    'tare_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    vehicleNumber,
    partyId,
    vehicleType,
    driverName,
    driverPhone,
    tareWeight,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
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
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('vehicle_type')) {
      context.handle(
        _vehicleTypeMeta,
        vehicleType.isAcceptableOrUnknown(
          data['vehicle_type']!,
          _vehicleTypeMeta,
        ),
      );
    }
    if (data.containsKey('driver_name')) {
      context.handle(
        _driverNameMeta,
        driverName.isAcceptableOrUnknown(data['driver_name']!, _driverNameMeta),
      );
    }
    if (data.containsKey('driver_phone')) {
      context.handle(
        _driverPhoneMeta,
        driverPhone.isAcceptableOrUnknown(
          data['driver_phone']!,
          _driverPhoneMeta,
        ),
      );
    }
    if (data.containsKey('tare_weight')) {
      context.handle(
        _tareWeightMeta,
        tareWeight.isAcceptableOrUnknown(data['tare_weight']!, _tareWeightMeta),
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
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}party_id'],
      )!,
      vehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_type'],
      ),
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      ),
      driverPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_phone'],
      ),
      tareWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tare_weight'],
      ),
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
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String vehicleNumber;
  final int partyId;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final double? tareWeight;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.partyId,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.tareWeight,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
    map['party_id'] = Variable<int>(partyId);
    if (!nullToAbsent || vehicleType != null) {
      map['vehicle_type'] = Variable<String>(vehicleType);
    }
    if (!nullToAbsent || driverName != null) {
      map['driver_name'] = Variable<String>(driverName);
    }
    if (!nullToAbsent || driverPhone != null) {
      map['driver_phone'] = Variable<String>(driverPhone);
    }
    if (!nullToAbsent || tareWeight != null) {
      map['tare_weight'] = Variable<double>(tareWeight);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      vehicleNumber: Value(vehicleNumber),
      partyId: Value(partyId),
      vehicleType: vehicleType == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleType),
      driverName: driverName == null && nullToAbsent
          ? const Value.absent()
          : Value(driverName),
      driverPhone: driverPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(driverPhone),
      tareWeight: tareWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(tareWeight),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      vehicleNumber: serializer.fromJson<String>(json['vehicleNumber']),
      partyId: serializer.fromJson<int>(json['partyId']),
      vehicleType: serializer.fromJson<String?>(json['vehicleType']),
      driverName: serializer.fromJson<String?>(json['driverName']),
      driverPhone: serializer.fromJson<String?>(json['driverPhone']),
      tareWeight: serializer.fromJson<double?>(json['tareWeight']),
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
      'vehicleNumber': serializer.toJson<String>(vehicleNumber),
      'partyId': serializer.toJson<int>(partyId),
      'vehicleType': serializer.toJson<String?>(vehicleType),
      'driverName': serializer.toJson<String?>(driverName),
      'driverPhone': serializer.toJson<String?>(driverPhone),
      'tareWeight': serializer.toJson<double?>(tareWeight),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vehicle copyWith({
    int? id,
    String? vehicleNumber,
    int? partyId,
    Value<String?> vehicleType = const Value.absent(),
    Value<String?> driverName = const Value.absent(),
    Value<String?> driverPhone = const Value.absent(),
    Value<double?> tareWeight = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vehicle(
    id: id ?? this.id,
    vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    partyId: partyId ?? this.partyId,
    vehicleType: vehicleType.present ? vehicleType.value : this.vehicleType,
    driverName: driverName.present ? driverName.value : this.driverName,
    driverPhone: driverPhone.present ? driverPhone.value : this.driverPhone,
    tareWeight: tareWeight.present ? tareWeight.value : this.tareWeight,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      vehicleType: data.vehicleType.present
          ? data.vehicleType.value
          : this.vehicleType,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      driverPhone: data.driverPhone.present
          ? data.driverPhone.value
          : this.driverPhone,
      tareWeight: data.tareWeight.present
          ? data.tareWeight.value
          : this.tareWeight,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('partyId: $partyId, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('driverName: $driverName, ')
          ..write('driverPhone: $driverPhone, ')
          ..write('tareWeight: $tareWeight, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleNumber,
    partyId,
    vehicleType,
    driverName,
    driverPhone,
    tareWeight,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.vehicleNumber == this.vehicleNumber &&
          other.partyId == this.partyId &&
          other.vehicleType == this.vehicleType &&
          other.driverName == this.driverName &&
          other.driverPhone == this.driverPhone &&
          other.tareWeight == this.tareWeight &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> vehicleNumber;
  final Value<int> partyId;
  final Value<String?> vehicleType;
  final Value<String?> driverName;
  final Value<String?> driverPhone;
  final Value<double?> tareWeight;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.partyId = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.driverName = const Value.absent(),
    this.driverPhone = const Value.absent(),
    this.tareWeight = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String vehicleNumber,
    required int partyId,
    this.vehicleType = const Value.absent(),
    this.driverName = const Value.absent(),
    this.driverPhone = const Value.absent(),
    this.tareWeight = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : vehicleNumber = Value(vehicleNumber),
       partyId = Value(partyId);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? vehicleNumber,
    Expression<int>? partyId,
    Expression<String>? vehicleType,
    Expression<String>? driverName,
    Expression<String>? driverPhone,
    Expression<double>? tareWeight,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (partyId != null) 'party_id': partyId,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (driverName != null) 'driver_name': driverName,
      if (driverPhone != null) 'driver_phone': driverPhone,
      if (tareWeight != null) 'tare_weight': tareWeight,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? vehicleNumber,
    Value<int>? partyId,
    Value<String?>? vehicleType,
    Value<String?>? driverName,
    Value<String?>? driverPhone,
    Value<double?>? tareWeight,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      partyId: partyId ?? this.partyId,
      vehicleType: vehicleType ?? this.vehicleType,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      tareWeight: tareWeight ?? this.tareWeight,
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
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<int>(partyId.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(vehicleType.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (driverPhone.present) {
      map['driver_phone'] = Variable<String>(driverPhone.value);
    }
    if (tareWeight.present) {
      map['tare_weight'] = Variable<double>(tareWeight.value);
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
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('partyId: $partyId, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('driverName: $driverName, ')
          ..write('driverPhone: $driverPhone, ')
          ..write('tareWeight: $tareWeight, ')
          ..write('isActive: $isActive, ')
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ton'),
  );
  static const VerificationMeta _defaultRateMeta = const VerificationMeta(
    'defaultRate',
  );
  @override
  late final GeneratedColumn<double> defaultRate = GeneratedColumn<double>(
    'default_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    category,
    unit,
    defaultRate,
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('default_rate')) {
      context.handle(
        _defaultRateMeta,
        defaultRate.isAcceptableOrUnknown(
          data['default_rate']!,
          _defaultRateMeta,
        ),
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
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      defaultRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_rate'],
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
  final String? category;
  final String unit;
  final double defaultRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Material({
    required this.id,
    required this.name,
    this.category,
    required this.unit,
    required this.defaultRate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['unit'] = Variable<String>(unit);
    map['default_rate'] = Variable<double>(defaultRate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      unit: Value(unit),
      defaultRate: Value(defaultRate),
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
      category: serializer.fromJson<String?>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      defaultRate: serializer.fromJson<double>(json['defaultRate']),
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
      'category': serializer.toJson<String?>(category),
      'unit': serializer.toJson<String>(unit),
      'defaultRate': serializer.toJson<double>(defaultRate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Material copyWith({
    int? id,
    String? name,
    Value<String?> category = const Value.absent(),
    String? unit,
    double? defaultRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Material(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    unit: unit ?? this.unit,
    defaultRate: defaultRate ?? this.defaultRate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      defaultRate: data.defaultRate.present
          ? data.defaultRate.value
          : this.defaultRate,
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
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('defaultRate: $defaultRate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    unit,
    defaultRate,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.defaultRate == this.defaultRate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String> unit;
  final Value<double> defaultRate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.defaultRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.defaultRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Material> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? defaultRate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (defaultRate != null) 'default_rate': defaultRate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<String>? unit,
    Value<double>? defaultRate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      defaultRate: defaultRate ?? this.defaultRate,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (defaultRate.present) {
      map['default_rate'] = Variable<double>(defaultRate.value);
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
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('defaultRate: $defaultRate, ')
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
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<int> partyId = GeneratedColumn<int>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<int> materialId = GeneratedColumn<int>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES materials (id)',
    ),
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
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
  static const VerificationMeta _secondWeightKgMeta = const VerificationMeta(
    'secondWeightKg',
  );
  @override
  late final GeneratedColumn<double> secondWeightKg = GeneratedColumn<double>(
    'second_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netWeightKgMeta = const VerificationMeta(
    'netWeightKg',
  );
  @override
  late final GeneratedColumn<double> netWeightKg = GeneratedColumn<double>(
    'net_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePerTonMeta = const VerificationMeta(
    'ratePerTon',
  );
  @override
  late final GeneratedColumn<double> ratePerTon = GeneratedColumn<double>(
    'rate_per_ton',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
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
    partyId,
    vehicleId,
    materialId,
    entryType,
    paymentMode,
    firstWeightKg,
    secondWeightKg,
    netWeightKg,
    ratePerTon,
    amount,
    remarks,
    status,
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
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
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
    if (data.containsKey('second_weight_kg')) {
      context.handle(
        _secondWeightKgMeta,
        secondWeightKg.isAcceptableOrUnknown(
          data['second_weight_kg']!,
          _secondWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondWeightKgMeta);
    }
    if (data.containsKey('net_weight_kg')) {
      context.handle(
        _netWeightKgMeta,
        netWeightKg.isAcceptableOrUnknown(
          data['net_weight_kg']!,
          _netWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netWeightKgMeta);
    }
    if (data.containsKey('rate_per_ton')) {
      context.handle(
        _ratePerTonMeta,
        ratePerTon.isAcceptableOrUnknown(
          data['rate_per_ton']!,
          _ratePerTonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePerTonMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}party_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}material_id'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      firstWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}first_weight_kg'],
      )!,
      secondWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}second_weight_kg'],
      )!,
      netWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_weight_kg'],
      )!,
      ratePerTon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate_per_ton'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
  final int partyId;
  final int vehicleId;
  final int materialId;
  final String entryType;
  final String paymentMode;
  final double firstWeightKg;
  final double secondWeightKg;
  final double netWeightKg;
  final double ratePerTon;
  final double amount;
  final String? remarks;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Weighment({
    required this.id,
    required this.billNumber,
    required this.partyId,
    required this.vehicleId,
    required this.materialId,
    required this.entryType,
    required this.paymentMode,
    required this.firstWeightKg,
    required this.secondWeightKg,
    required this.netWeightKg,
    required this.ratePerTon,
    required this.amount,
    this.remarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_number'] = Variable<String>(billNumber);
    map['party_id'] = Variable<int>(partyId);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['material_id'] = Variable<int>(materialId);
    map['entry_type'] = Variable<String>(entryType);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['first_weight_kg'] = Variable<double>(firstWeightKg);
    map['second_weight_kg'] = Variable<double>(secondWeightKg);
    map['net_weight_kg'] = Variable<double>(netWeightKg);
    map['rate_per_ton'] = Variable<double>(ratePerTon);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeighmentsCompanion toCompanion(bool nullToAbsent) {
    return WeighmentsCompanion(
      id: Value(id),
      billNumber: Value(billNumber),
      partyId: Value(partyId),
      vehicleId: Value(vehicleId),
      materialId: Value(materialId),
      entryType: Value(entryType),
      paymentMode: Value(paymentMode),
      firstWeightKg: Value(firstWeightKg),
      secondWeightKg: Value(secondWeightKg),
      netWeightKg: Value(netWeightKg),
      ratePerTon: Value(ratePerTon),
      amount: Value(amount),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      status: Value(status),
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
      partyId: serializer.fromJson<int>(json['partyId']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      materialId: serializer.fromJson<int>(json['materialId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      firstWeightKg: serializer.fromJson<double>(json['firstWeightKg']),
      secondWeightKg: serializer.fromJson<double>(json['secondWeightKg']),
      netWeightKg: serializer.fromJson<double>(json['netWeightKg']),
      ratePerTon: serializer.fromJson<double>(json['ratePerTon']),
      amount: serializer.fromJson<double>(json['amount']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      status: serializer.fromJson<String>(json['status']),
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
      'partyId': serializer.toJson<int>(partyId),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'materialId': serializer.toJson<int>(materialId),
      'entryType': serializer.toJson<String>(entryType),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'firstWeightKg': serializer.toJson<double>(firstWeightKg),
      'secondWeightKg': serializer.toJson<double>(secondWeightKg),
      'netWeightKg': serializer.toJson<double>(netWeightKg),
      'ratePerTon': serializer.toJson<double>(ratePerTon),
      'amount': serializer.toJson<double>(amount),
      'remarks': serializer.toJson<String?>(remarks),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Weighment copyWith({
    int? id,
    String? billNumber,
    int? partyId,
    int? vehicleId,
    int? materialId,
    String? entryType,
    String? paymentMode,
    double? firstWeightKg,
    double? secondWeightKg,
    double? netWeightKg,
    double? ratePerTon,
    double? amount,
    Value<String?> remarks = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Weighment(
    id: id ?? this.id,
    billNumber: billNumber ?? this.billNumber,
    partyId: partyId ?? this.partyId,
    vehicleId: vehicleId ?? this.vehicleId,
    materialId: materialId ?? this.materialId,
    entryType: entryType ?? this.entryType,
    paymentMode: paymentMode ?? this.paymentMode,
    firstWeightKg: firstWeightKg ?? this.firstWeightKg,
    secondWeightKg: secondWeightKg ?? this.secondWeightKg,
    netWeightKg: netWeightKg ?? this.netWeightKg,
    ratePerTon: ratePerTon ?? this.ratePerTon,
    amount: amount ?? this.amount,
    remarks: remarks.present ? remarks.value : this.remarks,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Weighment copyWithCompanion(WeighmentsCompanion data) {
    return Weighment(
      id: data.id.present ? data.id.value : this.id,
      billNumber: data.billNumber.present
          ? data.billNumber.value
          : this.billNumber,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      firstWeightKg: data.firstWeightKg.present
          ? data.firstWeightKg.value
          : this.firstWeightKg,
      secondWeightKg: data.secondWeightKg.present
          ? data.secondWeightKg.value
          : this.secondWeightKg,
      netWeightKg: data.netWeightKg.present
          ? data.netWeightKg.value
          : this.netWeightKg,
      ratePerTon: data.ratePerTon.present
          ? data.ratePerTon.value
          : this.ratePerTon,
      amount: data.amount.present ? data.amount.value : this.amount,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Weighment(')
          ..write('id: $id, ')
          ..write('billNumber: $billNumber, ')
          ..write('partyId: $partyId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('materialId: $materialId, ')
          ..write('entryType: $entryType, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('ratePerTon: $ratePerTon, ')
          ..write('amount: $amount, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billNumber,
    partyId,
    vehicleId,
    materialId,
    entryType,
    paymentMode,
    firstWeightKg,
    secondWeightKg,
    netWeightKg,
    ratePerTon,
    amount,
    remarks,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weighment &&
          other.id == this.id &&
          other.billNumber == this.billNumber &&
          other.partyId == this.partyId &&
          other.vehicleId == this.vehicleId &&
          other.materialId == this.materialId &&
          other.entryType == this.entryType &&
          other.paymentMode == this.paymentMode &&
          other.firstWeightKg == this.firstWeightKg &&
          other.secondWeightKg == this.secondWeightKg &&
          other.netWeightKg == this.netWeightKg &&
          other.ratePerTon == this.ratePerTon &&
          other.amount == this.amount &&
          other.remarks == this.remarks &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeighmentsCompanion extends UpdateCompanion<Weighment> {
  final Value<int> id;
  final Value<String> billNumber;
  final Value<int> partyId;
  final Value<int> vehicleId;
  final Value<int> materialId;
  final Value<String> entryType;
  final Value<String> paymentMode;
  final Value<double> firstWeightKg;
  final Value<double> secondWeightKg;
  final Value<double> netWeightKg;
  final Value<double> ratePerTon;
  final Value<double> amount;
  final Value<String?> remarks;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeighmentsCompanion({
    this.id = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.partyId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.firstWeightKg = const Value.absent(),
    this.secondWeightKg = const Value.absent(),
    this.netWeightKg = const Value.absent(),
    this.ratePerTon = const Value.absent(),
    this.amount = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeighmentsCompanion.insert({
    this.id = const Value.absent(),
    required String billNumber,
    required int partyId,
    required int vehicleId,
    required int materialId,
    required String entryType,
    required String paymentMode,
    required double firstWeightKg,
    required double secondWeightKg,
    required double netWeightKg,
    required double ratePerTon,
    required double amount,
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : billNumber = Value(billNumber),
       partyId = Value(partyId),
       vehicleId = Value(vehicleId),
       materialId = Value(materialId),
       entryType = Value(entryType),
       paymentMode = Value(paymentMode),
       firstWeightKg = Value(firstWeightKg),
       secondWeightKg = Value(secondWeightKg),
       netWeightKg = Value(netWeightKg),
       ratePerTon = Value(ratePerTon),
       amount = Value(amount);
  static Insertable<Weighment> custom({
    Expression<int>? id,
    Expression<String>? billNumber,
    Expression<int>? partyId,
    Expression<int>? vehicleId,
    Expression<int>? materialId,
    Expression<String>? entryType,
    Expression<String>? paymentMode,
    Expression<double>? firstWeightKg,
    Expression<double>? secondWeightKg,
    Expression<double>? netWeightKg,
    Expression<double>? ratePerTon,
    Expression<double>? amount,
    Expression<String>? remarks,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billNumber != null) 'bill_number': billNumber,
      if (partyId != null) 'party_id': partyId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (materialId != null) 'material_id': materialId,
      if (entryType != null) 'entry_type': entryType,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (firstWeightKg != null) 'first_weight_kg': firstWeightKg,
      if (secondWeightKg != null) 'second_weight_kg': secondWeightKg,
      if (netWeightKg != null) 'net_weight_kg': netWeightKg,
      if (ratePerTon != null) 'rate_per_ton': ratePerTon,
      if (amount != null) 'amount': amount,
      if (remarks != null) 'remarks': remarks,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeighmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? billNumber,
    Value<int>? partyId,
    Value<int>? vehicleId,
    Value<int>? materialId,
    Value<String>? entryType,
    Value<String>? paymentMode,
    Value<double>? firstWeightKg,
    Value<double>? secondWeightKg,
    Value<double>? netWeightKg,
    Value<double>? ratePerTon,
    Value<double>? amount,
    Value<String?>? remarks,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeighmentsCompanion(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      partyId: partyId ?? this.partyId,
      vehicleId: vehicleId ?? this.vehicleId,
      materialId: materialId ?? this.materialId,
      entryType: entryType ?? this.entryType,
      paymentMode: paymentMode ?? this.paymentMode,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      ratePerTon: ratePerTon ?? this.ratePerTon,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
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
    if (partyId.present) {
      map['party_id'] = Variable<int>(partyId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<int>(materialId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (firstWeightKg.present) {
      map['first_weight_kg'] = Variable<double>(firstWeightKg.value);
    }
    if (secondWeightKg.present) {
      map['second_weight_kg'] = Variable<double>(secondWeightKg.value);
    }
    if (netWeightKg.present) {
      map['net_weight_kg'] = Variable<double>(netWeightKg.value);
    }
    if (ratePerTon.present) {
      map['rate_per_ton'] = Variable<double>(ratePerTon.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
          ..write('partyId: $partyId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('materialId: $materialId, ')
          ..write('entryType: $entryType, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('ratePerTon: $ratePerTon, ')
          ..write('amount: $amount, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
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
  late final $PartiesTable parties = $PartiesTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $WeighmentsTable weighments = $WeighmentsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final PartyDao partyDao = PartyDao(this as AppDatabase);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final MaterialDao materialDao = MaterialDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    parties,
    vehicles,
    materials,
    weighments,
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
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contactPerson,
      Value<String?> mobile,
      Value<String?> email,
      Value<String?> address,
      Value<String?> gstNumber,
      Value<String?> city,
      Value<String?> state,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contactPerson,
      Value<String?> mobile,
      Value<String?> email,
      Value<String?> address,
      Value<String?> gstNumber,
      Value<String?> city,
      Value<String?> state,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiclesTable, List<Vehicle>> _vehiclesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: 'parties__id__vehicles__party_id',
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WeighmentsTable, List<Weighment>>
  _weighmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weighments,
    aliasName: 'parties__id__weighments__party_id',
  );

  $$WeighmentsTableProcessedTableManager get weighmentsRefs {
    final manager = $$WeighmentsTableTableManager(
      $_db,
      $_db.weighments,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weighmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
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

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstNumber => $composableBuilder(
    column: $table.gstNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
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

  Expression<bool> vehiclesRefs(
    Expression<bool> Function($$VehiclesTableFilterComposer f) f,
  ) {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weighmentsRefs(
    Expression<bool> Function($$WeighmentsTableFilterComposer f) f,
  ) {
    final $$WeighmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableFilterComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
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

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstNumber => $composableBuilder(
    column: $table.gstNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
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

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
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

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get gstNumber =>
      $composableBuilder(column: $table.gstNumber, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> vehiclesRefs<T extends Object>(
    Expression<T> Function($$VehiclesTableAnnotationComposer a) f,
  ) {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weighmentsRefs<T extends Object>(
    Expression<T> Function($$WeighmentsTableAnnotationComposer a) f,
  ) {
    final $$WeighmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({bool vehiclesRefs, bool weighmentsRefs})
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> gstNumber = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                name: name,
                contactPerson: contactPerson,
                mobile: mobile,
                email: email,
                address: address,
                gstNumber: gstNumber,
                city: city,
                state: state,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> gstNumber = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                name: name,
                contactPerson: contactPerson,
                mobile: mobile,
                email: email,
                address: address,
                gstNumber: gstNumber,
                city: city,
                state: state,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehiclesRefs = false, weighmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vehiclesRefs) db.vehicles,
                    if (weighmentsRefs) db.weighments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vehiclesRefs)
                        await $_getPrefetchedData<
                          Party,
                          $PartiesTable,
                          Vehicle
                        >(
                          currentTable: table,
                          referencedTable: $$PartiesTableReferences
                              ._vehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).vehiclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (weighmentsRefs)
                        await $_getPrefetchedData<
                          Party,
                          $PartiesTable,
                          Weighment
                        >(
                          currentTable: table,
                          referencedTable: $$PartiesTableReferences
                              ._weighmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).weighmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({bool vehiclesRefs, bool weighmentsRefs})
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String vehicleNumber,
      required int partyId,
      Value<String?> vehicleType,
      Value<String?> driverName,
      Value<String?> driverPhone,
      Value<double?> tareWeight,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> vehicleNumber,
      Value<int> partyId,
      Value<String?> vehicleType,
      Value<String?> driverName,
      Value<String?> driverPhone,
      Value<double?> tareWeight,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('vehicles__party_id__parties__id');

  $$PartiesTableProcessedTableManager get partyId {
    final $_column = $_itemColumn<int>('party_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WeighmentsTable, List<Weighment>>
  _weighmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weighments,
    aliasName: 'vehicles__id__weighments__vehicle_id',
  );

  $$WeighmentsTableProcessedTableManager get weighmentsRefs {
    final manager = $$WeighmentsTableTableManager(
      $_db,
      $_db.weighments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weighmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tareWeight => $composableBuilder(
    column: $table.tareWeight,
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

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> weighmentsRefs(
    Expression<bool> Function($$WeighmentsTableFilterComposer f) f,
  ) {
    final $$WeighmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableFilterComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tareWeight => $composableBuilder(
    column: $table.tareWeight,
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

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
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

  GeneratedColumn<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tareWeight => $composableBuilder(
    column: $table.tareWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> weighmentsRefs<T extends Object>(
    Expression<T> Function($$WeighmentsTableAnnotationComposer a) f,
  ) {
    final $$WeighmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool partyId, bool weighmentsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vehicleNumber = const Value.absent(),
                Value<int> partyId = const Value.absent(),
                Value<String?> vehicleType = const Value.absent(),
                Value<String?> driverName = const Value.absent(),
                Value<String?> driverPhone = const Value.absent(),
                Value<double?> tareWeight = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                vehicleNumber: vehicleNumber,
                partyId: partyId,
                vehicleType: vehicleType,
                driverName: driverName,
                driverPhone: driverPhone,
                tareWeight: tareWeight,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vehicleNumber,
                required int partyId,
                Value<String?> vehicleType = const Value.absent(),
                Value<String?> driverName = const Value.absent(),
                Value<String?> driverPhone = const Value.absent(),
                Value<double?> tareWeight = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                vehicleNumber: vehicleNumber,
                partyId: partyId,
                vehicleType: vehicleType,
                driverName: driverName,
                driverPhone: driverPhone,
                tareWeight: tareWeight,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({partyId = false, weighmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (weighmentsRefs) db.weighments],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (partyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partyId,
                                referencedTable: $$VehiclesTableReferences
                                    ._partyIdTable(db),
                                referencedColumn: $$VehiclesTableReferences
                                    ._partyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (weighmentsRefs)
                    await $_getPrefetchedData<
                      Vehicle,
                      $VehiclesTable,
                      Weighment
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._weighmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).weighmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool partyId, bool weighmentsRefs})
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> category,
      Value<String> unit,
      Value<double> defaultRate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> category,
      Value<String> unit,
      Value<double> defaultRate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MaterialsTableReferences
    extends BaseReferences<_$AppDatabase, $MaterialsTable, Material> {
  $$MaterialsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WeighmentsTable, List<Weighment>>
  _weighmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weighments,
    aliasName: 'materials__id__weighments__material_id',
  );

  $$WeighmentsTableProcessedTableManager get weighmentsRefs {
    final manager = $$WeighmentsTableTableManager(
      $_db,
      $_db.weighments,
    ).filter((f) => f.materialId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weighmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
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

  Expression<bool> weighmentsRefs(
    Expression<bool> Function($$WeighmentsTableFilterComposer f) f,
  ) {
    final $$WeighmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.materialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableFilterComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> weighmentsRefs<T extends Object>(
    Expression<T> Function($$WeighmentsTableAnnotationComposer a) f,
  ) {
    final $$WeighmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighments,
      getReferencedColumn: (t) => t.materialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.weighments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Material, $$MaterialsTableReferences),
          Material,
          PrefetchHooks Function({bool weighmentsRefs})
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
                Value<String?> category = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> defaultRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                name: name,
                category: category,
                unit: unit,
                defaultRate: defaultRate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> defaultRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                name: name,
                category: category,
                unit: unit,
                defaultRate: defaultRate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaterialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({weighmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (weighmentsRefs) db.weighments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (weighmentsRefs)
                    await $_getPrefetchedData<
                      Material,
                      $MaterialsTable,
                      Weighment
                    >(
                      currentTable: table,
                      referencedTable: $$MaterialsTableReferences
                          ._weighmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MaterialsTableReferences(
                            db,
                            table,
                            p0,
                          ).weighmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.materialId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Material, $$MaterialsTableReferences),
      Material,
      PrefetchHooks Function({bool weighmentsRefs})
    >;
typedef $$WeighmentsTableCreateCompanionBuilder =
    WeighmentsCompanion Function({
      Value<int> id,
      required String billNumber,
      required int partyId,
      required int vehicleId,
      required int materialId,
      required String entryType,
      required String paymentMode,
      required double firstWeightKg,
      required double secondWeightKg,
      required double netWeightKg,
      required double ratePerTon,
      required double amount,
      Value<String?> remarks,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WeighmentsTableUpdateCompanionBuilder =
    WeighmentsCompanion Function({
      Value<int> id,
      Value<String> billNumber,
      Value<int> partyId,
      Value<int> vehicleId,
      Value<int> materialId,
      Value<String> entryType,
      Value<String> paymentMode,
      Value<double> firstWeightKg,
      Value<double> secondWeightKg,
      Value<double> netWeightKg,
      Value<double> ratePerTon,
      Value<double> amount,
      Value<String?> remarks,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WeighmentsTableReferences
    extends BaseReferences<_$AppDatabase, $WeighmentsTable, Weighment> {
  $$WeighmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('weighments__party_id__parties__id');

  $$PartiesTableProcessedTableManager get partyId {
    final $_column = $_itemColumn<int>('party_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('weighments__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MaterialsTable _materialIdTable(_$AppDatabase db) =>
      db.materials.createAlias('weighments__material_id__materials__id');

  $$MaterialsTableProcessedTableManager get materialId {
    final $_column = $_itemColumn<int>('material_id')!;

    final manager = $$MaterialsTableTableManager(
      $_db,
      $_db.materials,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_materialIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratePerTon => $composableBuilder(
    column: $table.ratePerTon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaterialsTableFilterComposer get materialId {
    final $$MaterialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableFilterComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratePerTon => $composableBuilder(
    column: $table.ratePerTon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaterialsTableOrderingComposer get materialId {
    final $$MaterialsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableOrderingComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get firstWeightKg => $composableBuilder(
    column: $table.firstWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get secondWeightKg => $composableBuilder(
    column: $table.secondWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netWeightKg => $composableBuilder(
    column: $table.netWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratePerTon => $composableBuilder(
    column: $table.ratePerTon,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaterialsTableAnnotationComposer get materialId {
    final $$MaterialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.materialId,
      referencedTable: $db.materials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaterialsTableAnnotationComposer(
            $db: $db,
            $table: $db.materials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Weighment, $$WeighmentsTableReferences),
          Weighment,
          PrefetchHooks Function({
            bool partyId,
            bool vehicleId,
            bool materialId,
          })
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
                Value<int> partyId = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> materialId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<double> firstWeightKg = const Value.absent(),
                Value<double> secondWeightKg = const Value.absent(),
                Value<double> netWeightKg = const Value.absent(),
                Value<double> ratePerTon = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion(
                id: id,
                billNumber: billNumber,
                partyId: partyId,
                vehicleId: vehicleId,
                materialId: materialId,
                entryType: entryType,
                paymentMode: paymentMode,
                firstWeightKg: firstWeightKg,
                secondWeightKg: secondWeightKg,
                netWeightKg: netWeightKg,
                ratePerTon: ratePerTon,
                amount: amount,
                remarks: remarks,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String billNumber,
                required int partyId,
                required int vehicleId,
                required int materialId,
                required String entryType,
                required String paymentMode,
                required double firstWeightKg,
                required double secondWeightKg,
                required double netWeightKg,
                required double ratePerTon,
                required double amount,
                Value<String?> remarks = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion.insert(
                id: id,
                billNumber: billNumber,
                partyId: partyId,
                vehicleId: vehicleId,
                materialId: materialId,
                entryType: entryType,
                paymentMode: paymentMode,
                firstWeightKg: firstWeightKg,
                secondWeightKg: secondWeightKg,
                netWeightKg: netWeightKg,
                ratePerTon: ratePerTon,
                amount: amount,
                remarks: remarks,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeighmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({partyId = false, vehicleId = false, materialId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable: $$WeighmentsTableReferences
                                        ._partyIdTable(db),
                                    referencedColumn:
                                        $$WeighmentsTableReferences
                                            ._partyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable: $$WeighmentsTableReferences
                                        ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$WeighmentsTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (materialId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.materialId,
                                    referencedTable: $$WeighmentsTableReferences
                                        ._materialIdTable(db),
                                    referencedColumn:
                                        $$WeighmentsTableReferences
                                            ._materialIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
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
      (Weighment, $$WeighmentsTableReferences),
      Weighment,
      PrefetchHooks Function({bool partyId, bool vehicleId, bool materialId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db, _db.weighments);
}
