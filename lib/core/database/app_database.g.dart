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

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerCodeMeta = const VerificationMeta(
    'customerCode',
  );
  @override
  late final GeneratedColumn<String> customerCode = GeneratedColumn<String>(
    'customer_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
    customerCode,
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
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_code')) {
      context.handle(
        _customerCodeMeta,
        customerCode.isAcceptableOrUnknown(
          data['customer_code']!,
          _customerCodeMeta,
        ),
      );
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
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_code'],
      ),
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
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String? customerCode;
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
  const Customer({
    required this.id,
    this.customerCode,
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
    if (!nullToAbsent || customerCode != null) {
      map['customer_code'] = Variable<String>(customerCode);
    }
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

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      customerCode: customerCode == null && nullToAbsent
          ? const Value.absent()
          : Value(customerCode),
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

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      customerCode: serializer.fromJson<String?>(json['customerCode']),
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
      'customerCode': serializer.toJson<String?>(customerCode),
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

  Customer copyWith({
    int? id,
    Value<String?> customerCode = const Value.absent(),
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
  }) => Customer(
    id: id ?? this.id,
    customerCode: customerCode.present ? customerCode.value : this.customerCode,
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
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      customerCode: data.customerCode.present
          ? data.customerCode.value
          : this.customerCode,
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
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('customerCode: $customerCode, ')
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
    customerCode,
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
      (other is Customer &&
          other.id == this.id &&
          other.customerCode == this.customerCode &&
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

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String?> customerCode;
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
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.customerCode = const Value.absent(),
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
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    this.customerCode = const Value.absent(),
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
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? customerCode,
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
      if (customerCode != null) 'customer_code': customerCode,
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

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String?>? customerCode,
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
    return CustomersCompanion(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
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
    if (customerCode.present) {
      map['customer_code'] = Variable<String>(customerCode.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('customerCode: $customerCode, ')
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
    code,
    name,
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
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
  final String code;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Material({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
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
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
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
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Material copyWith({
    int? id,
    String? code,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Material(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Material(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<Material> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('code: $code, ')
          ..write('name: $name, ')
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
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
    customerId,
    vehicleNumber,
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
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
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
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      vehicleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_number'],
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
  final int customerId;
  final String vehicleNumber;
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
  final String weightUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Weighment({
    required this.id,
    required this.billNumber,
    required this.customerId,
    required this.vehicleNumber,
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
    required this.weightUnit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_number'] = Variable<String>(billNumber);
    map['customer_id'] = Variable<int>(customerId);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
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
    map['weight_unit'] = Variable<String>(weightUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeighmentsCompanion toCompanion(bool nullToAbsent) {
    return WeighmentsCompanion(
      id: Value(id),
      billNumber: Value(billNumber),
      customerId: Value(customerId),
      vehicleNumber: Value(vehicleNumber),
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
      customerId: serializer.fromJson<int>(json['customerId']),
      vehicleNumber: serializer.fromJson<String>(json['vehicleNumber']),
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
      'customerId': serializer.toJson<int>(customerId),
      'vehicleNumber': serializer.toJson<String>(vehicleNumber),
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
      'weightUnit': serializer.toJson<String>(weightUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Weighment copyWith({
    int? id,
    String? billNumber,
    int? customerId,
    String? vehicleNumber,
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
    String? weightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Weighment(
    id: id ?? this.id,
    billNumber: billNumber ?? this.billNumber,
    customerId: customerId ?? this.customerId,
    vehicleNumber: vehicleNumber ?? this.vehicleNumber,
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
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
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
          ..write('customerId: $customerId, ')
          ..write('vehicleNumber: $vehicleNumber, ')
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
    customerId,
    vehicleNumber,
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
          other.customerId == this.customerId &&
          other.vehicleNumber == this.vehicleNumber &&
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
          other.weightUnit == this.weightUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeighmentsCompanion extends UpdateCompanion<Weighment> {
  final Value<int> id;
  final Value<String> billNumber;
  final Value<int> customerId;
  final Value<String> vehicleNumber;
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
  final Value<String> weightUnit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeighmentsCompanion({
    this.id = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
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
    this.weightUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeighmentsCompanion.insert({
    this.id = const Value.absent(),
    required String billNumber,
    required int customerId,
    required String vehicleNumber,
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
    this.weightUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : billNumber = Value(billNumber),
       customerId = Value(customerId),
       vehicleNumber = Value(vehicleNumber),
       materialId = Value(materialId),
       paymentMode = Value(paymentMode),
       firstWeightKg = Value(firstWeightKg);
  static Insertable<Weighment> custom({
    Expression<int>? id,
    Expression<String>? billNumber,
    Expression<int>? customerId,
    Expression<String>? vehicleNumber,
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
    Expression<String>? weightUnit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billNumber != null) 'bill_number': billNumber,
      if (customerId != null) 'customer_id': customerId,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
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
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeighmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? billNumber,
    Value<int>? customerId,
    Value<String>? vehicleNumber,
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
    Value<String>? weightUnit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeighmentsCompanion(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      customerId: customerId ?? this.customerId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
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
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
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
          ..write('customerId: $customerId, ')
          ..write('vehicleNumber: $vehicleNumber, ')
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
  static const VerificationMeta _showCustomerMeta = const VerificationMeta(
    'showCustomer',
  );
  @override
  late final GeneratedColumn<bool> showCustomer = GeneratedColumn<bool>(
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
    showCustomer,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showAmount,
    showPaymentMode,
    showCashReceived,
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
        _showCustomerMeta,
        showCustomer.isAcceptableOrUnknown(
          data['show_party']!,
          _showCustomerMeta,
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
      showCustomer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_party'],
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
  final bool showCustomer;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showAmount;
  final bool showPaymentMode;
  final bool showCashReceived;
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
    required this.showCustomer,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showAmount,
    required this.showPaymentMode,
    required this.showCashReceived,
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
    map['show_party'] = Variable<bool>(showCustomer);
    map['show_gross_weight'] = Variable<bool>(showGrossWeight);
    map['show_tare_weight'] = Variable<bool>(showTareWeight);
    map['show_net_weight'] = Variable<bool>(showNetWeight);
    map['show_amount'] = Variable<bool>(showAmount);
    map['show_payment_mode'] = Variable<bool>(showPaymentMode);
    map['show_cash_received'] = Variable<bool>(showCashReceived);
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
      showCustomer: Value(showCustomer),
      showGrossWeight: Value(showGrossWeight),
      showTareWeight: Value(showTareWeight),
      showNetWeight: Value(showNetWeight),
      showAmount: Value(showAmount),
      showPaymentMode: Value(showPaymentMode),
      showCashReceived: Value(showCashReceived),
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
      showCustomer: serializer.fromJson<bool>(json['showCustomer']),
      showGrossWeight: serializer.fromJson<bool>(json['showGrossWeight']),
      showTareWeight: serializer.fromJson<bool>(json['showTareWeight']),
      showNetWeight: serializer.fromJson<bool>(json['showNetWeight']),
      showAmount: serializer.fromJson<bool>(json['showAmount']),
      showPaymentMode: serializer.fromJson<bool>(json['showPaymentMode']),
      showCashReceived: serializer.fromJson<bool>(json['showCashReceived']),
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
      'showCustomer': serializer.toJson<bool>(showCustomer),
      'showGrossWeight': serializer.toJson<bool>(showGrossWeight),
      'showTareWeight': serializer.toJson<bool>(showTareWeight),
      'showNetWeight': serializer.toJson<bool>(showNetWeight),
      'showAmount': serializer.toJson<bool>(showAmount),
      'showPaymentMode': serializer.toJson<bool>(showPaymentMode),
      'showCashReceived': serializer.toJson<bool>(showCashReceived),
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
    bool? showCustomer,
    bool? showGrossWeight,
    bool? showTareWeight,
    bool? showNetWeight,
    bool? showAmount,
    bool? showPaymentMode,
    bool? showCashReceived,
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
    showCustomer: showCustomer ?? this.showCustomer,
    showGrossWeight: showGrossWeight ?? this.showGrossWeight,
    showTareWeight: showTareWeight ?? this.showTareWeight,
    showNetWeight: showNetWeight ?? this.showNetWeight,
    showAmount: showAmount ?? this.showAmount,
    showPaymentMode: showPaymentMode ?? this.showPaymentMode,
    showCashReceived: showCashReceived ?? this.showCashReceived,
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
      showCustomer: data.showCustomer.present
          ? data.showCustomer.value
          : this.showCustomer,
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
          ..write('showCustomer: $showCustomer, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showAmount: $showAmount, ')
          ..write('showPaymentMode: $showPaymentMode, ')
          ..write('showCashReceived: $showCashReceived, ')
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
    showCustomer,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showAmount,
    showPaymentMode,
    showCashReceived,
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
          other.showCustomer == this.showCustomer &&
          other.showGrossWeight == this.showGrossWeight &&
          other.showTareWeight == this.showTareWeight &&
          other.showNetWeight == this.showNetWeight &&
          other.showAmount == this.showAmount &&
          other.showPaymentMode == this.showPaymentMode &&
          other.showCashReceived == this.showCashReceived &&
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
  final Value<bool> showCustomer;
  final Value<bool> showGrossWeight;
  final Value<bool> showTareWeight;
  final Value<bool> showNetWeight;
  final Value<bool> showAmount;
  final Value<bool> showPaymentMode;
  final Value<bool> showCashReceived;
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
    this.showCustomer = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showAmount = const Value.absent(),
    this.showPaymentMode = const Value.absent(),
    this.showCashReceived = const Value.absent(),
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
    this.showCustomer = const Value.absent(),
    this.showGrossWeight = const Value.absent(),
    this.showTareWeight = const Value.absent(),
    this.showNetWeight = const Value.absent(),
    this.showAmount = const Value.absent(),
    this.showPaymentMode = const Value.absent(),
    this.showCashReceived = const Value.absent(),
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
    Expression<bool>? showCustomer,
    Expression<bool>? showGrossWeight,
    Expression<bool>? showTareWeight,
    Expression<bool>? showNetWeight,
    Expression<bool>? showAmount,
    Expression<bool>? showPaymentMode,
    Expression<bool>? showCashReceived,
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
      if (showCustomer != null) 'show_party': showCustomer,
      if (showGrossWeight != null) 'show_gross_weight': showGrossWeight,
      if (showTareWeight != null) 'show_tare_weight': showTareWeight,
      if (showNetWeight != null) 'show_net_weight': showNetWeight,
      if (showAmount != null) 'show_amount': showAmount,
      if (showPaymentMode != null) 'show_payment_mode': showPaymentMode,
      if (showCashReceived != null) 'show_cash_received': showCashReceived,
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
    Value<bool>? showCustomer,
    Value<bool>? showGrossWeight,
    Value<bool>? showTareWeight,
    Value<bool>? showNetWeight,
    Value<bool>? showAmount,
    Value<bool>? showPaymentMode,
    Value<bool>? showCashReceived,
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
      showCustomer: showCustomer ?? this.showCustomer,
      showGrossWeight: showGrossWeight ?? this.showGrossWeight,
      showTareWeight: showTareWeight ?? this.showTareWeight,
      showNetWeight: showNetWeight ?? this.showNetWeight,
      showAmount: showAmount ?? this.showAmount,
      showPaymentMode: showPaymentMode ?? this.showPaymentMode,
      showCashReceived: showCashReceived ?? this.showCashReceived,
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
    if (showCustomer.present) {
      map['show_party'] = Variable<bool>(showCustomer.value);
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
          ..write('showCustomer: $showCustomer, ')
          ..write('showGrossWeight: $showGrossWeight, ')
          ..write('showTareWeight: $showTareWeight, ')
          ..write('showNetWeight: $showNetWeight, ')
          ..write('showAmount: $showAmount, ')
          ..write('showPaymentMode: $showPaymentMode, ')
          ..write('showCashReceived: $showCashReceived, ')
          ..write('showRemarks: $showRemarks, ')
          ..write('showFooterNote: $showFooterNote, ')
          ..write('footerNote: $footerNote, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChargeVehicleTypesTable extends ChargeVehicleTypes
    with TableInfo<$ChargeVehicleTypesTable, ChargeVehicleType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChargeVehicleTypesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'charge_vehicle_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChargeVehicleType> instance, {
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
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChargeVehicleType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChargeVehicleType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $ChargeVehicleTypesTable createAlias(String alias) {
    return $ChargeVehicleTypesTable(attachedDatabase, alias);
  }
}

class ChargeVehicleType extends DataClass
    implements Insertable<ChargeVehicleType> {
  final int id;
  final String name;
  final bool isActive;
  const ChargeVehicleType({
    required this.id,
    required this.name,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ChargeVehicleTypesCompanion toCompanion(bool nullToAbsent) {
    return ChargeVehicleTypesCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
    );
  }

  factory ChargeVehicleType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChargeVehicleType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ChargeVehicleType copyWith({int? id, String? name, bool? isActive}) =>
      ChargeVehicleType(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
      );
  ChargeVehicleType copyWithCompanion(ChargeVehicleTypesCompanion data) {
    return ChargeVehicleType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChargeVehicleType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChargeVehicleType &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive);
}

class ChargeVehicleTypesCompanion extends UpdateCompanion<ChargeVehicleType> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  const ChargeVehicleTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ChargeVehicleTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ChargeVehicleType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ChargeVehicleTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
  }) {
    return ChargeVehicleTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
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
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChargeVehicleTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $WeighmentRatesTable extends WeighmentRates
    with TableInfo<$WeighmentRatesTable, WeighmentRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeighmentRatesTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES charge_vehicle_types (id)',
    ),
  );
  static const VerificationMeta _rateTypeMeta = const VerificationMeta(
    'rateType',
  );
  @override
  late final GeneratedColumn<String> rateType = GeneratedColumn<String>(
    'rate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightLimitMeta = const VerificationMeta(
    'weightLimit',
  );
  @override
  late final GeneratedColumn<double> weightLimit = GeneratedColumn<double>(
    'weight_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleTypeId,
    rateType,
    weightLimit,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weighment_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeighmentRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('rate_type')) {
      context.handle(
        _rateTypeMeta,
        rateType.isAcceptableOrUnknown(data['rate_type']!, _rateTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_rateTypeMeta);
    }
    if (data.containsKey('weight_limit')) {
      context.handle(
        _weightLimitMeta,
        weightLimit.isAcceptableOrUnknown(
          data['weight_limit']!,
          _weightLimitMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeighmentRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeighmentRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_type_id'],
      )!,
      rateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_type'],
      )!,
      weightLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_limit'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $WeighmentRatesTable createAlias(String alias) {
    return $WeighmentRatesTable(attachedDatabase, alias);
  }
}

class WeighmentRate extends DataClass implements Insertable<WeighmentRate> {
  final int id;
  final int vehicleTypeId;
  final String rateType;
  final double? weightLimit;
  final double amount;
  const WeighmentRate({
    required this.id,
    required this.vehicleTypeId,
    required this.rateType,
    this.weightLimit,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_type_id'] = Variable<int>(vehicleTypeId);
    map['rate_type'] = Variable<String>(rateType);
    if (!nullToAbsent || weightLimit != null) {
      map['weight_limit'] = Variable<double>(weightLimit);
    }
    map['amount'] = Variable<double>(amount);
    return map;
  }

  WeighmentRatesCompanion toCompanion(bool nullToAbsent) {
    return WeighmentRatesCompanion(
      id: Value(id),
      vehicleTypeId: Value(vehicleTypeId),
      rateType: Value(rateType),
      weightLimit: weightLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(weightLimit),
      amount: Value(amount),
    );
  }

  factory WeighmentRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeighmentRate(
      id: serializer.fromJson<int>(json['id']),
      vehicleTypeId: serializer.fromJson<int>(json['vehicleTypeId']),
      rateType: serializer.fromJson<String>(json['rateType']),
      weightLimit: serializer.fromJson<double?>(json['weightLimit']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleTypeId': serializer.toJson<int>(vehicleTypeId),
      'rateType': serializer.toJson<String>(rateType),
      'weightLimit': serializer.toJson<double?>(weightLimit),
      'amount': serializer.toJson<double>(amount),
    };
  }

  WeighmentRate copyWith({
    int? id,
    int? vehicleTypeId,
    String? rateType,
    Value<double?> weightLimit = const Value.absent(),
    double? amount,
  }) => WeighmentRate(
    id: id ?? this.id,
    vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
    rateType: rateType ?? this.rateType,
    weightLimit: weightLimit.present ? weightLimit.value : this.weightLimit,
    amount: amount ?? this.amount,
  );
  WeighmentRate copyWithCompanion(WeighmentRatesCompanion data) {
    return WeighmentRate(
      id: data.id.present ? data.id.value : this.id,
      vehicleTypeId: data.vehicleTypeId.present
          ? data.vehicleTypeId.value
          : this.vehicleTypeId,
      rateType: data.rateType.present ? data.rateType.value : this.rateType,
      weightLimit: data.weightLimit.present
          ? data.weightLimit.value
          : this.weightLimit,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeighmentRate(')
          ..write('id: $id, ')
          ..write('vehicleTypeId: $vehicleTypeId, ')
          ..write('rateType: $rateType, ')
          ..write('weightLimit: $weightLimit, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleTypeId, rateType, weightLimit, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeighmentRate &&
          other.id == this.id &&
          other.vehicleTypeId == this.vehicleTypeId &&
          other.rateType == this.rateType &&
          other.weightLimit == this.weightLimit &&
          other.amount == this.amount);
}

class WeighmentRatesCompanion extends UpdateCompanion<WeighmentRate> {
  final Value<int> id;
  final Value<int> vehicleTypeId;
  final Value<String> rateType;
  final Value<double?> weightLimit;
  final Value<double> amount;
  const WeighmentRatesCompanion({
    this.id = const Value.absent(),
    this.vehicleTypeId = const Value.absent(),
    this.rateType = const Value.absent(),
    this.weightLimit = const Value.absent(),
    this.amount = const Value.absent(),
  });
  WeighmentRatesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleTypeId,
    required String rateType,
    this.weightLimit = const Value.absent(),
    required double amount,
  }) : vehicleTypeId = Value(vehicleTypeId),
       rateType = Value(rateType),
       amount = Value(amount);
  static Insertable<WeighmentRate> custom({
    Expression<int>? id,
    Expression<int>? vehicleTypeId,
    Expression<String>? rateType,
    Expression<double>? weightLimit,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleTypeId != null) 'vehicle_type_id': vehicleTypeId,
      if (rateType != null) 'rate_type': rateType,
      if (weightLimit != null) 'weight_limit': weightLimit,
      if (amount != null) 'amount': amount,
    });
  }

  WeighmentRatesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleTypeId,
    Value<String>? rateType,
    Value<double?>? weightLimit,
    Value<double>? amount,
  }) {
    return WeighmentRatesCompanion(
      id: id ?? this.id,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      rateType: rateType ?? this.rateType,
      weightLimit: weightLimit ?? this.weightLimit,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleTypeId.present) {
      map['vehicle_type_id'] = Variable<int>(vehicleTypeId.value);
    }
    if (rateType.present) {
      map['rate_type'] = Variable<String>(rateType.value);
    }
    if (weightLimit.present) {
      map['weight_limit'] = Variable<double>(weightLimit.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeighmentRatesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleTypeId: $vehicleTypeId, ')
          ..write('rateType: $rateType, ')
          ..write('weightLimit: $weightLimit, ')
          ..write('amount: $amount')
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
  late final $CustomersTable customers = $CustomersTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $WeighmentsTable weighments = $WeighmentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ChargeVehicleTypesTable chargeVehicleTypes =
      $ChargeVehicleTypesTable(this);
  late final $WeighmentRatesTable weighmentRates = $WeighmentRatesTable(this);
  late final $ScaleSettingsTable scaleSettings = $ScaleSettingsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final CustomerDao customerDao = CustomerDao(this as AppDatabase);
  late final MaterialDao materialDao = MaterialDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
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
    customers,
    materials,
    weighments,
    appSettings,
    chargeVehicleTypes,
    weighmentRates,
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
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String?> customerCode,
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
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String?> customerCode,
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

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WeighmentsTable, List<Weighment>>
  _weighmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weighments,
    aliasName: 'customers__id__weighments__customer_id',
  );

  $$WeighmentsTableProcessedTableManager get weighmentsRefs {
    final manager = $$WeighmentsTableTableManager(
      $_db,
      $_db.weighments,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weighmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
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
      getReferencedColumn: (t) => t.customerId,
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

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
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

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => column,
  );

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
      getReferencedColumn: (t) => t.customerId,
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

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool weighmentsRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> customerCode = const Value.absent(),
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
              }) => CustomersCompanion(
                id: id,
                customerCode: customerCode,
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
                Value<String?> customerCode = const Value.absent(),
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
              }) => CustomersCompanion.insert(
                id: id,
                customerCode: customerCode,
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
                  $$CustomersTableReferences(db, table, e),
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
                      Customer,
                      $CustomersTable,
                      Weighment
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._weighmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(
                            db,
                            table,
                            p0,
                          ).weighmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool weighmentsRefs})
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      required String code,
      required String name,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                code: code,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                code: code,
                name: name,
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
      required int customerId,
      required String vehicleNumber,
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
      Value<String> weightUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WeighmentsTableUpdateCompanionBuilder =
    WeighmentsCompanion Function({
      Value<int> id,
      Value<String> billNumber,
      Value<int> customerId,
      Value<String> vehicleNumber,
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
      Value<String> weightUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WeighmentsTableReferences
    extends BaseReferences<_$AppDatabase, $WeighmentsTable, Weighment> {
  $$WeighmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('weighments__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
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

  ColumnFilters<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
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

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
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

  ColumnOrderings<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
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

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
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

  GeneratedColumn<String> get vehicleNumber => $composableBuilder(
    column: $table.vehicleNumber,
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

  GeneratedColumn<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
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
          PrefetchHooks Function({bool customerId, bool materialId})
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
                Value<int> customerId = const Value.absent(),
                Value<String> vehicleNumber = const Value.absent(),
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
                Value<String> weightUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion(
                id: id,
                billNumber: billNumber,
                customerId: customerId,
                vehicleNumber: vehicleNumber,
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
                weightUnit: weightUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String billNumber,
                required int customerId,
                required String vehicleNumber,
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
                Value<String> weightUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeighmentsCompanion.insert(
                id: id,
                billNumber: billNumber,
                customerId: customerId,
                vehicleNumber: vehicleNumber,
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
                weightUnit: weightUnit,
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
          prefetchHooksCallback: ({customerId = false, materialId = false}) {
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
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$WeighmentsTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$WeighmentsTableReferences
                                    ._customerIdTable(db)
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
                                referencedColumn: $$WeighmentsTableReferences
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
      PrefetchHooks Function({bool customerId, bool materialId})
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
      Value<bool> showCustomer,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showAmount,
      Value<bool> showPaymentMode,
      Value<bool> showCashReceived,
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
      Value<bool> showCustomer,
      Value<bool> showGrossWeight,
      Value<bool> showTareWeight,
      Value<bool> showNetWeight,
      Value<bool> showAmount,
      Value<bool> showPaymentMode,
      Value<bool> showCashReceived,
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

  ColumnFilters<bool> get showCustomer => $composableBuilder(
    column: $table.showCustomer,
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

  ColumnOrderings<bool> get showCustomer => $composableBuilder(
    column: $table.showCustomer,
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

  GeneratedColumn<bool> get showCustomer => $composableBuilder(
    column: $table.showCustomer,
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
                Value<bool> showCustomer = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showAmount = const Value.absent(),
                Value<bool> showPaymentMode = const Value.absent(),
                Value<bool> showCashReceived = const Value.absent(),
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
                showCustomer: showCustomer,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showAmount: showAmount,
                showPaymentMode: showPaymentMode,
                showCashReceived: showCashReceived,
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
                Value<bool> showCustomer = const Value.absent(),
                Value<bool> showGrossWeight = const Value.absent(),
                Value<bool> showTareWeight = const Value.absent(),
                Value<bool> showNetWeight = const Value.absent(),
                Value<bool> showAmount = const Value.absent(),
                Value<bool> showPaymentMode = const Value.absent(),
                Value<bool> showCashReceived = const Value.absent(),
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
                showCustomer: showCustomer,
                showGrossWeight: showGrossWeight,
                showTareWeight: showTareWeight,
                showNetWeight: showNetWeight,
                showAmount: showAmount,
                showPaymentMode: showPaymentMode,
                showCashReceived: showCashReceived,
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
typedef $$ChargeVehicleTypesTableCreateCompanionBuilder =
    ChargeVehicleTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
    });
typedef $$ChargeVehicleTypesTableUpdateCompanionBuilder =
    ChargeVehicleTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
    });

final class $$ChargeVehicleTypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChargeVehicleTypesTable,
          ChargeVehicleType
        > {
  $$ChargeVehicleTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WeighmentRatesTable, List<WeighmentRate>>
  _weighmentRatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weighmentRates,
    aliasName: 'charge_vehicle_types__id__weighment_rates__vehicle_type_id',
  );

  $$WeighmentRatesTableProcessedTableManager get weighmentRatesRefs {
    final manager = $$WeighmentRatesTableTableManager(
      $_db,
      $_db.weighmentRates,
    ).filter((f) => f.vehicleTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weighmentRatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChargeVehicleTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ChargeVehicleTypesTable> {
  $$ChargeVehicleTypesTableFilterComposer({
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

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> weighmentRatesRefs(
    Expression<bool> Function($$WeighmentRatesTableFilterComposer f) f,
  ) {
    final $$WeighmentRatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighmentRates,
      getReferencedColumn: (t) => t.vehicleTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentRatesTableFilterComposer(
            $db: $db,
            $table: $db.weighmentRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChargeVehicleTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChargeVehicleTypesTable> {
  $$ChargeVehicleTypesTableOrderingComposer({
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

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChargeVehicleTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChargeVehicleTypesTable> {
  $$ChargeVehicleTypesTableAnnotationComposer({
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

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> weighmentRatesRefs<T extends Object>(
    Expression<T> Function($$WeighmentRatesTableAnnotationComposer a) f,
  ) {
    final $$WeighmentRatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weighmentRates,
      getReferencedColumn: (t) => t.vehicleTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeighmentRatesTableAnnotationComposer(
            $db: $db,
            $table: $db.weighmentRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChargeVehicleTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChargeVehicleTypesTable,
          ChargeVehicleType,
          $$ChargeVehicleTypesTableFilterComposer,
          $$ChargeVehicleTypesTableOrderingComposer,
          $$ChargeVehicleTypesTableAnnotationComposer,
          $$ChargeVehicleTypesTableCreateCompanionBuilder,
          $$ChargeVehicleTypesTableUpdateCompanionBuilder,
          (ChargeVehicleType, $$ChargeVehicleTypesTableReferences),
          ChargeVehicleType,
          PrefetchHooks Function({bool weighmentRatesRefs})
        > {
  $$ChargeVehicleTypesTableTableManager(
    _$AppDatabase db,
    $ChargeVehicleTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChargeVehicleTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChargeVehicleTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChargeVehicleTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => ChargeVehicleTypesCompanion(
                id: id,
                name: name,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
              }) => ChargeVehicleTypesCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChargeVehicleTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({weighmentRatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (weighmentRatesRefs) db.weighmentRates,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (weighmentRatesRefs)
                    await $_getPrefetchedData<
                      ChargeVehicleType,
                      $ChargeVehicleTypesTable,
                      WeighmentRate
                    >(
                      currentTable: table,
                      referencedTable: $$ChargeVehicleTypesTableReferences
                          ._weighmentRatesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChargeVehicleTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).weighmentRatesRefs,
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

typedef $$ChargeVehicleTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChargeVehicleTypesTable,
      ChargeVehicleType,
      $$ChargeVehicleTypesTableFilterComposer,
      $$ChargeVehicleTypesTableOrderingComposer,
      $$ChargeVehicleTypesTableAnnotationComposer,
      $$ChargeVehicleTypesTableCreateCompanionBuilder,
      $$ChargeVehicleTypesTableUpdateCompanionBuilder,
      (ChargeVehicleType, $$ChargeVehicleTypesTableReferences),
      ChargeVehicleType,
      PrefetchHooks Function({bool weighmentRatesRefs})
    >;
typedef $$WeighmentRatesTableCreateCompanionBuilder =
    WeighmentRatesCompanion Function({
      Value<int> id,
      required int vehicleTypeId,
      required String rateType,
      Value<double?> weightLimit,
      required double amount,
    });
typedef $$WeighmentRatesTableUpdateCompanionBuilder =
    WeighmentRatesCompanion Function({
      Value<int> id,
      Value<int> vehicleTypeId,
      Value<String> rateType,
      Value<double?> weightLimit,
      Value<double> amount,
    });

final class $$WeighmentRatesTableReferences
    extends BaseReferences<_$AppDatabase, $WeighmentRatesTable, WeighmentRate> {
  $$WeighmentRatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChargeVehicleTypesTable _vehicleTypeIdTable(_$AppDatabase db) =>
      db.chargeVehicleTypes.createAlias(
        'weighment_rates__vehicle_type_id__charge_vehicle_types__id',
      );

  $$ChargeVehicleTypesTableProcessedTableManager get vehicleTypeId {
    final $_column = $_itemColumn<int>('vehicle_type_id')!;

    final manager = $$ChargeVehicleTypesTableTableManager(
      $_db,
      $_db.chargeVehicleTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeighmentRatesTableFilterComposer
    extends Composer<_$AppDatabase, $WeighmentRatesTable> {
  $$WeighmentRatesTableFilterComposer({
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

  ColumnFilters<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightLimit => $composableBuilder(
    column: $table.weightLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$ChargeVehicleTypesTableFilterComposer get vehicleTypeId {
    final $$ChargeVehicleTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleTypeId,
      referencedTable: $db.chargeVehicleTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChargeVehicleTypesTableFilterComposer(
            $db: $db,
            $table: $db.chargeVehicleTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeighmentRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeighmentRatesTable> {
  $$WeighmentRatesTableOrderingComposer({
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

  ColumnOrderings<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightLimit => $composableBuilder(
    column: $table.weightLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChargeVehicleTypesTableOrderingComposer get vehicleTypeId {
    final $$ChargeVehicleTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleTypeId,
      referencedTable: $db.chargeVehicleTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChargeVehicleTypesTableOrderingComposer(
            $db: $db,
            $table: $db.chargeVehicleTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeighmentRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeighmentRatesTable> {
  $$WeighmentRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rateType =>
      $composableBuilder(column: $table.rateType, builder: (column) => column);

  GeneratedColumn<double> get weightLimit => $composableBuilder(
    column: $table.weightLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$ChargeVehicleTypesTableAnnotationComposer get vehicleTypeId {
    final $$ChargeVehicleTypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.vehicleTypeId,
          referencedTable: $db.chargeVehicleTypes,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChargeVehicleTypesTableAnnotationComposer(
                $db: $db,
                $table: $db.chargeVehicleTypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WeighmentRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeighmentRatesTable,
          WeighmentRate,
          $$WeighmentRatesTableFilterComposer,
          $$WeighmentRatesTableOrderingComposer,
          $$WeighmentRatesTableAnnotationComposer,
          $$WeighmentRatesTableCreateCompanionBuilder,
          $$WeighmentRatesTableUpdateCompanionBuilder,
          (WeighmentRate, $$WeighmentRatesTableReferences),
          WeighmentRate,
          PrefetchHooks Function({bool vehicleTypeId})
        > {
  $$WeighmentRatesTableTableManager(
    _$AppDatabase db,
    $WeighmentRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeighmentRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeighmentRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeighmentRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleTypeId = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<double?> weightLimit = const Value.absent(),
                Value<double> amount = const Value.absent(),
              }) => WeighmentRatesCompanion(
                id: id,
                vehicleTypeId: vehicleTypeId,
                rateType: rateType,
                weightLimit: weightLimit,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleTypeId,
                required String rateType,
                Value<double?> weightLimit = const Value.absent(),
                required double amount,
              }) => WeighmentRatesCompanion.insert(
                id: id,
                vehicleTypeId: vehicleTypeId,
                rateType: rateType,
                weightLimit: weightLimit,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeighmentRatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleTypeId = false}) {
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
                    if (vehicleTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleTypeId,
                                referencedTable: $$WeighmentRatesTableReferences
                                    ._vehicleTypeIdTable(db),
                                referencedColumn:
                                    $$WeighmentRatesTableReferences
                                        ._vehicleTypeIdTable(db)
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

typedef $$WeighmentRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeighmentRatesTable,
      WeighmentRate,
      $$WeighmentRatesTableFilterComposer,
      $$WeighmentRatesTableOrderingComposer,
      $$WeighmentRatesTableAnnotationComposer,
      $$WeighmentRatesTableCreateCompanionBuilder,
      $$WeighmentRatesTableUpdateCompanionBuilder,
      (WeighmentRate, $$WeighmentRatesTableReferences),
      WeighmentRate,
      PrefetchHooks Function({bool vehicleTypeId})
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
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db, _db.weighments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ChargeVehicleTypesTableTableManager get chargeVehicleTypes =>
      $$ChargeVehicleTypesTableTableManager(_db, _db.chargeVehicleTypes);
  $$WeighmentRatesTableTableManager get weighmentRates =>
      $$WeighmentRatesTableTableManager(_db, _db.weighmentRates);
  $$ScaleSettingsTableTableManager get scaleSettings =>
      $$ScaleSettingsTableTableManager(_db, _db.scaleSettings);
}
