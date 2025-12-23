// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, Organization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
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
  static const VerificationMeta _parentCommissaryIdMeta =
      const VerificationMeta('parentCommissaryId');
  @override
  late final GeneratedColumn<String> parentCommissaryId =
      GeneratedColumn<String>(
        'parent_commissary_id',
        aliasedName,
        true,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    name,
    type,
    address,
    phone,
    email,
    parentCommissaryId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Organization> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('parent_commissary_id')) {
      context.handle(
        _parentCommissaryIdMeta,
        parentCommissaryId.isAcceptableOrUnknown(
          data['parent_commissary_id']!,
          _parentCommissaryIdMeta,
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Organization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Organization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      parentCommissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_commissary_id'],
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
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class Organization extends DataClass implements Insertable<Organization> {
  final int id;
  final String cloudId;
  final String name;
  final String type;
  final String? address;
  final String? phone;
  final String? email;
  final String? parentCommissaryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const Organization({
    required this.id,
    required this.cloudId,
    required this.name,
    required this.type,
    this.address,
    this.phone,
    this.email,
    this.parentCommissaryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || parentCommissaryId != null) {
      map['parent_commissary_id'] = Variable<String>(parentCommissaryId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      name: Value(name),
      type: Value(type),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      parentCommissaryId: parentCommissaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCommissaryId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory Organization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Organization(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      parentCommissaryId: serializer.fromJson<String?>(
        json['parentCommissaryId'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'parentCommissaryId': serializer.toJson<String?>(parentCommissaryId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  Organization copyWith({
    int? id,
    String? cloudId,
    String? name,
    String? type,
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> parentCommissaryId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => Organization(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    name: name ?? this.name,
    type: type ?? this.type,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    parentCommissaryId: parentCommissaryId.present
        ? parentCommissaryId.value
        : this.parentCommissaryId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  Organization copyWithCompanion(OrganizationsCompanion data) {
    return Organization(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      parentCommissaryId: data.parentCommissaryId.present
          ? data.parentCommissaryId.value
          : this.parentCommissaryId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Organization(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('parentCommissaryId: $parentCommissaryId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    name,
    type,
    address,
    phone,
    email,
    parentCommissaryId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organization &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.name == this.name &&
          other.type == this.type &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.parentCommissaryId == this.parentCommissaryId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class OrganizationsCompanion extends UpdateCompanion<Organization> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> parentCommissaryId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.parentCommissaryId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String name,
    required String type,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.parentCommissaryId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       name = Value(name),
       type = Value(type);
  static Insertable<Organization> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? parentCommissaryId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (parentCommissaryId != null)
        'parent_commissary_id': parentCommissaryId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  OrganizationsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? parentCommissaryId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      parentCommissaryId: parentCommissaryId ?? this.parentCommissaryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (parentCommissaryId.present) {
      map['parent_commissary_id'] = Variable<String>(parentCommissaryId.value);
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
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('parentCommissaryId: $parentCommissaryId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
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
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canViewInventoryMeta = const VerificationMeta(
    'canViewInventory',
  );
  @override
  late final GeneratedColumn<bool> canViewInventory = GeneratedColumn<bool>(
    'can_view_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_view_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _canManageInventoryMeta =
      const VerificationMeta('canManageInventory');
  @override
  late final GeneratedColumn<bool> canManageInventory = GeneratedColumn<bool>(
    'can_manage_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canManageEmployeesMeta =
      const VerificationMeta('canManageEmployees');
  @override
  late final GeneratedColumn<bool> canManageEmployees = GeneratedColumn<bool>(
    'can_manage_employees',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_employees" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canManageRolesMeta = const VerificationMeta(
    'canManageRoles',
  );
  @override
  late final GeneratedColumn<bool> canManageRoles = GeneratedColumn<bool>(
    'can_manage_roles',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_roles" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canViewReportsMeta = const VerificationMeta(
    'canViewReports',
  );
  @override
  late final GeneratedColumn<bool> canViewReports = GeneratedColumn<bool>(
    'can_view_reports',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_view_reports" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canManageBranchesMeta = const VerificationMeta(
    'canManageBranches',
  );
  @override
  late final GeneratedColumn<bool> canManageBranches = GeneratedColumn<bool>(
    'can_manage_branches',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_manage_branches" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSystemRoleMeta = const VerificationMeta(
    'isSystemRole',
  );
  @override
  late final GeneratedColumn<bool> isSystemRole = GeneratedColumn<bool>(
    'is_system_role',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_role" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    name,
    description,
    canViewInventory,
    canManageInventory,
    canManageEmployees,
    canManageRoles,
    canViewReports,
    canManageBranches,
    isSystemRole,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Role> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('can_view_inventory')) {
      context.handle(
        _canViewInventoryMeta,
        canViewInventory.isAcceptableOrUnknown(
          data['can_view_inventory']!,
          _canViewInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_manage_inventory')) {
      context.handle(
        _canManageInventoryMeta,
        canManageInventory.isAcceptableOrUnknown(
          data['can_manage_inventory']!,
          _canManageInventoryMeta,
        ),
      );
    }
    if (data.containsKey('can_manage_employees')) {
      context.handle(
        _canManageEmployeesMeta,
        canManageEmployees.isAcceptableOrUnknown(
          data['can_manage_employees']!,
          _canManageEmployeesMeta,
        ),
      );
    }
    if (data.containsKey('can_manage_roles')) {
      context.handle(
        _canManageRolesMeta,
        canManageRoles.isAcceptableOrUnknown(
          data['can_manage_roles']!,
          _canManageRolesMeta,
        ),
      );
    }
    if (data.containsKey('can_view_reports')) {
      context.handle(
        _canViewReportsMeta,
        canViewReports.isAcceptableOrUnknown(
          data['can_view_reports']!,
          _canViewReportsMeta,
        ),
      );
    }
    if (data.containsKey('can_manage_branches')) {
      context.handle(
        _canManageBranchesMeta,
        canManageBranches.isAcceptableOrUnknown(
          data['can_manage_branches']!,
          _canManageBranchesMeta,
        ),
      );
    }
    if (data.containsKey('is_system_role')) {
      context.handle(
        _isSystemRoleMeta,
        isSystemRole.isAcceptableOrUnknown(
          data['is_system_role']!,
          _isSystemRoleMeta,
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      canViewInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_view_inventory'],
      )!,
      canManageInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_inventory'],
      )!,
      canManageEmployees: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_employees'],
      )!,
      canManageRoles: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_roles'],
      )!,
      canViewReports: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_view_reports'],
      )!,
      canManageBranches: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_manage_branches'],
      )!,
      isSystemRole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_role'],
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
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final int id;
  final String cloudId;
  final String name;
  final String? description;
  final bool canViewInventory;
  final bool canManageInventory;
  final bool canManageEmployees;
  final bool canManageRoles;
  final bool canViewReports;
  final bool canManageBranches;
  final bool isSystemRole;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const Role({
    required this.id,
    required this.cloudId,
    required this.name,
    this.description,
    required this.canViewInventory,
    required this.canManageInventory,
    required this.canManageEmployees,
    required this.canManageRoles,
    required this.canViewReports,
    required this.canManageBranches,
    required this.isSystemRole,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['can_view_inventory'] = Variable<bool>(canViewInventory);
    map['can_manage_inventory'] = Variable<bool>(canManageInventory);
    map['can_manage_employees'] = Variable<bool>(canManageEmployees);
    map['can_manage_roles'] = Variable<bool>(canManageRoles);
    map['can_view_reports'] = Variable<bool>(canViewReports);
    map['can_manage_branches'] = Variable<bool>(canManageBranches);
    map['is_system_role'] = Variable<bool>(isSystemRole);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      canViewInventory: Value(canViewInventory),
      canManageInventory: Value(canManageInventory),
      canManageEmployees: Value(canManageEmployees),
      canManageRoles: Value(canManageRoles),
      canViewReports: Value(canViewReports),
      canManageBranches: Value(canManageBranches),
      isSystemRole: Value(isSystemRole),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory Role.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      canViewInventory: serializer.fromJson<bool>(json['canViewInventory']),
      canManageInventory: serializer.fromJson<bool>(json['canManageInventory']),
      canManageEmployees: serializer.fromJson<bool>(json['canManageEmployees']),
      canManageRoles: serializer.fromJson<bool>(json['canManageRoles']),
      canViewReports: serializer.fromJson<bool>(json['canViewReports']),
      canManageBranches: serializer.fromJson<bool>(json['canManageBranches']),
      isSystemRole: serializer.fromJson<bool>(json['isSystemRole']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'canViewInventory': serializer.toJson<bool>(canViewInventory),
      'canManageInventory': serializer.toJson<bool>(canManageInventory),
      'canManageEmployees': serializer.toJson<bool>(canManageEmployees),
      'canManageRoles': serializer.toJson<bool>(canManageRoles),
      'canViewReports': serializer.toJson<bool>(canViewReports),
      'canManageBranches': serializer.toJson<bool>(canManageBranches),
      'isSystemRole': serializer.toJson<bool>(isSystemRole),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  Role copyWith({
    int? id,
    String? cloudId,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? canViewInventory,
    bool? canManageInventory,
    bool? canManageEmployees,
    bool? canManageRoles,
    bool? canViewReports,
    bool? canManageBranches,
    bool? isSystemRole,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => Role(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    canViewInventory: canViewInventory ?? this.canViewInventory,
    canManageInventory: canManageInventory ?? this.canManageInventory,
    canManageEmployees: canManageEmployees ?? this.canManageEmployees,
    canManageRoles: canManageRoles ?? this.canManageRoles,
    canViewReports: canViewReports ?? this.canViewReports,
    canManageBranches: canManageBranches ?? this.canManageBranches,
    isSystemRole: isSystemRole ?? this.isSystemRole,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      canViewInventory: data.canViewInventory.present
          ? data.canViewInventory.value
          : this.canViewInventory,
      canManageInventory: data.canManageInventory.present
          ? data.canManageInventory.value
          : this.canManageInventory,
      canManageEmployees: data.canManageEmployees.present
          ? data.canManageEmployees.value
          : this.canManageEmployees,
      canManageRoles: data.canManageRoles.present
          ? data.canManageRoles.value
          : this.canManageRoles,
      canViewReports: data.canViewReports.present
          ? data.canViewReports.value
          : this.canViewReports,
      canManageBranches: data.canManageBranches.present
          ? data.canManageBranches.value
          : this.canManageBranches,
      isSystemRole: data.isSystemRole.present
          ? data.isSystemRole.value
          : this.isSystemRole,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canManageInventory: $canManageInventory, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canManageBranches: $canManageBranches, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    name,
    description,
    canViewInventory,
    canManageInventory,
    canManageEmployees,
    canManageRoles,
    canViewReports,
    canManageBranches,
    isSystemRole,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.name == this.name &&
          other.description == this.description &&
          other.canViewInventory == this.canViewInventory &&
          other.canManageInventory == this.canManageInventory &&
          other.canManageEmployees == this.canManageEmployees &&
          other.canManageRoles == this.canManageRoles &&
          other.canViewReports == this.canViewReports &&
          other.canManageBranches == this.canManageBranches &&
          other.isSystemRole == this.isSystemRole &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> canViewInventory;
  final Value<bool> canManageInventory;
  final Value<bool> canManageEmployees;
  final Value<bool> canManageRoles;
  final Value<bool> canViewReports;
  final Value<bool> canManageBranches;
  final Value<bool> isSystemRole;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.canViewInventory = const Value.absent(),
    this.canManageInventory = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canManageBranches = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String name,
    this.description = const Value.absent(),
    this.canViewInventory = const Value.absent(),
    this.canManageInventory = const Value.absent(),
    this.canManageEmployees = const Value.absent(),
    this.canManageRoles = const Value.absent(),
    this.canViewReports = const Value.absent(),
    this.canManageBranches = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       name = Value(name);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? canViewInventory,
    Expression<bool>? canManageInventory,
    Expression<bool>? canManageEmployees,
    Expression<bool>? canManageRoles,
    Expression<bool>? canViewReports,
    Expression<bool>? canManageBranches,
    Expression<bool>? isSystemRole,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (canViewInventory != null) 'can_view_inventory': canViewInventory,
      if (canManageInventory != null)
        'can_manage_inventory': canManageInventory,
      if (canManageEmployees != null)
        'can_manage_employees': canManageEmployees,
      if (canManageRoles != null) 'can_manage_roles': canManageRoles,
      if (canViewReports != null) 'can_view_reports': canViewReports,
      if (canManageBranches != null) 'can_manage_branches': canManageBranches,
      if (isSystemRole != null) 'is_system_role': isSystemRole,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? canViewInventory,
    Value<bool>? canManageInventory,
    Value<bool>? canManageEmployees,
    Value<bool>? canManageRoles,
    Value<bool>? canViewReports,
    Value<bool>? canManageBranches,
    Value<bool>? isSystemRole,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      description: description ?? this.description,
      canViewInventory: canViewInventory ?? this.canViewInventory,
      canManageInventory: canManageInventory ?? this.canManageInventory,
      canManageEmployees: canManageEmployees ?? this.canManageEmployees,
      canManageRoles: canManageRoles ?? this.canManageRoles,
      canViewReports: canViewReports ?? this.canViewReports,
      canManageBranches: canManageBranches ?? this.canManageBranches,
      isSystemRole: isSystemRole ?? this.isSystemRole,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (canViewInventory.present) {
      map['can_view_inventory'] = Variable<bool>(canViewInventory.value);
    }
    if (canManageInventory.present) {
      map['can_manage_inventory'] = Variable<bool>(canManageInventory.value);
    }
    if (canManageEmployees.present) {
      map['can_manage_employees'] = Variable<bool>(canManageEmployees.value);
    }
    if (canManageRoles.present) {
      map['can_manage_roles'] = Variable<bool>(canManageRoles.value);
    }
    if (canViewReports.present) {
      map['can_view_reports'] = Variable<bool>(canViewReports.value);
    }
    if (canManageBranches.present) {
      map['can_manage_branches'] = Variable<bool>(canManageBranches.value);
    }
    if (isSystemRole.present) {
      map['is_system_role'] = Variable<bool>(isSystemRole.value);
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
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('canViewInventory: $canViewInventory, ')
          ..write('canManageInventory: $canManageInventory, ')
          ..write('canManageEmployees: $canManageEmployees, ')
          ..write('canManageRoles: $canManageRoles, ')
          ..write('canViewReports: $canViewReports, ')
          ..write('canManageBranches: $canManageBranches, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authUserIdMeta = const VerificationMeta(
    'authUserId',
  );
  @override
  late final GeneratedColumn<String> authUserId = GeneratedColumn<String>(
    'auth_user_id',
    aliasedName,
    true,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    username,
    email,
    phone,
    passwordHash,
    organizationId,
    roleId,
    authUserId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
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
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
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
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('auth_user_id')) {
      context.handle(
        _authUserIdMeta,
        authUserId.isAcceptableOrUnknown(
          data['auth_user_id']!,
          _authUserIdMeta,
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
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
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      authUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_user_id'],
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
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
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
  final String cloudId;
  final String username;
  final String email;
  final String? phone;
  final String passwordHash;
  final int organizationId;
  final int roleId;
  final String? authUserId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const User({
    required this.id,
    required this.cloudId,
    required this.username,
    required this.email,
    this.phone,
    required this.passwordHash,
    required this.organizationId,
    required this.roleId,
    this.authUserId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['password_hash'] = Variable<String>(passwordHash);
    map['organization_id'] = Variable<int>(organizationId);
    map['role_id'] = Variable<int>(roleId);
    if (!nullToAbsent || authUserId != null) {
      map['auth_user_id'] = Variable<String>(authUserId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      username: Value(username),
      email: Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      passwordHash: Value(passwordHash),
      organizationId: Value(organizationId),
      roleId: Value(roleId),
      authUserId: authUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(authUserId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      roleId: serializer.fromJson<int>(json['roleId']),
      authUserId: serializer.fromJson<String?>(json['authUserId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String?>(phone),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'organizationId': serializer.toJson<int>(organizationId),
      'roleId': serializer.toJson<int>(roleId),
      'authUserId': serializer.toJson<String?>(authUserId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  User copyWith({
    int? id,
    String? cloudId,
    String? username,
    String? email,
    Value<String?> phone = const Value.absent(),
    String? passwordHash,
    int? organizationId,
    int? roleId,
    Value<String?> authUserId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => User(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    username: username ?? this.username,
    email: email ?? this.email,
    phone: phone.present ? phone.value : this.phone,
    passwordHash: passwordHash ?? this.passwordHash,
    organizationId: organizationId ?? this.organizationId,
    roleId: roleId ?? this.roleId,
    authUserId: authUserId.present ? authUserId.value : this.authUserId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      authUserId: data.authUserId.present
          ? data.authUserId.value
          : this.authUserId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('organizationId: $organizationId, ')
          ..write('roleId: $roleId, ')
          ..write('authUserId: $authUserId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    username,
    email,
    phone,
    passwordHash,
    organizationId,
    roleId,
    authUserId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.username == this.username &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.passwordHash == this.passwordHash &&
          other.organizationId == this.organizationId &&
          other.roleId == this.roleId &&
          other.authUserId == this.authUserId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> username;
  final Value<String> email;
  final Value<String?> phone;
  final Value<String> passwordHash;
  final Value<int> organizationId;
  final Value<int> roleId;
  final Value<String?> authUserId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.authUserId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String username,
    required String email,
    this.phone = const Value.absent(),
    required String passwordHash,
    required int organizationId,
    required int roleId,
    this.authUserId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       username = Value(username),
       email = Value(email),
       passwordHash = Value(passwordHash),
       organizationId = Value(organizationId),
       roleId = Value(roleId);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? username,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? passwordHash,
    Expression<int>? organizationId,
    Expression<int>? roleId,
    Expression<String>? authUserId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (organizationId != null) 'organization_id': organizationId,
      if (roleId != null) 'role_id': roleId,
      if (authUserId != null) 'auth_user_id': authUserId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? username,
    Value<String>? email,
    Value<String?>? phone,
    Value<String>? passwordHash,
    Value<int>? organizationId,
    Value<int>? roleId,
    Value<String?>? authUserId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      organizationId: organizationId ?? this.organizationId,
      roleId: roleId ?? this.roleId,
      authUserId: authUserId ?? this.authUserId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (authUserId.present) {
      map['auth_user_id'] = Variable<String>(authUserId.value);
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
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('organizationId: $organizationId, ')
          ..write('roleId: $roleId, ')
          ..write('authUserId: $authUserId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    name,
    description,
    isDeleted,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String cloudId;
  final String name;
  final String? description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const Category({
    required this.id,
    required this.cloudId,
    required this.name,
    this.description,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  Category copyWith({
    int? id,
    String? cloudId,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => Category(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    name,
    description,
    isDeleted,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.name == this.name &&
          other.description == this.description &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String name,
    this.description = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criticalLevelMeta = const VerificationMeta(
    'criticalLevel',
  );
  @override
  late final GeneratedColumn<int> criticalLevel = GeneratedColumn<int>(
    'critical_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _soldMeta = const VerificationMeta('sold');
  @override
  late final GeneratedColumn<int> sold = GeneratedColumn<int>(
    'sold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _spoilageMeta = const VerificationMeta(
    'spoilage',
  );
  @override
  late final GeneratedColumn<int> spoilage = GeneratedColumn<int>(
    'spoilage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masterItemIdMeta = const VerificationMeta(
    'masterItemId',
  );
  @override
  late final GeneratedColumn<String> masterItemId = GeneratedColumn<String>(
    'master_item_id',
    aliasedName,
    true,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    name,
    description,
    stock,
    criticalLevel,
    sold,
    spoilage,
    price,
    cost,
    organizationId,
    categoryId,
    masterItemId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('critical_level')) {
      context.handle(
        _criticalLevelMeta,
        criticalLevel.isAcceptableOrUnknown(
          data['critical_level']!,
          _criticalLevelMeta,
        ),
      );
    }
    if (data.containsKey('sold')) {
      context.handle(
        _soldMeta,
        sold.isAcceptableOrUnknown(data['sold']!, _soldMeta),
      );
    }
    if (data.containsKey('spoilage')) {
      context.handle(
        _spoilageMeta,
        spoilage.isAcceptableOrUnknown(data['spoilage']!, _spoilageMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('master_item_id')) {
      context.handle(
        _masterItemIdMeta,
        masterItemId.isAcceptableOrUnknown(
          data['master_item_id']!,
          _masterItemIdMeta,
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      criticalLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}critical_level'],
      )!,
      sold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sold'],
      )!,
      spoilage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spoilage'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      masterItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_item_id'],
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
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String cloudId;
  final String name;
  final String? description;
  final int stock;
  final int criticalLevel;
  final int sold;
  final int spoilage;
  final double price;
  final double cost;
  final int organizationId;
  final int? categoryId;
  final String? masterItemId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const Item({
    required this.id,
    required this.cloudId,
    required this.name,
    this.description,
    required this.stock,
    required this.criticalLevel,
    required this.sold,
    required this.spoilage,
    required this.price,
    required this.cost,
    required this.organizationId,
    this.categoryId,
    this.masterItemId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['stock'] = Variable<int>(stock);
    map['critical_level'] = Variable<int>(criticalLevel);
    map['sold'] = Variable<int>(sold);
    map['spoilage'] = Variable<int>(spoilage);
    map['price'] = Variable<double>(price);
    map['cost'] = Variable<double>(cost);
    map['organization_id'] = Variable<int>(organizationId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || masterItemId != null) {
      map['master_item_id'] = Variable<String>(masterItemId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      stock: Value(stock),
      criticalLevel: Value(criticalLevel),
      sold: Value(sold),
      spoilage: Value(spoilage),
      price: Value(price),
      cost: Value(cost),
      organizationId: Value(organizationId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      masterItemId: masterItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(masterItemId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      stock: serializer.fromJson<int>(json['stock']),
      criticalLevel: serializer.fromJson<int>(json['criticalLevel']),
      sold: serializer.fromJson<int>(json['sold']),
      spoilage: serializer.fromJson<int>(json['spoilage']),
      price: serializer.fromJson<double>(json['price']),
      cost: serializer.fromJson<double>(json['cost']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      masterItemId: serializer.fromJson<String?>(json['masterItemId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'stock': serializer.toJson<int>(stock),
      'criticalLevel': serializer.toJson<int>(criticalLevel),
      'sold': serializer.toJson<int>(sold),
      'spoilage': serializer.toJson<int>(spoilage),
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double>(cost),
      'organizationId': serializer.toJson<int>(organizationId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'masterItemId': serializer.toJson<String?>(masterItemId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  Item copyWith({
    int? id,
    String? cloudId,
    String? name,
    Value<String?> description = const Value.absent(),
    int? stock,
    int? criticalLevel,
    int? sold,
    int? spoilage,
    double? price,
    double? cost,
    int? organizationId,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> masterItemId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => Item(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    stock: stock ?? this.stock,
    criticalLevel: criticalLevel ?? this.criticalLevel,
    sold: sold ?? this.sold,
    spoilage: spoilage ?? this.spoilage,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    organizationId: organizationId ?? this.organizationId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    masterItemId: masterItemId.present ? masterItemId.value : this.masterItemId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      stock: data.stock.present ? data.stock.value : this.stock,
      criticalLevel: data.criticalLevel.present
          ? data.criticalLevel.value
          : this.criticalLevel,
      sold: data.sold.present ? data.sold.value : this.sold,
      spoilage: data.spoilage.present ? data.spoilage.value : this.spoilage,
      price: data.price.present ? data.price.value : this.price,
      cost: data.cost.present ? data.cost.value : this.cost,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      masterItemId: data.masterItemId.present
          ? data.masterItemId.value
          : this.masterItemId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stock: $stock, ')
          ..write('criticalLevel: $criticalLevel, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('organizationId: $organizationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('masterItemId: $masterItemId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    name,
    description,
    stock,
    criticalLevel,
    sold,
    spoilage,
    price,
    cost,
    organizationId,
    categoryId,
    masterItemId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.name == this.name &&
          other.description == this.description &&
          other.stock == this.stock &&
          other.criticalLevel == this.criticalLevel &&
          other.sold == this.sold &&
          other.spoilage == this.spoilage &&
          other.price == this.price &&
          other.cost == this.cost &&
          other.organizationId == this.organizationId &&
          other.categoryId == this.categoryId &&
          other.masterItemId == this.masterItemId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> stock;
  final Value<int> criticalLevel;
  final Value<int> sold;
  final Value<int> spoilage;
  final Value<double> price;
  final Value<double> cost;
  final Value<int> organizationId;
  final Value<int?> categoryId;
  final Value<String?> masterItemId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.stock = const Value.absent(),
    this.criticalLevel = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.masterItemId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String name,
    this.description = const Value.absent(),
    this.stock = const Value.absent(),
    this.criticalLevel = const Value.absent(),
    this.sold = const Value.absent(),
    this.spoilage = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    required int organizationId,
    this.categoryId = const Value.absent(),
    this.masterItemId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       name = Value(name),
       organizationId = Value(organizationId);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? stock,
    Expression<int>? criticalLevel,
    Expression<int>? sold,
    Expression<int>? spoilage,
    Expression<double>? price,
    Expression<double>? cost,
    Expression<int>? organizationId,
    Expression<int>? categoryId,
    Expression<String>? masterItemId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (stock != null) 'stock': stock,
      if (criticalLevel != null) 'critical_level': criticalLevel,
      if (sold != null) 'sold': sold,
      if (spoilage != null) 'spoilage': spoilage,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (organizationId != null) 'organization_id': organizationId,
      if (categoryId != null) 'category_id': categoryId,
      if (masterItemId != null) 'master_item_id': masterItemId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? stock,
    Value<int>? criticalLevel,
    Value<int>? sold,
    Value<int>? spoilage,
    Value<double>? price,
    Value<double>? cost,
    Value<int>? organizationId,
    Value<int?>? categoryId,
    Value<String?>? masterItemId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      criticalLevel: criticalLevel ?? this.criticalLevel,
      sold: sold ?? this.sold,
      spoilage: spoilage ?? this.spoilage,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      organizationId: organizationId ?? this.organizationId,
      categoryId: categoryId ?? this.categoryId,
      masterItemId: masterItemId ?? this.masterItemId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (criticalLevel.present) {
      map['critical_level'] = Variable<int>(criticalLevel.value);
    }
    if (sold.present) {
      map['sold'] = Variable<int>(sold.value);
    }
    if (spoilage.present) {
      map['spoilage'] = Variable<int>(spoilage.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (masterItemId.present) {
      map['master_item_id'] = Variable<String>(masterItemId.value);
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
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stock: $stock, ')
          ..write('criticalLevel: $criticalLevel, ')
          ..write('sold: $sold, ')
          ..write('spoilage: $spoilage, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('organizationId: $organizationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('masterItemId: $masterItemId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criticalLevelMeta = const VerificationMeta(
    'criticalLevel',
  );
  @override
  late final GeneratedColumn<double> criticalLevel = GeneratedColumn<double>(
    'critical_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
    'cost_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _commissaryIdMeta = const VerificationMeta(
    'commissaryId',
  );
  @override
  late final GeneratedColumn<int> commissaryId = GeneratedColumn<int>(
    'commissary_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    name,
    unit,
    stock,
    criticalLevel,
    costPerUnit,
    commissaryId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('critical_level')) {
      context.handle(
        _criticalLevelMeta,
        criticalLevel.isAcceptableOrUnknown(
          data['critical_level']!,
          _criticalLevelMeta,
        ),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('commissary_id')) {
      context.handle(
        _commissaryIdMeta,
        commissaryId.isAcceptableOrUnknown(
          data['commissary_id']!,
          _commissaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commissaryIdMeta);
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      criticalLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}critical_level'],
      )!,
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_unit'],
      )!,
      commissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commissary_id'],
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
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final int id;
  final String cloudId;
  final String name;
  final String unit;
  final double stock;
  final double criticalLevel;
  final double costPerUnit;
  final int commissaryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const Ingredient({
    required this.id,
    required this.cloudId,
    required this.name,
    required this.unit,
    required this.stock,
    required this.criticalLevel,
    required this.costPerUnit,
    required this.commissaryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['stock'] = Variable<double>(stock);
    map['critical_level'] = Variable<double>(criticalLevel);
    map['cost_per_unit'] = Variable<double>(costPerUnit);
    map['commissary_id'] = Variable<int>(commissaryId);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      name: Value(name),
      unit: Value(unit),
      stock: Value(stock),
      criticalLevel: Value(criticalLevel),
      costPerUnit: Value(costPerUnit),
      commissaryId: Value(commissaryId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      stock: serializer.fromJson<double>(json['stock']),
      criticalLevel: serializer.fromJson<double>(json['criticalLevel']),
      costPerUnit: serializer.fromJson<double>(json['costPerUnit']),
      commissaryId: serializer.fromJson<int>(json['commissaryId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'stock': serializer.toJson<double>(stock),
      'criticalLevel': serializer.toJson<double>(criticalLevel),
      'costPerUnit': serializer.toJson<double>(costPerUnit),
      'commissaryId': serializer.toJson<int>(commissaryId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  Ingredient copyWith({
    int? id,
    String? cloudId,
    String? name,
    String? unit,
    double? stock,
    double? criticalLevel,
    double? costPerUnit,
    int? commissaryId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => Ingredient(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    stock: stock ?? this.stock,
    criticalLevel: criticalLevel ?? this.criticalLevel,
    costPerUnit: costPerUnit ?? this.costPerUnit,
    commissaryId: commissaryId ?? this.commissaryId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      stock: data.stock.present ? data.stock.value : this.stock,
      criticalLevel: data.criticalLevel.present
          ? data.criticalLevel.value
          : this.criticalLevel,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      commissaryId: data.commissaryId.present
          ? data.commissaryId.value
          : this.commissaryId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stock: $stock, ')
          ..write('criticalLevel: $criticalLevel, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    name,
    unit,
    stock,
    criticalLevel,
    costPerUnit,
    commissaryId,
    isActive,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.stock == this.stock &&
          other.criticalLevel == this.criticalLevel &&
          other.costPerUnit == this.costPerUnit &&
          other.commissaryId == this.commissaryId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<String> name;
  final Value<String> unit;
  final Value<double> stock;
  final Value<double> criticalLevel;
  final Value<double> costPerUnit;
  final Value<int> commissaryId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.stock = const Value.absent(),
    this.criticalLevel = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.commissaryId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required String name,
    required String unit,
    this.stock = const Value.absent(),
    this.criticalLevel = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    required int commissaryId,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       name = Value(name),
       unit = Value(unit),
       commissaryId = Value(commissaryId);
  static Insertable<Ingredient> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? stock,
    Expression<double>? criticalLevel,
    Expression<double>? costPerUnit,
    Expression<int>? commissaryId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (stock != null) 'stock': stock,
      if (criticalLevel != null) 'critical_level': criticalLevel,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (commissaryId != null) 'commissary_id': commissaryId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  IngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<String>? name,
    Value<String>? unit,
    Value<double>? stock,
    Value<double>? criticalLevel,
    Value<double>? costPerUnit,
    Value<int>? commissaryId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      criticalLevel: criticalLevel ?? this.criticalLevel,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      commissaryId: commissaryId ?? this.commissaryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (criticalLevel.present) {
      map['critical_level'] = Variable<double>(criticalLevel.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (commissaryId.present) {
      map['commissary_id'] = Variable<int>(commissaryId.value);
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
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stock: $stock, ')
          ..write('criticalLevel: $criticalLevel, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    itemId,
    ingredientId,
    quantity,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final String cloudId;
  final int itemId;
  final int ingredientId;
  final double quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const RecipeIngredient({
    required this.id,
    required this.cloudId,
    required this.itemId,
    required this.ingredientId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['item_id'] = Variable<int>(itemId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    map['quantity'] = Variable<double>(quantity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      itemId: Value(itemId),
      ingredientId: Value(ingredientId),
      quantity: Value(quantity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'itemId': serializer.toJson<int>(itemId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'quantity': serializer.toJson<double>(quantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    String? cloudId,
    int? itemId,
    int? ingredientId,
    double? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => RecipeIngredient(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    itemId: itemId ?? this.itemId,
    ingredientId: ingredientId ?? this.ingredientId,
    quantity: quantity ?? this.quantity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('itemId: $itemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    itemId,
    ingredientId,
    quantity,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.itemId == this.itemId &&
          other.ingredientId == this.ingredientId &&
          other.quantity == this.quantity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<int> itemId;
  final Value<int> ingredientId;
  final Value<double> quantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required int itemId,
    required int ingredientId,
    required double quantity,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       itemId = Value(itemId),
       ingredientId = Value(ingredientId),
       quantity = Value(quantity);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<int>? itemId,
    Expression<int>? ingredientId,
    Expression<double>? quantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (itemId != null) 'item_id': itemId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantity != null) 'quantity': quantity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<int>? itemId,
    Value<int>? ingredientId,
    Value<double>? quantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      itemId: itemId ?? this.itemId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('itemId: $itemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantity: $quantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $StockReplenishmentRequestsTable extends StockReplenishmentRequests
    with
        TableInfo<$StockReplenishmentRequestsTable, StockReplenishmentRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockReplenishmentRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _franchiseeIdMeta = const VerificationMeta(
    'franchiseeId',
  );
  @override
  late final GeneratedColumn<int> franchiseeId = GeneratedColumn<int>(
    'franchisee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commissaryIdMeta = const VerificationMeta(
    'commissaryId',
  );
  @override
  late final GeneratedColumn<int> commissaryId = GeneratedColumn<int>(
    'commissary_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityRequestedMeta = const VerificationMeta(
    'quantityRequested',
  );
  @override
  late final GeneratedColumn<int> quantityRequested = GeneratedColumn<int>(
    'quantity_requested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityApprovedMeta = const VerificationMeta(
    'quantityApproved',
  );
  @override
  late final GeneratedColumn<int> quantityApproved = GeneratedColumn<int>(
    'quantity_approved',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _requesterNotesMeta = const VerificationMeta(
    'requesterNotes',
  );
  @override
  late final GeneratedColumn<String> requesterNotes = GeneratedColumn<String>(
    'requester_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approverNotesMeta = const VerificationMeta(
    'approverNotes',
  );
  @override
  late final GeneratedColumn<String> approverNotes = GeneratedColumn<String>(
    'approver_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedByMeta = const VerificationMeta(
    'processedBy',
  );
  @override
  late final GeneratedColumn<int> processedBy = GeneratedColumn<int>(
    'processed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    franchiseeId,
    commissaryId,
    itemId,
    quantityRequested,
    quantityApproved,
    status,
    requesterNotes,
    approverNotes,
    processedBy,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_replenishment_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockReplenishmentRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('franchisee_id')) {
      context.handle(
        _franchiseeIdMeta,
        franchiseeId.isAcceptableOrUnknown(
          data['franchisee_id']!,
          _franchiseeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_franchiseeIdMeta);
    }
    if (data.containsKey('commissary_id')) {
      context.handle(
        _commissaryIdMeta,
        commissaryId.isAcceptableOrUnknown(
          data['commissary_id']!,
          _commissaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commissaryIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity_requested')) {
      context.handle(
        _quantityRequestedMeta,
        quantityRequested.isAcceptableOrUnknown(
          data['quantity_requested']!,
          _quantityRequestedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityRequestedMeta);
    }
    if (data.containsKey('quantity_approved')) {
      context.handle(
        _quantityApprovedMeta,
        quantityApproved.isAcceptableOrUnknown(
          data['quantity_approved']!,
          _quantityApprovedMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requester_notes')) {
      context.handle(
        _requesterNotesMeta,
        requesterNotes.isAcceptableOrUnknown(
          data['requester_notes']!,
          _requesterNotesMeta,
        ),
      );
    }
    if (data.containsKey('approver_notes')) {
      context.handle(
        _approverNotesMeta,
        approverNotes.isAcceptableOrUnknown(
          data['approver_notes']!,
          _approverNotesMeta,
        ),
      );
    }
    if (data.containsKey('processed_by')) {
      context.handle(
        _processedByMeta,
        processedBy.isAcceptableOrUnknown(
          data['processed_by']!,
          _processedByMeta,
        ),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockReplenishmentRequest map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockReplenishmentRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      franchiseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}franchisee_id'],
      )!,
      commissaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commissary_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      quantityRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_requested'],
      )!,
      quantityApproved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_approved'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requesterNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requester_notes'],
      ),
      approverNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approver_notes'],
      ),
      processedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processed_by'],
      ),
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $StockReplenishmentRequestsTable createAlias(String alias) {
    return $StockReplenishmentRequestsTable(attachedDatabase, alias);
  }
}

class StockReplenishmentRequest extends DataClass
    implements Insertable<StockReplenishmentRequest> {
  final int id;
  final String cloudId;
  final int franchiseeId;
  final int commissaryId;
  final int itemId;
  final int quantityRequested;
  final int? quantityApproved;
  final String status;
  final String? requesterNotes;
  final String? approverNotes;
  final int? processedBy;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const StockReplenishmentRequest({
    required this.id,
    required this.cloudId,
    required this.franchiseeId,
    required this.commissaryId,
    required this.itemId,
    required this.quantityRequested,
    this.quantityApproved,
    required this.status,
    this.requesterNotes,
    this.approverNotes,
    this.processedBy,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['franchisee_id'] = Variable<int>(franchiseeId);
    map['commissary_id'] = Variable<int>(commissaryId);
    map['item_id'] = Variable<int>(itemId);
    map['quantity_requested'] = Variable<int>(quantityRequested);
    if (!nullToAbsent || quantityApproved != null) {
      map['quantity_approved'] = Variable<int>(quantityApproved);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || requesterNotes != null) {
      map['requester_notes'] = Variable<String>(requesterNotes);
    }
    if (!nullToAbsent || approverNotes != null) {
      map['approver_notes'] = Variable<String>(approverNotes);
    }
    if (!nullToAbsent || processedBy != null) {
      map['processed_by'] = Variable<int>(processedBy);
    }
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  StockReplenishmentRequestsCompanion toCompanion(bool nullToAbsent) {
    return StockReplenishmentRequestsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      franchiseeId: Value(franchiseeId),
      commissaryId: Value(commissaryId),
      itemId: Value(itemId),
      quantityRequested: Value(quantityRequested),
      quantityApproved: quantityApproved == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityApproved),
      status: Value(status),
      requesterNotes: requesterNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(requesterNotes),
      approverNotes: approverNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(approverNotes),
      processedBy: processedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(processedBy),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory StockReplenishmentRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockReplenishmentRequest(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      franchiseeId: serializer.fromJson<int>(json['franchiseeId']),
      commissaryId: serializer.fromJson<int>(json['commissaryId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      quantityRequested: serializer.fromJson<int>(json['quantityRequested']),
      quantityApproved: serializer.fromJson<int?>(json['quantityApproved']),
      status: serializer.fromJson<String>(json['status']),
      requesterNotes: serializer.fromJson<String?>(json['requesterNotes']),
      approverNotes: serializer.fromJson<String?>(json['approverNotes']),
      processedBy: serializer.fromJson<int?>(json['processedBy']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'franchiseeId': serializer.toJson<int>(franchiseeId),
      'commissaryId': serializer.toJson<int>(commissaryId),
      'itemId': serializer.toJson<int>(itemId),
      'quantityRequested': serializer.toJson<int>(quantityRequested),
      'quantityApproved': serializer.toJson<int?>(quantityApproved),
      'status': serializer.toJson<String>(status),
      'requesterNotes': serializer.toJson<String?>(requesterNotes),
      'approverNotes': serializer.toJson<String?>(approverNotes),
      'processedBy': serializer.toJson<int?>(processedBy),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  StockReplenishmentRequest copyWith({
    int? id,
    String? cloudId,
    int? franchiseeId,
    int? commissaryId,
    int? itemId,
    int? quantityRequested,
    Value<int?> quantityApproved = const Value.absent(),
    String? status,
    Value<String?> requesterNotes = const Value.absent(),
    Value<String?> approverNotes = const Value.absent(),
    Value<int?> processedBy = const Value.absent(),
    Value<DateTime?> processedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => StockReplenishmentRequest(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    franchiseeId: franchiseeId ?? this.franchiseeId,
    commissaryId: commissaryId ?? this.commissaryId,
    itemId: itemId ?? this.itemId,
    quantityRequested: quantityRequested ?? this.quantityRequested,
    quantityApproved: quantityApproved.present
        ? quantityApproved.value
        : this.quantityApproved,
    status: status ?? this.status,
    requesterNotes: requesterNotes.present
        ? requesterNotes.value
        : this.requesterNotes,
    approverNotes: approverNotes.present
        ? approverNotes.value
        : this.approverNotes,
    processedBy: processedBy.present ? processedBy.value : this.processedBy,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  StockReplenishmentRequest copyWithCompanion(
    StockReplenishmentRequestsCompanion data,
  ) {
    return StockReplenishmentRequest(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      franchiseeId: data.franchiseeId.present
          ? data.franchiseeId.value
          : this.franchiseeId,
      commissaryId: data.commissaryId.present
          ? data.commissaryId.value
          : this.commissaryId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantityRequested: data.quantityRequested.present
          ? data.quantityRequested.value
          : this.quantityRequested,
      quantityApproved: data.quantityApproved.present
          ? data.quantityApproved.value
          : this.quantityApproved,
      status: data.status.present ? data.status.value : this.status,
      requesterNotes: data.requesterNotes.present
          ? data.requesterNotes.value
          : this.requesterNotes,
      approverNotes: data.approverNotes.present
          ? data.approverNotes.value
          : this.approverNotes,
      processedBy: data.processedBy.present
          ? data.processedBy.value
          : this.processedBy,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockReplenishmentRequest(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('quantityApproved: $quantityApproved, ')
          ..write('status: $status, ')
          ..write('requesterNotes: $requesterNotes, ')
          ..write('approverNotes: $approverNotes, ')
          ..write('processedBy: $processedBy, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    franchiseeId,
    commissaryId,
    itemId,
    quantityRequested,
    quantityApproved,
    status,
    requesterNotes,
    approverNotes,
    processedBy,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockReplenishmentRequest &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.franchiseeId == this.franchiseeId &&
          other.commissaryId == this.commissaryId &&
          other.itemId == this.itemId &&
          other.quantityRequested == this.quantityRequested &&
          other.quantityApproved == this.quantityApproved &&
          other.status == this.status &&
          other.requesterNotes == this.requesterNotes &&
          other.approverNotes == this.approverNotes &&
          other.processedBy == this.processedBy &&
          other.processedAt == this.processedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class StockReplenishmentRequestsCompanion
    extends UpdateCompanion<StockReplenishmentRequest> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<int> franchiseeId;
  final Value<int> commissaryId;
  final Value<int> itemId;
  final Value<int> quantityRequested;
  final Value<int?> quantityApproved;
  final Value<String> status;
  final Value<String?> requesterNotes;
  final Value<String?> approverNotes;
  final Value<int?> processedBy;
  final Value<DateTime?> processedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const StockReplenishmentRequestsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.franchiseeId = const Value.absent(),
    this.commissaryId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantityRequested = const Value.absent(),
    this.quantityApproved = const Value.absent(),
    this.status = const Value.absent(),
    this.requesterNotes = const Value.absent(),
    this.approverNotes = const Value.absent(),
    this.processedBy = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  StockReplenishmentRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required int franchiseeId,
    required int commissaryId,
    required int itemId,
    required int quantityRequested,
    this.quantityApproved = const Value.absent(),
    this.status = const Value.absent(),
    this.requesterNotes = const Value.absent(),
    this.approverNotes = const Value.absent(),
    this.processedBy = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       franchiseeId = Value(franchiseeId),
       commissaryId = Value(commissaryId),
       itemId = Value(itemId),
       quantityRequested = Value(quantityRequested);
  static Insertable<StockReplenishmentRequest> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<int>? franchiseeId,
    Expression<int>? commissaryId,
    Expression<int>? itemId,
    Expression<int>? quantityRequested,
    Expression<int>? quantityApproved,
    Expression<String>? status,
    Expression<String>? requesterNotes,
    Expression<String>? approverNotes,
    Expression<int>? processedBy,
    Expression<DateTime>? processedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (franchiseeId != null) 'franchisee_id': franchiseeId,
      if (commissaryId != null) 'commissary_id': commissaryId,
      if (itemId != null) 'item_id': itemId,
      if (quantityRequested != null) 'quantity_requested': quantityRequested,
      if (quantityApproved != null) 'quantity_approved': quantityApproved,
      if (status != null) 'status': status,
      if (requesterNotes != null) 'requester_notes': requesterNotes,
      if (approverNotes != null) 'approver_notes': approverNotes,
      if (processedBy != null) 'processed_by': processedBy,
      if (processedAt != null) 'processed_at': processedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  StockReplenishmentRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<int>? franchiseeId,
    Value<int>? commissaryId,
    Value<int>? itemId,
    Value<int>? quantityRequested,
    Value<int?>? quantityApproved,
    Value<String>? status,
    Value<String?>? requesterNotes,
    Value<String?>? approverNotes,
    Value<int?>? processedBy,
    Value<DateTime?>? processedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return StockReplenishmentRequestsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      franchiseeId: franchiseeId ?? this.franchiseeId,
      commissaryId: commissaryId ?? this.commissaryId,
      itemId: itemId ?? this.itemId,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      quantityApproved: quantityApproved ?? this.quantityApproved,
      status: status ?? this.status,
      requesterNotes: requesterNotes ?? this.requesterNotes,
      approverNotes: approverNotes ?? this.approverNotes,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (franchiseeId.present) {
      map['franchisee_id'] = Variable<int>(franchiseeId.value);
    }
    if (commissaryId.present) {
      map['commissary_id'] = Variable<int>(commissaryId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (quantityRequested.present) {
      map['quantity_requested'] = Variable<int>(quantityRequested.value);
    }
    if (quantityApproved.present) {
      map['quantity_approved'] = Variable<int>(quantityApproved.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requesterNotes.present) {
      map['requester_notes'] = Variable<String>(requesterNotes.value);
    }
    if (approverNotes.present) {
      map['approver_notes'] = Variable<String>(approverNotes.value);
    }
    if (processedBy.present) {
      map['processed_by'] = Variable<int>(processedBy.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockReplenishmentRequestsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('commissaryId: $commissaryId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('quantityApproved: $quantityApproved, ')
          ..write('status: $status, ')
          ..write('requesterNotes: $requesterNotes, ')
          ..write('approverNotes: $approverNotes, ')
          ..write('processedBy: $processedBy, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

class $StockChangeRequestsTable extends StockChangeRequests
    with TableInfo<$StockChangeRequestsTable, StockChangeRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockChangeRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _franchiseeIdMeta = const VerificationMeta(
    'franchiseeId',
  );
  @override
  late final GeneratedColumn<int> franchiseeId = GeneratedColumn<int>(
    'franchisee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityChangeMeta = const VerificationMeta(
    'quantityChange',
  );
  @override
  late final GeneratedColumn<int> quantityChange = GeneratedColumn<int>(
    'quantity_change',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStockMeta = const VerificationMeta(
    'previousStock',
  );
  @override
  late final GeneratedColumn<int> previousStock = GeneratedColumn<int>(
    'previous_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStockMeta = const VerificationMeta(
    'newStock',
  );
  @override
  late final GeneratedColumn<int> newStock = GeneratedColumn<int>(
    'new_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<int> requestedBy = GeneratedColumn<int>(
    'requested_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedByMeta = const VerificationMeta(
    'processedBy',
  );
  @override
  late final GeneratedColumn<int> processedBy = GeneratedColumn<int>(
    'processed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsSyncMeta = const VerificationMeta(
    'needsSync',
  );
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
    'needs_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    franchiseeId,
    itemId,
    changeType,
    quantityChange,
    previousStock,
    newStock,
    reason,
    status,
    requestedBy,
    processedBy,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_change_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockChangeRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudIdMeta);
    }
    if (data.containsKey('franchisee_id')) {
      context.handle(
        _franchiseeIdMeta,
        franchiseeId.isAcceptableOrUnknown(
          data['franchisee_id']!,
          _franchiseeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_franchiseeIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('quantity_change')) {
      context.handle(
        _quantityChangeMeta,
        quantityChange.isAcceptableOrUnknown(
          data['quantity_change']!,
          _quantityChangeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityChangeMeta);
    }
    if (data.containsKey('previous_stock')) {
      context.handle(
        _previousStockMeta,
        previousStock.isAcceptableOrUnknown(
          data['previous_stock']!,
          _previousStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStockMeta);
    }
    if (data.containsKey('new_stock')) {
      context.handle(
        _newStockMeta,
        newStock.isAcceptableOrUnknown(data['new_stock']!, _newStockMeta),
      );
    } else if (isInserting) {
      context.missing(_newStockMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByMeta);
    }
    if (data.containsKey('processed_by')) {
      context.handle(
        _processedByMeta,
        processedBy.isAcceptableOrUnknown(
          data['processed_by']!,
          _processedByMeta,
        ),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
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
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_sync')) {
      context.handle(
        _needsSyncMeta,
        needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockChangeRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockChangeRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      )!,
      franchiseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}franchisee_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      quantityChange: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_change'],
      )!,
      previousStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_stock'],
      )!,
      newStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_stock'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_by'],
      )!,
      processedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processed_by'],
      ),
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_sync'],
      )!,
    );
  }

  @override
  $StockChangeRequestsTable createAlias(String alias) {
    return $StockChangeRequestsTable(attachedDatabase, alias);
  }
}

class StockChangeRequest extends DataClass
    implements Insertable<StockChangeRequest> {
  final int id;
  final String cloudId;
  final int franchiseeId;
  final int itemId;
  final String changeType;
  final int quantityChange;
  final int previousStock;
  final int newStock;
  final String? reason;
  final String status;
  final int requestedBy;
  final int? processedBy;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const StockChangeRequest({
    required this.id,
    required this.cloudId,
    required this.franchiseeId,
    required this.itemId,
    required this.changeType,
    required this.quantityChange,
    required this.previousStock,
    required this.newStock,
    this.reason,
    required this.status,
    required this.requestedBy,
    this.processedBy,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.needsSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cloud_id'] = Variable<String>(cloudId);
    map['franchisee_id'] = Variable<int>(franchiseeId);
    map['item_id'] = Variable<int>(itemId);
    map['change_type'] = Variable<String>(changeType);
    map['quantity_change'] = Variable<int>(quantityChange);
    map['previous_stock'] = Variable<int>(previousStock);
    map['new_stock'] = Variable<int>(newStock);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['status'] = Variable<String>(status);
    map['requested_by'] = Variable<int>(requestedBy);
    if (!nullToAbsent || processedBy != null) {
      map['processed_by'] = Variable<int>(processedBy);
    }
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  StockChangeRequestsCompanion toCompanion(bool nullToAbsent) {
    return StockChangeRequestsCompanion(
      id: Value(id),
      cloudId: Value(cloudId),
      franchiseeId: Value(franchiseeId),
      itemId: Value(itemId),
      changeType: Value(changeType),
      quantityChange: Value(quantityChange),
      previousStock: Value(previousStock),
      newStock: Value(newStock),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      status: Value(status),
      requestedBy: Value(requestedBy),
      processedBy: processedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(processedBy),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory StockChangeRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockChangeRequest(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String>(json['cloudId']),
      franchiseeId: serializer.fromJson<int>(json['franchiseeId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      quantityChange: serializer.fromJson<int>(json['quantityChange']),
      previousStock: serializer.fromJson<int>(json['previousStock']),
      newStock: serializer.fromJson<int>(json['newStock']),
      reason: serializer.fromJson<String?>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      requestedBy: serializer.fromJson<int>(json['requestedBy']),
      processedBy: serializer.fromJson<int?>(json['processedBy']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String>(cloudId),
      'franchiseeId': serializer.toJson<int>(franchiseeId),
      'itemId': serializer.toJson<int>(itemId),
      'changeType': serializer.toJson<String>(changeType),
      'quantityChange': serializer.toJson<int>(quantityChange),
      'previousStock': serializer.toJson<int>(previousStock),
      'newStock': serializer.toJson<int>(newStock),
      'reason': serializer.toJson<String?>(reason),
      'status': serializer.toJson<String>(status),
      'requestedBy': serializer.toJson<int>(requestedBy),
      'processedBy': serializer.toJson<int?>(processedBy),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  StockChangeRequest copyWith({
    int? id,
    String? cloudId,
    int? franchiseeId,
    int? itemId,
    String? changeType,
    int? quantityChange,
    int? previousStock,
    int? newStock,
    Value<String?> reason = const Value.absent(),
    String? status,
    int? requestedBy,
    Value<int?> processedBy = const Value.absent(),
    Value<DateTime?> processedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsSync,
  }) => StockChangeRequest(
    id: id ?? this.id,
    cloudId: cloudId ?? this.cloudId,
    franchiseeId: franchiseeId ?? this.franchiseeId,
    itemId: itemId ?? this.itemId,
    changeType: changeType ?? this.changeType,
    quantityChange: quantityChange ?? this.quantityChange,
    previousStock: previousStock ?? this.previousStock,
    newStock: newStock ?? this.newStock,
    reason: reason.present ? reason.value : this.reason,
    status: status ?? this.status,
    requestedBy: requestedBy ?? this.requestedBy,
    processedBy: processedBy.present ? processedBy.value : this.processedBy,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsSync: needsSync ?? this.needsSync,
  );
  StockChangeRequest copyWithCompanion(StockChangeRequestsCompanion data) {
    return StockChangeRequest(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      franchiseeId: data.franchiseeId.present
          ? data.franchiseeId.value
          : this.franchiseeId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      quantityChange: data.quantityChange.present
          ? data.quantityChange.value
          : this.quantityChange,
      previousStock: data.previousStock.present
          ? data.previousStock.value
          : this.previousStock,
      newStock: data.newStock.present ? data.newStock.value : this.newStock,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      processedBy: data.processedBy.present
          ? data.processedBy.value
          : this.processedBy,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockChangeRequest(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('processedBy: $processedBy, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cloudId,
    franchiseeId,
    itemId,
    changeType,
    quantityChange,
    previousStock,
    newStock,
    reason,
    status,
    requestedBy,
    processedBy,
    processedAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
    needsSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockChangeRequest &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.franchiseeId == this.franchiseeId &&
          other.itemId == this.itemId &&
          other.changeType == this.changeType &&
          other.quantityChange == this.quantityChange &&
          other.previousStock == this.previousStock &&
          other.newStock == this.newStock &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.requestedBy == this.requestedBy &&
          other.processedBy == this.processedBy &&
          other.processedAt == this.processedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class StockChangeRequestsCompanion extends UpdateCompanion<StockChangeRequest> {
  final Value<int> id;
  final Value<String> cloudId;
  final Value<int> franchiseeId;
  final Value<int> itemId;
  final Value<String> changeType;
  final Value<int> quantityChange;
  final Value<int> previousStock;
  final Value<int> newStock;
  final Value<String?> reason;
  final Value<String> status;
  final Value<int> requestedBy;
  final Value<int?> processedBy;
  final Value<DateTime?> processedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  const StockChangeRequestsCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.franchiseeId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.quantityChange = const Value.absent(),
    this.previousStock = const Value.absent(),
    this.newStock = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.processedBy = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  });
  StockChangeRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String cloudId,
    required int franchiseeId,
    required int itemId,
    required String changeType,
    required int quantityChange,
    required int previousStock,
    required int newStock,
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    required int requestedBy,
    this.processedBy = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
  }) : cloudId = Value(cloudId),
       franchiseeId = Value(franchiseeId),
       itemId = Value(itemId),
       changeType = Value(changeType),
       quantityChange = Value(quantityChange),
       previousStock = Value(previousStock),
       newStock = Value(newStock),
       requestedBy = Value(requestedBy);
  static Insertable<StockChangeRequest> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<int>? franchiseeId,
    Expression<int>? itemId,
    Expression<String>? changeType,
    Expression<int>? quantityChange,
    Expression<int>? previousStock,
    Expression<int>? newStock,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<int>? requestedBy,
    Expression<int>? processedBy,
    Expression<DateTime>? processedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (franchiseeId != null) 'franchisee_id': franchiseeId,
      if (itemId != null) 'item_id': itemId,
      if (changeType != null) 'change_type': changeType,
      if (quantityChange != null) 'quantity_change': quantityChange,
      if (previousStock != null) 'previous_stock': previousStock,
      if (newStock != null) 'new_stock': newStock,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (processedBy != null) 'processed_by': processedBy,
      if (processedAt != null) 'processed_at': processedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
    });
  }

  StockChangeRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? cloudId,
    Value<int>? franchiseeId,
    Value<int>? itemId,
    Value<String>? changeType,
    Value<int>? quantityChange,
    Value<int>? previousStock,
    Value<int>? newStock,
    Value<String?>? reason,
    Value<String>? status,
    Value<int>? requestedBy,
    Value<int?>? processedBy,
    Value<DateTime?>? processedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsSync,
  }) {
    return StockChangeRequestsCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      franchiseeId: franchiseeId ?? this.franchiseeId,
      itemId: itemId ?? this.itemId,
      changeType: changeType ?? this.changeType,
      quantityChange: quantityChange ?? this.quantityChange,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (franchiseeId.present) {
      map['franchisee_id'] = Variable<int>(franchiseeId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (quantityChange.present) {
      map['quantity_change'] = Variable<int>(quantityChange.value);
    }
    if (previousStock.present) {
      map['previous_stock'] = Variable<int>(previousStock.value);
    }
    if (newStock.present) {
      map['new_stock'] = Variable<int>(newStock.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<int>(requestedBy.value);
    }
    if (processedBy.present) {
      map['processed_by'] = Variable<int>(processedBy.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockChangeRequestsCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('franchiseeId: $franchiseeId, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('processedBy: $processedBy, ')
          ..write('processedAt: $processedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $StockReplenishmentRequestsTable stockReplenishmentRequests =
      $StockReplenishmentRequestsTable(this);
  late final $StockChangeRequestsTable stockChangeRequests =
      $StockChangeRequestsTable(this);
  late final OrganizationsDao organizationsDao = OrganizationsDao(
    this as AppDatabase,
  );
  late final RolesDao rolesDao = RolesDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final IngredientsDao ingredientsDao = IngredientsDao(
    this as AppDatabase,
  );
  late final StockReplenishmentRequestsDao stockReplenishmentRequestsDao =
      StockReplenishmentRequestsDao(this as AppDatabase);
  late final StockChangeRequestsDao stockChangeRequestsDao =
      StockChangeRequestsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    organizations,
    roles,
    users,
    categories,
    items,
    ingredients,
    recipeIngredients,
    stockReplenishmentRequests,
    stockChangeRequests,
  ];
}

typedef $$OrganizationsTableCreateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      required String cloudId,
      required String name,
      required String type,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> parentCommissaryId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$OrganizationsTableUpdateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> name,
      Value<String> type,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> parentCommissaryId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentCommissaryId => $composableBuilder(
    column: $table.parentCommissaryId,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCommissaryId => $composableBuilder(
    column: $table.parentCommissaryId,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get parentCommissaryId => $composableBuilder(
    column: $table.parentCommissaryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$OrganizationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrganizationsTable,
          Organization,
          $$OrganizationsTableFilterComposer,
          $$OrganizationsTableOrderingComposer,
          $$OrganizationsTableAnnotationComposer,
          $$OrganizationsTableCreateCompanionBuilder,
          $$OrganizationsTableUpdateCompanionBuilder,
          (
            Organization,
            BaseReferences<_$AppDatabase, $OrganizationsTable, Organization>,
          ),
          Organization,
          PrefetchHooks Function()
        > {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> parentCommissaryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => OrganizationsCompanion(
                id: id,
                cloudId: cloudId,
                name: name,
                type: type,
                address: address,
                phone: phone,
                email: email,
                parentCommissaryId: parentCommissaryId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String name,
                required String type,
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> parentCommissaryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => OrganizationsCompanion.insert(
                id: id,
                cloudId: cloudId,
                name: name,
                type: type,
                address: address,
                phone: phone,
                email: email,
                parentCommissaryId: parentCommissaryId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrganizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrganizationsTable,
      Organization,
      $$OrganizationsTableFilterComposer,
      $$OrganizationsTableOrderingComposer,
      $$OrganizationsTableAnnotationComposer,
      $$OrganizationsTableCreateCompanionBuilder,
      $$OrganizationsTableUpdateCompanionBuilder,
      (
        Organization,
        BaseReferences<_$AppDatabase, $OrganizationsTable, Organization>,
      ),
      Organization,
      PrefetchHooks Function()
    >;
typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String cloudId,
      required String name,
      Value<String?> description,
      Value<bool> canViewInventory,
      Value<bool> canManageInventory,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
      Value<bool> canViewReports,
      Value<bool> canManageBranches,
      Value<bool> isSystemRole,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> name,
      Value<String?> description,
      Value<bool> canViewInventory,
      Value<bool> canManageInventory,
      Value<bool> canManageEmployees,
      Value<bool> canManageRoles,
      Value<bool> canViewReports,
      Value<bool> canManageBranches,
      Value<bool> isSystemRole,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageInventory => $composableBuilder(
    column: $table.canManageInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canManageBranches => $composableBuilder(
    column: $table.canManageBranches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageInventory => $composableBuilder(
    column: $table.canManageInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canManageBranches => $composableBuilder(
    column: $table.canManageBranches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canViewInventory => $composableBuilder(
    column: $table.canViewInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageInventory => $composableBuilder(
    column: $table.canManageInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageEmployees => $composableBuilder(
    column: $table.canManageEmployees,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageRoles => $composableBuilder(
    column: $table.canManageRoles,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canViewReports => $composableBuilder(
    column: $table.canViewReports,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canManageBranches => $composableBuilder(
    column: $table.canManageBranches,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          Role,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
          Role,
          PrefetchHooks Function()
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canManageInventory = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canManageBranches = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                canViewInventory: canViewInventory,
                canManageInventory: canManageInventory,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
                canViewReports: canViewReports,
                canManageBranches: canManageBranches,
                isSystemRole: isSystemRole,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> canViewInventory = const Value.absent(),
                Value<bool> canManageInventory = const Value.absent(),
                Value<bool> canManageEmployees = const Value.absent(),
                Value<bool> canManageRoles = const Value.absent(),
                Value<bool> canViewReports = const Value.absent(),
                Value<bool> canManageBranches = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                canViewInventory: canViewInventory,
                canManageInventory: canManageInventory,
                canManageEmployees: canManageEmployees,
                canManageRoles: canManageRoles,
                canViewReports: canViewReports,
                canManageBranches: canManageBranches,
                isSystemRole: isSystemRole,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      Role,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (Role, BaseReferences<_$AppDatabase, $RolesTable, Role>),
      Role,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String cloudId,
      required String username,
      required String email,
      Value<String?> phone,
      required String passwordHash,
      required int organizationId,
      required int roleId,
      Value<String?> authUserId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> username,
      Value<String> email,
      Value<String?> phone,
      Value<String> passwordHash,
      Value<int> organizationId,
      Value<int> roleId,
      Value<String?> authUserId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
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

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
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
                Value<String> cloudId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<String?> authUserId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                cloudId: cloudId,
                username: username,
                email: email,
                phone: phone,
                passwordHash: passwordHash,
                organizationId: organizationId,
                roleId: roleId,
                authUserId: authUserId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String username,
                required String email,
                Value<String?> phone = const Value.absent(),
                required String passwordHash,
                required int organizationId,
                required int roleId,
                Value<String?> authUserId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                cloudId: cloudId,
                username: username,
                email: email,
                phone: phone,
                passwordHash: passwordHash,
                organizationId: organizationId,
                roleId: roleId,
                authUserId: authUserId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
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
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String cloudId,
      required String name,
      Value<String?> description,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> name,
      Value<String?> description,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String cloudId,
      required String name,
      Value<String?> description,
      Value<int> stock,
      Value<int> criticalLevel,
      Value<int> sold,
      Value<int> spoilage,
      Value<double> price,
      Value<double> cost,
      required int organizationId,
      Value<int?> categoryId,
      Value<String?> masterItemId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> name,
      Value<String?> description,
      Value<int> stock,
      Value<int> criticalLevel,
      Value<int> sold,
      Value<int> spoilage,
      Value<double> price,
      Value<double> cost,
      Value<int> organizationId,
      Value<int?> categoryId,
      Value<String?> masterItemId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sold => $composableBuilder(
    column: $table.sold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterItemId => $composableBuilder(
    column: $table.masterItemId,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sold => $composableBuilder(
    column: $table.sold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spoilage => $composableBuilder(
    column: $table.spoilage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterItemId => $composableBuilder(
    column: $table.masterItemId,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sold =>
      $composableBuilder(column: $table.sold, builder: (column) => column);

  GeneratedColumn<int> get spoilage =>
      $composableBuilder(column: $table.spoilage, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masterItemId => $composableBuilder(
    column: $table.masterItemId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> criticalLevel = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> masterItemId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                stock: stock,
                criticalLevel: criticalLevel,
                sold: sold,
                spoilage: spoilage,
                price: price,
                cost: cost,
                organizationId: organizationId,
                categoryId: categoryId,
                masterItemId: masterItemId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> criticalLevel = const Value.absent(),
                Value<int> sold = const Value.absent(),
                Value<int> spoilage = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                required int organizationId,
                Value<int?> categoryId = const Value.absent(),
                Value<String?> masterItemId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                cloudId: cloudId,
                name: name,
                description: description,
                stock: stock,
                criticalLevel: criticalLevel,
                sold: sold,
                spoilage: spoilage,
                price: price,
                cost: cost,
                organizationId: organizationId,
                categoryId: categoryId,
                masterItemId: masterItemId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      required String cloudId,
      required String name,
      required String unit,
      Value<double> stock,
      Value<double> criticalLevel,
      Value<double> costPerUnit,
      required int commissaryId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<String> name,
      Value<String> unit,
      Value<double> stock,
      Value<double> criticalLevel,
      Value<double> costPerUnit,
      Value<int> commissaryId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get criticalLevel => $composableBuilder(
    column: $table.criticalLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (
            Ingredient,
            BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
          ),
          Ingredient,
          PrefetchHooks Function()
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> criticalLevel = const Value.absent(),
                Value<double> costPerUnit = const Value.absent(),
                Value<int> commissaryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                cloudId: cloudId,
                name: name,
                unit: unit,
                stock: stock,
                criticalLevel: criticalLevel,
                costPerUnit: costPerUnit,
                commissaryId: commissaryId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required String name,
                required String unit,
                Value<double> stock = const Value.absent(),
                Value<double> criticalLevel = const Value.absent(),
                Value<double> costPerUnit = const Value.absent(),
                required int commissaryId,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                cloudId: cloudId,
                name: name,
                unit: unit,
                stock: stock,
                criticalLevel: criticalLevel,
                costPerUnit: costPerUnit,
                commissaryId: commissaryId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (
        Ingredient,
        BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
      ),
      Ingredient,
      PrefetchHooks Function()
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required String cloudId,
      required int itemId,
      required int ingredientId,
      required double quantity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<int> itemId,
      Value<int> ingredientId,
      Value<double> quantity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (
            RecipeIngredient,
            BaseReferences<
              _$AppDatabase,
              $RecipeIngredientsTable,
              RecipeIngredient
            >,
          ),
          RecipeIngredient,
          PrefetchHooks Function()
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> ingredientId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                cloudId: cloudId,
                itemId: itemId,
                ingredientId: ingredientId,
                quantity: quantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required int itemId,
                required int ingredientId,
                required double quantity,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                cloudId: cloudId,
                itemId: itemId,
                ingredientId: ingredientId,
                quantity: quantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (
        RecipeIngredient,
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        >,
      ),
      RecipeIngredient,
      PrefetchHooks Function()
    >;
typedef $$StockReplenishmentRequestsTableCreateCompanionBuilder =
    StockReplenishmentRequestsCompanion Function({
      Value<int> id,
      required String cloudId,
      required int franchiseeId,
      required int commissaryId,
      required int itemId,
      required int quantityRequested,
      Value<int?> quantityApproved,
      Value<String> status,
      Value<String?> requesterNotes,
      Value<String?> approverNotes,
      Value<int?> processedBy,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$StockReplenishmentRequestsTableUpdateCompanionBuilder =
    StockReplenishmentRequestsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<int> franchiseeId,
      Value<int> commissaryId,
      Value<int> itemId,
      Value<int> quantityRequested,
      Value<int?> quantityApproved,
      Value<String> status,
      Value<String?> requesterNotes,
      Value<String?> approverNotes,
      Value<int?> processedBy,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$StockReplenishmentRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityApproved => $composableBuilder(
    column: $table.quantityApproved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requesterNotes => $composableBuilder(
    column: $table.requesterNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approverNotes => $composableBuilder(
    column: $table.approverNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockReplenishmentRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityApproved => $composableBuilder(
    column: $table.quantityApproved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requesterNotes => $composableBuilder(
    column: $table.requesterNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approverNotes => $composableBuilder(
    column: $table.approverNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockReplenishmentRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockReplenishmentRequestsTable> {
  $$StockReplenishmentRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commissaryId => $composableBuilder(
    column: $table.commissaryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityApproved => $composableBuilder(
    column: $table.quantityApproved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get requesterNotes => $composableBuilder(
    column: $table.requesterNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approverNotes => $composableBuilder(
    column: $table.approverNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$StockReplenishmentRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockReplenishmentRequestsTable,
          StockReplenishmentRequest,
          $$StockReplenishmentRequestsTableFilterComposer,
          $$StockReplenishmentRequestsTableOrderingComposer,
          $$StockReplenishmentRequestsTableAnnotationComposer,
          $$StockReplenishmentRequestsTableCreateCompanionBuilder,
          $$StockReplenishmentRequestsTableUpdateCompanionBuilder,
          (
            StockReplenishmentRequest,
            BaseReferences<
              _$AppDatabase,
              $StockReplenishmentRequestsTable,
              StockReplenishmentRequest
            >,
          ),
          StockReplenishmentRequest,
          PrefetchHooks Function()
        > {
  $$StockReplenishmentRequestsTableTableManager(
    _$AppDatabase db,
    $StockReplenishmentRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockReplenishmentRequestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StockReplenishmentRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StockReplenishmentRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<int> franchiseeId = const Value.absent(),
                Value<int> commissaryId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> quantityRequested = const Value.absent(),
                Value<int?> quantityApproved = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> requesterNotes = const Value.absent(),
                Value<String?> approverNotes = const Value.absent(),
                Value<int?> processedBy = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => StockReplenishmentRequestsCompanion(
                id: id,
                cloudId: cloudId,
                franchiseeId: franchiseeId,
                commissaryId: commissaryId,
                itemId: itemId,
                quantityRequested: quantityRequested,
                quantityApproved: quantityApproved,
                status: status,
                requesterNotes: requesterNotes,
                approverNotes: approverNotes,
                processedBy: processedBy,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required int franchiseeId,
                required int commissaryId,
                required int itemId,
                required int quantityRequested,
                Value<int?> quantityApproved = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> requesterNotes = const Value.absent(),
                Value<String?> approverNotes = const Value.absent(),
                Value<int?> processedBy = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => StockReplenishmentRequestsCompanion.insert(
                id: id,
                cloudId: cloudId,
                franchiseeId: franchiseeId,
                commissaryId: commissaryId,
                itemId: itemId,
                quantityRequested: quantityRequested,
                quantityApproved: quantityApproved,
                status: status,
                requesterNotes: requesterNotes,
                approverNotes: approverNotes,
                processedBy: processedBy,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockReplenishmentRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockReplenishmentRequestsTable,
      StockReplenishmentRequest,
      $$StockReplenishmentRequestsTableFilterComposer,
      $$StockReplenishmentRequestsTableOrderingComposer,
      $$StockReplenishmentRequestsTableAnnotationComposer,
      $$StockReplenishmentRequestsTableCreateCompanionBuilder,
      $$StockReplenishmentRequestsTableUpdateCompanionBuilder,
      (
        StockReplenishmentRequest,
        BaseReferences<
          _$AppDatabase,
          $StockReplenishmentRequestsTable,
          StockReplenishmentRequest
        >,
      ),
      StockReplenishmentRequest,
      PrefetchHooks Function()
    >;
typedef $$StockChangeRequestsTableCreateCompanionBuilder =
    StockChangeRequestsCompanion Function({
      Value<int> id,
      required String cloudId,
      required int franchiseeId,
      required int itemId,
      required String changeType,
      required int quantityChange,
      required int previousStock,
      required int newStock,
      Value<String?> reason,
      Value<String> status,
      required int requestedBy,
      Value<int?> processedBy,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });
typedef $$StockChangeRequestsTableUpdateCompanionBuilder =
    StockChangeRequestsCompanion Function({
      Value<int> id,
      Value<String> cloudId,
      Value<int> franchiseeId,
      Value<int> itemId,
      Value<String> changeType,
      Value<int> quantityChange,
      Value<int> previousStock,
      Value<int> newStock,
      Value<String?> reason,
      Value<String> status,
      Value<int> requestedBy,
      Value<int?> processedBy,
      Value<DateTime?> processedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsSync,
    });

class $$StockChangeRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableFilterComposer({
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

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityChange => $composableBuilder(
    column: $table.quantityChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockChangeRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityChange => $composableBuilder(
    column: $table.quantityChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsSync => $composableBuilder(
    column: $table.needsSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockChangeRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockChangeRequestsTable> {
  $$StockChangeRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<int> get franchiseeId => $composableBuilder(
    column: $table.franchiseeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityChange => $composableBuilder(
    column: $table.quantityChange,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newStock =>
      $composableBuilder(column: $table.newStock, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get processedBy => $composableBuilder(
    column: $table.processedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$StockChangeRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockChangeRequestsTable,
          StockChangeRequest,
          $$StockChangeRequestsTableFilterComposer,
          $$StockChangeRequestsTableOrderingComposer,
          $$StockChangeRequestsTableAnnotationComposer,
          $$StockChangeRequestsTableCreateCompanionBuilder,
          $$StockChangeRequestsTableUpdateCompanionBuilder,
          (
            StockChangeRequest,
            BaseReferences<
              _$AppDatabase,
              $StockChangeRequestsTable,
              StockChangeRequest
            >,
          ),
          StockChangeRequest,
          PrefetchHooks Function()
        > {
  $$StockChangeRequestsTableTableManager(
    _$AppDatabase db,
    $StockChangeRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockChangeRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockChangeRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StockChangeRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cloudId = const Value.absent(),
                Value<int> franchiseeId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<int> quantityChange = const Value.absent(),
                Value<int> previousStock = const Value.absent(),
                Value<int> newStock = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> requestedBy = const Value.absent(),
                Value<int?> processedBy = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => StockChangeRequestsCompanion(
                id: id,
                cloudId: cloudId,
                franchiseeId: franchiseeId,
                itemId: itemId,
                changeType: changeType,
                quantityChange: quantityChange,
                previousStock: previousStock,
                newStock: newStock,
                reason: reason,
                status: status,
                requestedBy: requestedBy,
                processedBy: processedBy,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cloudId,
                required int franchiseeId,
                required int itemId,
                required String changeType,
                required int quantityChange,
                required int previousStock,
                required int newStock,
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int requestedBy,
                Value<int?> processedBy = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsSync = const Value.absent(),
              }) => StockChangeRequestsCompanion.insert(
                id: id,
                cloudId: cloudId,
                franchiseeId: franchiseeId,
                itemId: itemId,
                changeType: changeType,
                quantityChange: quantityChange,
                previousStock: previousStock,
                newStock: newStock,
                reason: reason,
                status: status,
                requestedBy: requestedBy,
                processedBy: processedBy,
                processedAt: processedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                needsSync: needsSync,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockChangeRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockChangeRequestsTable,
      StockChangeRequest,
      $$StockChangeRequestsTableFilterComposer,
      $$StockChangeRequestsTableOrderingComposer,
      $$StockChangeRequestsTableAnnotationComposer,
      $$StockChangeRequestsTableCreateCompanionBuilder,
      $$StockChangeRequestsTableUpdateCompanionBuilder,
      (
        StockChangeRequest,
        BaseReferences<
          _$AppDatabase,
          $StockChangeRequestsTable,
          StockChangeRequest
        >,
      ),
      StockChangeRequest,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$StockReplenishmentRequestsTableTableManager
  get stockReplenishmentRequests =>
      $$StockReplenishmentRequestsTableTableManager(
        _db,
        _db.stockReplenishmentRequests,
      );
  $$StockChangeRequestsTableTableManager get stockChangeRequests =>
      $$StockChangeRequestsTableTableManager(_db, _db.stockChangeRequests);
}
