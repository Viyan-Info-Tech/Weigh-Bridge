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

class $VehicleTypesTable extends VehicleTypes
    with TableInfo<$VehicleTypesTable, VehicleType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleTypesTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emptyPriceMeta = const VerificationMeta(
    'emptyPrice',
  );
  @override
  late final GeneratedColumn<double> emptyPrice = GeneratedColumn<double>(
    'empty_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loadPriceMeta = const VerificationMeta(
    'loadPrice',
  );
  @override
  late final GeneratedColumn<double> loadPrice = GeneratedColumn<double>(
    'load_price',
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
    emptyPrice,
    loadPrice,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleType> instance, {
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
    if (data.containsKey('empty_price')) {
      context.handle(
        _emptyPriceMeta,
        emptyPrice.isAcceptableOrUnknown(data['empty_price']!, _emptyPriceMeta),
      );
    }
    if (data.containsKey('load_price')) {
      context.handle(
        _loadPriceMeta,
        loadPrice.isAcceptableOrUnknown(data['load_price']!, _loadPriceMeta),
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
  VehicleType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emptyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}empty_price'],
      )!,
      loadPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}load_price'],
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
  $VehicleTypesTable createAlias(String alias) {
    return $VehicleTypesTable(attachedDatabase, alias);
  }
}

class VehicleType extends DataClass implements Insertable<VehicleType> {
  final int id;
  final String name;
  final double emptyPrice;
  final double loadPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VehicleType({
    required this.id,
    required this.name,
    required this.emptyPrice,
    required this.loadPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['empty_price'] = Variable<double>(emptyPrice);
    map['load_price'] = Variable<double>(loadPrice);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehicleTypesCompanion toCompanion(bool nullToAbsent) {
    return VehicleTypesCompanion(
      id: Value(id),
      name: Value(name),
      emptyPrice: Value(emptyPrice),
      loadPrice: Value(loadPrice),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VehicleType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emptyPrice: serializer.fromJson<double>(json['emptyPrice']),
      loadPrice: serializer.fromJson<double>(json['loadPrice']),
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
      'emptyPrice': serializer.toJson<double>(emptyPrice),
      'loadPrice': serializer.toJson<double>(loadPrice),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VehicleType copyWith({
    int? id,
    String? name,
    double? emptyPrice,
    double? loadPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VehicleType(
    id: id ?? this.id,
    name: name ?? this.name,
    emptyPrice: emptyPrice ?? this.emptyPrice,
    loadPrice: loadPrice ?? this.loadPrice,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VehicleType copyWithCompanion(VehicleTypesCompanion data) {
    return VehicleType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emptyPrice: data.emptyPrice.present
          ? data.emptyPrice.value
          : this.emptyPrice,
      loadPrice: data.loadPrice.present ? data.loadPrice.value : this.loadPrice,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emptyPrice: $emptyPrice, ')
          ..write('loadPrice: $loadPrice, ')
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
    emptyPrice,
    loadPrice,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleType &&
          other.id == this.id &&
          other.name == this.name &&
          other.emptyPrice == this.emptyPrice &&
          other.loadPrice == this.loadPrice &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehicleTypesCompanion extends UpdateCompanion<VehicleType> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> emptyPrice;
  final Value<double> loadPrice;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VehicleTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emptyPrice = const Value.absent(),
    this.loadPrice = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehicleTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emptyPrice = const Value.absent(),
    this.loadPrice = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<VehicleType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? emptyPrice,
    Expression<double>? loadPrice,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emptyPrice != null) 'empty_price': emptyPrice,
      if (loadPrice != null) 'load_price': loadPrice,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehicleTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? emptyPrice,
    Value<double>? loadPrice,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VehicleTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emptyPrice: emptyPrice ?? this.emptyPrice,
      loadPrice: loadPrice ?? this.loadPrice,
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
    if (emptyPrice.present) {
      map['empty_price'] = Variable<double>(emptyPrice.value);
    }
    if (loadPrice.present) {
      map['load_price'] = Variable<double>(loadPrice.value);
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
    return (StringBuffer('VehicleTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emptyPrice: $emptyPrice, ')
          ..write('loadPrice: $loadPrice, ')
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
  static const VerificationMeta _vehicleTypeIdMeta = const VerificationMeta(
    'vehicleTypeId',
  );
  @override
  late final GeneratedColumn<int> vehicleTypeId = GeneratedColumn<int>(
    'vehicle_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_types (id)',
    ),
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
    vehicleTypeId,
    driverName,
    driverPhone,
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
    if (data.containsKey('vehicle_type_id')) {
      context.handle(
        _vehicleTypeIdMeta,
        vehicleTypeId.isAcceptableOrUnknown(
          data['vehicle_type_id']!,
          _vehicleTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleTypeIdMeta);
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
      vehicleTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_type_id'],
      )!,
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      ),
      driverPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_phone'],
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
  final int vehicleTypeId;
  final String? driverName;
  final String? driverPhone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleTypeId,
    this.driverName,
    this.driverPhone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
    map['vehicle_type_id'] = Variable<int>(vehicleTypeId);
    if (!nullToAbsent || driverName != null) {
      map['driver_name'] = Variable<String>(driverName);
    }
    if (!nullToAbsent || driverPhone != null) {
      map['driver_phone'] = Variable<String>(driverPhone);
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
      vehicleTypeId: Value(vehicleTypeId),
      driverName: driverName == null && nullToAbsent
          ? const Value.absent()
          : Value(driverName),
      driverPhone: driverPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(driverPhone),
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
      vehicleTypeId: serializer.fromJson<int>(json['vehicleTypeId']),
      driverName: serializer.fromJson<String?>(json['driverName']),
      driverPhone: serializer.fromJson<String?>(json['driverPhone']),
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
      'vehicleTypeId': serializer.toJson<int>(vehicleTypeId),
      'driverName': serializer.toJson<String?>(driverName),
      'driverPhone': serializer.toJson<String?>(driverPhone),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vehicle copyWith({
    int? id,
    String? vehicleNumber,
    int? vehicleTypeId,
    Value<String?> driverName = const Value.absent(),
    Value<String?> driverPhone = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vehicle(
    id: id ?? this.id,
    vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
    driverName: driverName.present ? driverName.value : this.driverName,
    driverPhone: driverPhone.present ? driverPhone.value : this.driverPhone,
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
      vehicleTypeId: data.vehicleTypeId.present
          ? data.vehicleTypeId.value
          : this.vehicleTypeId,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      driverPhone: data.driverPhone.present
          ? data.driverPhone.value
          : this.driverPhone,
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
          ..write('vehicleTypeId: $vehicleTypeId, ')
          ..write('driverName: $driverName, ')
          ..write('driverPhone: $driverPhone, ')
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
    vehicleTypeId,
    driverName,
    driverPhone,
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
          other.vehicleTypeId == this.vehicleTypeId &&
          other.driverName == this.driverName &&
          other.driverPhone == this.driverPhone &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> vehicleNumber;
  final Value<int> vehicleTypeId;
  final Value<String?> driverName;
  final Value<String?> driverPhone;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.vehicleTypeId = const Value.absent(),
    this.driverName = const Value.absent(),
    this.driverPhone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String vehicleNumber,
    required int vehicleTypeId,
    this.driverName = const Value.absent(),
    this.driverPhone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : vehicleNumber = Value(vehicleNumber),
       vehicleTypeId = Value(vehicleTypeId);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? vehicleNumber,
    Expression<int>? vehicleTypeId,
    Expression<String>? driverName,
    Expression<String>? driverPhone,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
      if (driverName != null) 'driver_name': driverName,
      if (driverPhone != null) 'driver_phone': driverPhone,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? vehicleNumber,
    Value<int>? vehicleTypeId,
    Value<String?>? driverName,
    Value<String?>? driverPhone,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
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
    if (vehicleTypeId.present) {
      map['vehicle_type_id'] = Variable<int>(vehicleTypeId.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (driverPhone.present) {
      map['driver_phone'] = Variable<String>(driverPhone.value);
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
          ..write('vehicleTypeId: $vehicleTypeId, ')
          ..write('driverName: $driverName, ')
          ..write('driverPhone: $driverPhone, ')
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
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Material({
    required this.id,
    required this.name,
    this.category,
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
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Material copyWith({
    int? id,
    String? name,
    Value<String?> category = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Material(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
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
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Material> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
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
  static const VerificationMeta _vehicleChargeMeta = const VerificationMeta(
    'vehicleCharge',
  );
  @override
  late final GeneratedColumn<double> vehicleCharge = GeneratedColumn<double>(
    'vehicle_charge',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    defaultValue: const Constant('pending'),
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
    paymentMode,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    netWeightKg,
    vehicleCharge,
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
    if (data.containsKey('vehicle_charge')) {
      context.handle(
        _vehicleChargeMeta,
        vehicleCharge.isAcceptableOrUnknown(
          data['vehicle_charge']!,
          _vehicleChargeMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
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
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
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
      vehicleCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vehicle_charge'],
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
  final String paymentMode;
  final double firstWeightKg;
  final String firstWeightType;
  final double? secondWeightKg;
  final String? secondWeightType;
  final double? netWeightKg;
  final double vehicleCharge;
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
    required this.paymentMode,
    required this.firstWeightKg,
    required this.firstWeightType,
    this.secondWeightKg,
    this.secondWeightType,
    this.netWeightKg,
    required this.vehicleCharge,
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
    map['payment_mode'] = Variable<String>(paymentMode);
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
    map['vehicle_charge'] = Variable<double>(vehicleCharge);
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
      paymentMode: Value(paymentMode),
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
      vehicleCharge: Value(vehicleCharge),
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
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      firstWeightKg: serializer.fromJson<double>(json['firstWeightKg']),
      firstWeightType: serializer.fromJson<String>(json['firstWeightType']),
      secondWeightKg: serializer.fromJson<double?>(json['secondWeightKg']),
      secondWeightType: serializer.fromJson<String?>(json['secondWeightType']),
      netWeightKg: serializer.fromJson<double?>(json['netWeightKg']),
      vehicleCharge: serializer.fromJson<double>(json['vehicleCharge']),
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
      'paymentMode': serializer.toJson<String>(paymentMode),
      'firstWeightKg': serializer.toJson<double>(firstWeightKg),
      'firstWeightType': serializer.toJson<String>(firstWeightType),
      'secondWeightKg': serializer.toJson<double?>(secondWeightKg),
      'secondWeightType': serializer.toJson<String?>(secondWeightType),
      'netWeightKg': serializer.toJson<double?>(netWeightKg),
      'vehicleCharge': serializer.toJson<double>(vehicleCharge),
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
    String? paymentMode,
    double? firstWeightKg,
    String? firstWeightType,
    Value<double?> secondWeightKg = const Value.absent(),
    Value<String?> secondWeightType = const Value.absent(),
    Value<double?> netWeightKg = const Value.absent(),
    double? vehicleCharge,
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
    paymentMode: paymentMode ?? this.paymentMode,
    firstWeightKg: firstWeightKg ?? this.firstWeightKg,
    firstWeightType: firstWeightType ?? this.firstWeightType,
    secondWeightKg: secondWeightKg.present
        ? secondWeightKg.value
        : this.secondWeightKg,
    secondWeightType: secondWeightType.present
        ? secondWeightType.value
        : this.secondWeightType,
    netWeightKg: netWeightKg.present ? netWeightKg.value : this.netWeightKg,
    vehicleCharge: vehicleCharge ?? this.vehicleCharge,
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
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
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
      vehicleCharge: data.vehicleCharge.present
          ? data.vehicleCharge.value
          : this.vehicleCharge,
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
          ..write('paymentMode: $paymentMode, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('firstWeightType: $firstWeightType, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('secondWeightType: $secondWeightType, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('vehicleCharge: $vehicleCharge, ')
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
    paymentMode,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    netWeightKg,
    vehicleCharge,
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
          other.paymentMode == this.paymentMode &&
          other.firstWeightKg == this.firstWeightKg &&
          other.firstWeightType == this.firstWeightType &&
          other.secondWeightKg == this.secondWeightKg &&
          other.secondWeightType == this.secondWeightType &&
          other.netWeightKg == this.netWeightKg &&
          other.vehicleCharge == this.vehicleCharge &&
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
  final Value<String> paymentMode;
  final Value<double> firstWeightKg;
  final Value<String> firstWeightType;
  final Value<double?> secondWeightKg;
  final Value<String?> secondWeightType;
  final Value<double?> netWeightKg;
  final Value<double> vehicleCharge;
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
    this.paymentMode = const Value.absent(),
    this.firstWeightKg = const Value.absent(),
    this.firstWeightType = const Value.absent(),
    this.secondWeightKg = const Value.absent(),
    this.secondWeightType = const Value.absent(),
    this.netWeightKg = const Value.absent(),
    this.vehicleCharge = const Value.absent(),
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
    required String paymentMode,
    required double firstWeightKg,
    this.firstWeightType = const Value.absent(),
    this.secondWeightKg = const Value.absent(),
    this.secondWeightType = const Value.absent(),
    this.netWeightKg = const Value.absent(),
    this.vehicleCharge = const Value.absent(),
    this.amount = const Value.absent(),
    this.remarks = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : billNumber = Value(billNumber),
       partyId = Value(partyId),
       vehicleId = Value(vehicleId),
       materialId = Value(materialId),
       paymentMode = Value(paymentMode),
       firstWeightKg = Value(firstWeightKg);
  static Insertable<Weighment> custom({
    Expression<int>? id,
    Expression<String>? billNumber,
    Expression<int>? partyId,
    Expression<int>? vehicleId,
    Expression<int>? materialId,
    Expression<String>? paymentMode,
    Expression<double>? firstWeightKg,
    Expression<String>? firstWeightType,
    Expression<double>? secondWeightKg,
    Expression<String>? secondWeightType,
    Expression<double>? netWeightKg,
    Expression<double>? vehicleCharge,
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
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (firstWeightKg != null) 'first_weight_kg': firstWeightKg,
      if (firstWeightType != null) 'first_weight_type': firstWeightType,
      if (secondWeightKg != null) 'second_weight_kg': secondWeightKg,
      if (secondWeightType != null) 'second_weight_type': secondWeightType,
      if (netWeightKg != null) 'net_weight_kg': netWeightKg,
      if (vehicleCharge != null) 'vehicle_charge': vehicleCharge,
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
    Value<String>? paymentMode,
    Value<double>? firstWeightKg,
    Value<String>? firstWeightType,
    Value<double?>? secondWeightKg,
    Value<String?>? secondWeightType,
    Value<double?>? netWeightKg,
    Value<double>? vehicleCharge,
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
      paymentMode: paymentMode ?? this.paymentMode,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      firstWeightType: firstWeightType ?? this.firstWeightType,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      secondWeightType: secondWeightType ?? this.secondWeightType,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      vehicleCharge: vehicleCharge ?? this.vehicleCharge,
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
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
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
    if (vehicleCharge.present) {
      map['vehicle_charge'] = Variable<double>(vehicleCharge.value);
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
          ..write('paymentMode: $paymentMode, ')
          ..write('firstWeightKg: $firstWeightKg, ')
          ..write('firstWeightType: $firstWeightType, ')
          ..write('secondWeightKg: $secondWeightKg, ')
          ..write('secondWeightType: $secondWeightType, ')
          ..write('netWeightKg: $netWeightKg, ')
          ..write('vehicleCharge: $vehicleCharge, ')
          ..write('amount: $amount, ')
          ..write('remarks: $remarks, ')
          ..write('status: $status, ')
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
  static const VerificationMeta _showMaterialMeta = const VerificationMeta(
    'showMaterial',
  );
  @override
  late final GeneratedColumn<bool> showMaterial = GeneratedColumn<bool>(
    'show_material',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_material" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showPartyMeta = const VerificationMeta(
    'showParty',
  );
  @override
  late final GeneratedColumn<bool> showParty = GeneratedColumn<bool>(
    'show_party',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_party" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showVehicleTypeMeta = const VerificationMeta(
    'showVehicleType',
  );
  @override
  late final GeneratedColumn<bool> showVehicleType = GeneratedColumn<bool>(
    'show_vehicle_type',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_vehicle_type" IN (0, 1))',
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
  static const VerificationMeta _showAmountMeta = const VerificationMeta(
    'showAmount',
  );
  @override
  late final GeneratedColumn<bool> showAmount = GeneratedColumn<bool>(
    'show_amount',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_amount" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showPaymentModeMeta = const VerificationMeta(
    'showPaymentMode',
  );
  @override
  late final GeneratedColumn<bool> showPaymentMode = GeneratedColumn<bool>(
    'show_payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_payment_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showCashReceivedMeta = const VerificationMeta(
    'showCashReceived',
  );
  @override
  late final GeneratedColumn<bool> showCashReceived = GeneratedColumn<bool>(
    'show_cash_received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_cash_received" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showPendingAmountMeta = const VerificationMeta(
    'showPendingAmount',
  );
  @override
  late final GeneratedColumn<bool> showPendingAmount = GeneratedColumn<bool>(
    'show_pending_amount',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_pending_amount" IN (0, 1))',
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
    showMaterial,
    showParty,
    showVehicleType,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showAmount,
    showPaymentMode,
    showCashReceived,
    showPendingAmount,
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
    if (data.containsKey('show_material')) {
      context.handle(
        _showMaterialMeta,
        showMaterial.isAcceptableOrUnknown(
          data['show_material']!,
          _showMaterialMeta,
        ),
      );
    }
    if (data.containsKey('show_party')) {
      context.handle(
        _showPartyMeta,
        showParty.isAcceptableOrUnknown(data['show_party']!, _showPartyMeta),
      );
    }
    if (data.containsKey('show_vehicle_type')) {
      context.handle(
        _showVehicleTypeMeta,
        showVehicleType.isAcceptableOrUnknown(
          data['show_vehicle_type']!,
          _showVehicleTypeMeta,
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
    if (data.containsKey('show_amount')) {
      context.handle(
        _showAmountMeta,
        showAmount.isAcceptableOrUnknown(data['show_amount']!, _showAmountMeta),
      );
    }
    if (data.containsKey('show_payment_mode')) {
      context.handle(
        _showPaymentModeMeta,
        showPaymentMode.isAcceptableOrUnknown(
          data['show_payment_mode']!,
          _showPaymentModeMeta,
        ),
      );
    }
    if (data.containsKey('show_cash_received')) {
      context.handle(
        _showCashReceivedMeta,
        showCashReceived.isAcceptableOrUnknown(
          data['show_cash_received']!,
          _showCashReceivedMeta,
        ),
      );
    }
    if (data.containsKey('show_pending_amount')) {
      context.handle(
        _showPendingAmountMeta,
        showPendingAmount.isAcceptableOrUnknown(
          data['show_pending_amount']!,
          _showPendingAmountMeta,
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
      showMaterial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_material'],
      )!,
      showParty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_party'],
      )!,
      showVehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_vehicle_type'],
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
      showAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_amount'],
      )!,
      showPaymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_payment_mode'],
      )!,
      showCashReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_cash_received'],
      )!,
      showPendingAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_pending_amount'],
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
  final bool showMaterial;
  final bool showParty;
  final bool showVehicleType;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showAmount;
  final bool showPaymentMode;
  final bool showCashReceived;
  final bool showPendingAmount;
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
    required this.showMaterial,
    required this.showParty,
    required this.showVehicleType,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showAmount,
    required this.showPaymentMode,
    required this.showCashReceived,
    required this.showPendingAmount,
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
    map['show_material'] = Variable<bool>(showMaterial);
    map['show_party'] = Variable<bool>(showParty);
    map['show_vehicle_type'] = Variable<bool>(showVehicleType);
    map['show_gross_weight'] = Variable<bool>(showGrossWeight);
    map['show_tare_weight'] = Variable<bool>(showTareWeight);
    map['show_net_weight'] = Variable<bool>(showNetWeight);
    map['show_amount'] = Variable<bool>(showAmount);
    map['show_payment_mode'] = Variable<bool>(showPaymentMode);
    map['show_cash_received'] = Variable<bool>(showCashReceived);
    map['show_pending_amount'] = Variable<bool>(showPendingAmount);
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
      showMaterial: Value(showMaterial),
      showParty: Value(showParty),
      showVehicleType: Value(showVehicleType),
      showGrossWeight: Value(showGrossWeight),
      showTareWeight: Value(showTareWeight),
      showNetWeight: Value(showNetWeight),
      showAmount: Value(showAmount),
      showPaymentMode: Value(showPaymentMode),
      showCashReceived: Value(showCashReceived),
      showPendingAmount: Value(showPendingAmount),
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
      showMaterial: serializer.fromJson<bool>(json['showMaterial']),
      showParty: serializer.fromJson<bool>(json['showParty']),
      showVehicleType: serializer.fromJson<bool>(json['showVehicleType']),
      showGrossWeight: serializer.fromJson<bool>(json['showGrossWeight']),
      showTareWeight: serializer.fromJson<bool>(json['showTareWeight']),
      showNetWeight: serializer.fromJson<bool>(json['showNetWeight']),
      showAmount: serializer.fromJson<bool>(json['showAmount']),
      showPaymentMode: serializer.fromJson<bool>(json['showPaymentMode']),
      showCashReceived: serializer.fromJson<bool>(json['showCashReceived']),
      showPendingAmount: serializer.fromJson<bool>(json['showPendingAmount']),
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
      'showMaterial': serializer.toJson<bool>(showMaterial),
      'showParty': serializer.toJson<bool>(showParty),
      'showVehicleType': serializer.toJson<bool>(showVehicleType),
      'showGrossWeight': serializer.toJson<bool>(showGrossWeight),
      'showTareWeight': serializer.toJson<bool>(showTareWeight),
      'showNetWeight': serializer.toJson<bool>(showNetWeight),
      'showAmount': serializer.toJson<bool>(showAmount),
      'showPaymentMode': serializer.toJson<bool>(showPaymentMode),
      'showCashReceived': serializer.toJson<bool>(showCashReceived),
      'showPendingAmount': serializer.toJson<bool>(showPendingAmount),
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
    bool? showMaterial,
    bool? showParty,
    bool? showVehicleType,
    bool? showGrossWeight,
    bool? showTareWeight,
    bool? showNetWeight,
    bool? showAmount,
    bool? showPaymentMode,
    bool? showCashReceived,
    bool? showPendingAmount,
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
    showMaterial: showMaterial ?? this.showMaterial,
    showParty: showParty ?? this.showParty,
    showVehicleType: showVehicleType ?? this.showVehicleType,
    showGrossWeight: showGrossWeight ?? this.showGrossWeight,
    showTareWeight: showTareWeight ?? this.showTareWeight,
    showNetWeight: showNetWeight ?? this.showNetWeight,
    showAmount: showAmount ?? this.showAmount,
    showPaymentMode: showPaymentMode ?? this.showPaymentMode,
    showCashReceived: showCashReceived ?? this.showCashReceived,
    showPendingAmount: showPendingAmount ?? this.showPendingAmount,
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
      showMaterial: data.showMaterial.present
          ? data.showMaterial.value
          : this.showMaterial,
      showParty: data.showParty.present ? data.showParty.value : this.showParty,
      showVehicleType: data.showVehicleType.present
          ? data.showVehicleType.value
          : this.showVehicleType,
      showGrossWeight: data.showGrossWeight.present
          ? data.showGrossWeight.value
          : this.showGrossWeight,
      showTareWeight: data.showTareWeight.present
          ? data.showTareWeight.value
          : this.showTareWeight,
      showNetWeight: data.showNetWeight.present
          ? data.showNetWeight.value
          : this.showNetWeight,
      showAmount: data.showAmount.present
          ? data.showAmount.value
          : this.showAmount,
      showPaymentMode: data.showPaymentMode.present
          ? data.showPaymentMode.value
          : this.showPaymentMode,
      showCashReceived: data.showCashReceived.present
          ? data.showCashReceived.value
          : this.showCashReceived,
      showPendingAmount: data.showPendingAmount.present
          ? data.showPendingAmount.value
          : this.showPendingAmount,
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
          ..write('showMaterial: $showMaterial, ')
          ..write('showParty: $showParty, ')
          ..write('showVehicleType: $showVehicleType, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showAmount: $showAmount, ')
          ..write('showPaymentMode: $showPaymentMode, ')
          ..write('showCashReceived: $showCashReceived, ')
          ..write('showPendingAmount: $showPendingAmount, ')
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
    showMaterial,
    showParty,
    showVehicleType,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showAmount,
    showPaymentMode,
    showCashReceived,
    showPendingAmount,
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
          other.showMaterial == this.showMaterial &&
          other.showParty == this.showParty &&
          other.showVehicleType == this.showVehicleType &&
          other.showGrossWeight == this.showGrossWeight &&
          other.showTareWeight == this.showTareWeight &&
          other.showNetWeight == this.showNetWeight &&
          other.showAmount == this.showAmount &&
          other.showPaymentMode == this.showPaymentMode &&
          other.showCashReceived == this.showCashReceived &&
          other.showPendingAmount == this.showPendingAmount &&
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
  final Value<bool> showMaterial;
  final Value<bool> showParty;
  final Value<bool> showVehicleType;
  final Value<bool> showGrossWeight;
  final Value<bool> showTareWeight;
  final Value<bool> showNetWeight;
  final Value<bool> showAmount;
  final Value<bool> showPaymentMode;
  final Value<bool> showCashReceived;
  final Value<bool> showPendingAmount;
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
    this.showMaterial = const Value.absent(),
    this.showParty = const Value.absent(),
    this.showVehicleType = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showAmount = const Value.absent(),
    this.showPaymentMode = const Value.absent(),
    this.showCashReceived = const Value.absent(),
    this.showPendingAmount = const Value.absent(),
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
    this.showMaterial = const Value.absent(),
    this.showParty = const Value.absent(),
    this.showVehicleType = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showAmount = const Value.absent(),
    this.showPaymentMode = const Value.absent(),
    this.showCashReceived = const Value.absent(),
    this.showPendingAmount = const Value.absent(),
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
    Expression<bool>? showMaterial,
    Expression<bool>? showParty,
    Expression<bool>? showVehicleType,
    Expression<bool>? showGrossWeight,
    Expression<bool>? showTareWeight,
    Expression<bool>? showNetWeight,
    Expression<bool>? showAmount,
    Expression<bool>? showPaymentMode,
    Expression<bool>? showCashReceived,
    Expression<bool>? showPendingAmount,
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
      if (showMaterial != null) 'show_material': showMaterial,
      if (showParty != null) 'show_party': showParty,
      if (showVehicleType != null) 'show_vehicle_type': showVehicleType,
      if (showGrossWeight != null) 'show_gross_weight': showGrossWeight,
      if (showTareWeight != null) 'show_tare_weight': showTareWeight,
      if (showNetWeight != null) 'show_net_weight': showNetWeight,
      if (showAmount != null) 'show_amount': showAmount,
      if (showPaymentMode != null) 'show_payment_mode': showPaymentMode,
      if (showCashReceived != null) 'show_cash_received': showCashReceived,
      if (showPendingAmount != null) 'show_pending_amount': showPendingAmount,
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
    Value<bool>? showMaterial,
    Value<bool>? showParty,
    Value<bool>? showVehicleType,
    Value<bool>? showGrossWeight,
    Value<bool>? showTareWeight,
    Value<bool>? showNetWeight,
    Value<bool>? showAmount,
    Value<bool>? showPaymentMode,
    Value<bool>? showCashReceived,
    Value<bool>? showPendingAmount,
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
      showMaterial: showMaterial ?? this.showMaterial,
      showParty: showParty ?? this.showParty,
      showVehicleType: showVehicleType ?? this.showVehicleType,
      showGrossWeight: showGrossWeight ?? this.showGrossWeight,
      showTareWeight: showTareWeight ?? this.showTareWeight,
      showNetWeight: showNetWeight ?? this.showNetWeight,
      showAmount: showAmount ?? this.showAmount,
      showPaymentMode: showPaymentMode ?? this.showPaymentMode,
      showCashReceived: showCashReceived ?? this.showCashReceived,
      showPendingAmount: showPendingAmount ?? this.showPendingAmount,
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
    if (showMaterial.present) {
      map['show_material'] = Variable<bool>(showMaterial.value);
    }
    if (showParty.present) {
      map['show_party'] = Variable<bool>(showParty.value);
    }
    if (showVehicleType.present) {
      map['show_vehicle_type'] = Variable<bool>(showVehicleType.value);
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
    if (showAmount.present) {
      map['show_amount'] = Variable<bool>(showAmount.value);
    }
    if (showPaymentMode.present) {
      map['show_payment_mode'] = Variable<bool>(showPaymentMode.value);
    }
    if (showCashReceived.present) {
      map['show_cash_received'] = Variable<bool>(showCashReceived.value);
    }
    if (showPendingAmount.present) {
      map['show_pending_amount'] = Variable<bool>(showPendingAmount.value);
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
          ..write('showMaterial: $showMaterial, ')
          ..write('showParty: $showParty, ')
          ..write('showVehicleType: $showVehicleType, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showAmount: $showAmount, ')
          ..write('showPaymentMode: $showPaymentMode, ')
          ..write('showCashReceived: $showCashReceived, ')
          ..write('showPendingAmount: $showPendingAmount, ')
          ..write('showRemarks: $showRemarks, ')
          ..write('showFooterNote: $showFooterNote, ')
          ..write('footerNote: $footerNote, ')
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
  late final $VehicleTypesTable vehicleTypes = $VehicleTypesTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $WeighmentsTable weighments = $WeighmentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final PartyDao partyDao = PartyDao(this as AppDatabase);
  late final VehicleTypeDao vehicleTypeDao = VehicleTypeDao(
    this as AppDatabase,
  );
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final MaterialDao materialDao = MaterialDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    parties,
    vehicleTypes,
    vehicles,
    materials,
    weighments,
    appSettings,
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
          PrefetchHooks Function({bool weighmentsRefs})
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
          prefetchHooksCallback: ({weighmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (weighmentsRefs) db.weighments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (weighmentsRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Weighment>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._weighmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PartiesTableReferences(
                        db,
                        table,
                        p0,
                      ).weighmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partyId == item.id),
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
      PrefetchHooks Function({bool weighmentsRefs})
    >;
typedef $$VehicleTypesTableCreateCompanionBuilder =
    VehicleTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<double> emptyPrice,
      Value<double> loadPrice,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VehicleTypesTableUpdateCompanionBuilder =
    VehicleTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> emptyPrice,
      Value<double> loadPrice,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$VehicleTypesTableReferences
    extends BaseReferences<_$AppDatabase, $VehicleTypesTable, VehicleType> {
  $$VehicleTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiclesTable, List<Vehicle>> _vehiclesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: 'vehicle_types__id__vehicles__vehicle_type_id',
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.vehicleTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleTypesTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleTypesTable> {
  $$VehicleTypesTableFilterComposer({
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

  ColumnFilters<double> get emptyPrice => $composableBuilder(
    column: $table.emptyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loadPrice => $composableBuilder(
    column: $table.loadPrice,
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
      getReferencedColumn: (t) => t.vehicleTypeId,
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
}

class $$VehicleTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleTypesTable> {
  $$VehicleTypesTableOrderingComposer({
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

  ColumnOrderings<double> get emptyPrice => $composableBuilder(
    column: $table.emptyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loadPrice => $composableBuilder(
    column: $table.loadPrice,
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

class $$VehicleTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleTypesTable> {
  $$VehicleTypesTableAnnotationComposer({
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

  GeneratedColumn<double> get emptyPrice => $composableBuilder(
    column: $table.emptyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loadPrice =>
      $composableBuilder(column: $table.loadPrice, builder: (column) => column);

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
      getReferencedColumn: (t) => t.vehicleTypeId,
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
}

class $$VehicleTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleTypesTable,
          VehicleType,
          $$VehicleTypesTableFilterComposer,
          $$VehicleTypesTableOrderingComposer,
          $$VehicleTypesTableAnnotationComposer,
          $$VehicleTypesTableCreateCompanionBuilder,
          $$VehicleTypesTableUpdateCompanionBuilder,
          (VehicleType, $$VehicleTypesTableReferences),
          VehicleType,
          PrefetchHooks Function({bool vehiclesRefs})
        > {
  $$VehicleTypesTableTableManager(_$AppDatabase db, $VehicleTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> emptyPrice = const Value.absent(),
                Value<double> loadPrice = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehicleTypesCompanion(
                id: id,
                name: name,
                emptyPrice: emptyPrice,
                loadPrice: loadPrice,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<double> emptyPrice = const Value.absent(),
                Value<double> loadPrice = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehicleTypesCompanion.insert(
                id: id,
                name: name,
                emptyPrice: emptyPrice,
                loadPrice: loadPrice,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehiclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vehiclesRefs) db.vehicles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vehiclesRefs)
                    await $_getPrefetchedData<
                      VehicleType,
                      $VehicleTypesTable,
                      Vehicle
                    >(
                      currentTable: table,
                      referencedTable: $$VehicleTypesTableReferences
                          ._vehiclesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VehicleTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).vehiclesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.vehicleTypeId == item.id,
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

typedef $$VehicleTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleTypesTable,
      VehicleType,
      $$VehicleTypesTableFilterComposer,
      $$VehicleTypesTableOrderingComposer,
      $$VehicleTypesTableAnnotationComposer,
      $$VehicleTypesTableCreateCompanionBuilder,
      $$VehicleTypesTableUpdateCompanionBuilder,
      (VehicleType, $$VehicleTypesTableReferences),
      VehicleType,
      PrefetchHooks Function({bool vehiclesRefs})
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String vehicleNumber,
      required int vehicleTypeId,
      Value<String?> driverName,
      Value<String?> driverPhone,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> vehicleNumber,
      Value<int> vehicleTypeId,
      Value<String?> driverName,
      Value<String?> driverPhone,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehicleTypesTable _vehicleTypeIdTable(_$AppDatabase db) => db
      .vehicleTypes
      .createAlias('vehicles__vehicle_type_id__vehicle_types__id');

  $$VehicleTypesTableProcessedTableManager get vehicleTypeId {
    final $_column = $_itemColumn<int>('vehicle_type_id')!;

    final manager = $$VehicleTypesTableTableManager(
      $_db,
      $_db.vehicleTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleTypeIdTable($_db));
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

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
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

  $$VehicleTypesTableFilterComposer get vehicleTypeId {
    final $$VehicleTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleTypeId,
      referencedTable: $db.vehicleTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleTypesTableFilterComposer(
            $db: $db,
            $table: $db.vehicleTypes,
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

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
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

  $$VehicleTypesTableOrderingComposer get vehicleTypeId {
    final $$VehicleTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleTypeId,
      referencedTable: $db.vehicleTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleTypesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleTypes,
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

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverPhone => $composableBuilder(
    column: $table.driverPhone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehicleTypesTableAnnotationComposer get vehicleTypeId {
    final $$VehicleTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleTypeId,
      referencedTable: $db.vehicleTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleTypes,
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
          PrefetchHooks Function({bool vehicleTypeId, bool weighmentsRefs})
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
                Value<int> vehicleTypeId = const Value.absent(),
                Value<String?> driverName = const Value.absent(),
                Value<String?> driverPhone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                vehicleNumber: vehicleNumber,
                vehicleTypeId: vehicleTypeId,
                driverName: driverName,
                driverPhone: driverPhone,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vehicleNumber,
                required int vehicleTypeId,
                Value<String?> driverName = const Value.absent(),
                Value<String?> driverPhone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                vehicleNumber: vehicleNumber,
                vehicleTypeId: vehicleTypeId,
                driverName: driverName,
                driverPhone: driverPhone,
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
          prefetchHooksCallback:
              ({vehicleTypeId = false, weighmentsRefs = false}) {
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
                        if (vehicleTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleTypeId,
                                    referencedTable: $$VehiclesTableReferences
                                        ._vehicleTypeIdTable(db),
                                    referencedColumn: $$VehiclesTableReferences
                                        ._vehicleTypeIdTable(db)
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
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).weighmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
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
      PrefetchHooks Function({bool vehicleTypeId, bool weighmentsRefs})
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> category,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> category,
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
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                name: name,
                category: category,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                name: name,
                category: category,
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
      required String paymentMode,
      required double firstWeightKg,
      Value<String> firstWeightType,
      Value<double?> secondWeightKg,
      Value<String?> secondWeightType,
      Value<double?> netWeightKg,
      Value<double> vehicleCharge,
      Value<double> amount,
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
      Value<String> paymentMode,
      Value<double> firstWeightKg,
      Value<String> firstWeightType,
      Value<double?> secondWeightKg,
      Value<String?> secondWeightType,
      Value<double?> netWeightKg,
      Value<double> vehicleCharge,
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

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
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

  ColumnFilters<double> get vehicleCharge => $composableBuilder(
    column: $table.vehicleCharge,
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

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
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

  ColumnOrderings<double> get vehicleCharge => $composableBuilder(
    column: $table.vehicleCharge,
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

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
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

  GeneratedColumn<double> get vehicleCharge => $composableBuilder(
    column: $table.vehicleCharge,
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
                Value<String> paymentMode = const Value.absent(),
                Value<double> firstWeightKg = const Value.absent(),
                Value<String> firstWeightType = const Value.absent(),
                Value<double?> secondWeightKg = const Value.absent(),
                Value<String?> secondWeightType = const Value.absent(),
                Value<double?> netWeightKg = const Value.absent(),
                Value<double> vehicleCharge = const Value.absent(),
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
                paymentMode: paymentMode,
                firstWeightKg: firstWeightKg,
                firstWeightType: firstWeightType,
                secondWeightKg: secondWeightKg,
                secondWeightType: secondWeightType,
                netWeightKg: netWeightKg,
                vehicleCharge: vehicleCharge,
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
                required String paymentMode,
                required double firstWeightKg,
                Value<String> firstWeightType = const Value.absent(),
                Value<double?> secondWeightKg = const Value.absent(),
                Value<String?> secondWeightType = const Value.absent(),
                Value<double?> netWeightKg = const Value.absent(),
                Value<double> vehicleCharge = const Value.absent(),
                Value<double> amount = const Value.absent(),
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
                paymentMode: paymentMode,
                firstWeightKg: firstWeightKg,
                firstWeightType: firstWeightType,
                secondWeightKg: secondWeightKg,
                secondWeightType: secondWeightType,
                netWeightKg: netWeightKg,
                vehicleCharge: vehicleCharge,
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
      Value<bool> showMaterial,
      Value<bool> showParty,
      Value<bool> showVehicleType,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showAmount,
      Value<bool> showPaymentMode,
      Value<bool> showCashReceived,
      Value<bool> showPendingAmount,
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
      Value<bool> showMaterial,
      Value<bool> showParty,
      Value<bool> showVehicleType,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showAmount,
      Value<bool> showPaymentMode,
      Value<bool> showCashReceived,
      Value<bool> showPendingAmount,
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

  ColumnFilters<bool> get showMaterial => $composableBuilder(
    column: $table.showMaterial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showParty => $composableBuilder(
    column: $table.showParty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showVehicleType => $composableBuilder(
    column: $table.showVehicleType,
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

  ColumnFilters<bool> get showAmount => $composableBuilder(
    column: $table.showAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPaymentMode => $composableBuilder(
    column: $table.showPaymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showCashReceived => $composableBuilder(
    column: $table.showCashReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPendingAmount => $composableBuilder(
    column: $table.showPendingAmount,
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

  ColumnOrderings<bool> get showMaterial => $composableBuilder(
    column: $table.showMaterial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showParty => $composableBuilder(
    column: $table.showParty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVehicleType => $composableBuilder(
    column: $table.showVehicleType,
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

  ColumnOrderings<bool> get showAmount => $composableBuilder(
    column: $table.showAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPaymentMode => $composableBuilder(
    column: $table.showPaymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showCashReceived => $composableBuilder(
    column: $table.showCashReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPendingAmount => $composableBuilder(
    column: $table.showPendingAmount,
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

  GeneratedColumn<bool> get showMaterial => $composableBuilder(
    column: $table.showMaterial,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showParty =>
      $composableBuilder(column: $table.showParty, builder: (column) => column);

  GeneratedColumn<bool> get showVehicleType => $composableBuilder(
    column: $table.showVehicleType,
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

  GeneratedColumn<bool> get showAmount => $composableBuilder(
    column: $table.showAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showPaymentMode => $composableBuilder(
    column: $table.showPaymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showCashReceived => $composableBuilder(
    column: $table.showCashReceived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showPendingAmount => $composableBuilder(
    column: $table.showPendingAmount,
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
                Value<bool> showMaterial = const Value.absent(),
                Value<bool> showParty = const Value.absent(),
                Value<bool> showVehicleType = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showAmount = const Value.absent(),
                Value<bool> showPaymentMode = const Value.absent(),
                Value<bool> showCashReceived = const Value.absent(),
                Value<bool> showPendingAmount = const Value.absent(),
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
                showMaterial: showMaterial,
                showParty: showParty,
                showVehicleType: showVehicleType,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showAmount: showAmount,
                showPaymentMode: showPaymentMode,
                showCashReceived: showCashReceived,
                showPendingAmount: showPendingAmount,
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
                Value<bool> showMaterial = const Value.absent(),
                Value<bool> showParty = const Value.absent(),
                Value<bool> showVehicleType = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showAmount = const Value.absent(),
                Value<bool> showPaymentMode = const Value.absent(),
                Value<bool> showCashReceived = const Value.absent(),
                Value<bool> showPendingAmount = const Value.absent(),
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
                showMaterial: showMaterial,
                showParty: showParty,
                showVehicleType: showVehicleType,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showAmount: showAmount,
                showPaymentMode: showPaymentMode,
                showCashReceived: showCashReceived,
                showPendingAmount: showPendingAmount,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$VehicleTypesTableTableManager get vehicleTypes =>
      $$VehicleTypesTableTableManager(_db, _db.vehicleTypes);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db, _db.weighments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
