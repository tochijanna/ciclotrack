// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WomenTable extends Women with TableInfo<$WomenTable, Woman> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WomenTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _initialsMeta = const VerificationMeta(
    'initials',
  );
  @override
  late final GeneratedColumn<String> initials = GeneratedColumn<String>(
    'initials',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('👩'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFE91E63),
  );
  static const VerificationMeta _privateNotesMeta = const VerificationMeta(
    'privateNotes',
  );
  @override
  late final GeneratedColumn<String> privateNotes = GeneratedColumn<String>(
    'private_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    initials,
    emoji,
    color,
    privateNotes,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'women';
  @override
  VerificationContext validateIntegrity(
    Insertable<Woman> instance, {
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
    if (data.containsKey('initials')) {
      context.handle(
        _initialsMeta,
        initials.isAcceptableOrUnknown(data['initials']!, _initialsMeta),
      );
    } else if (isInserting) {
      context.missing(_initialsMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('private_notes')) {
      context.handle(
        _privateNotesMeta,
        privateNotes.isAcceptableOrUnknown(
          data['private_notes']!,
          _privateNotesMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Woman map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Woman(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      initials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initials'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      privateNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_notes'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WomenTable createAlias(String alias) {
    return $WomenTable(attachedDatabase, alias);
  }
}

class Woman extends DataClass implements Insertable<Woman> {
  final int id;
  final String name;
  final String initials;
  final String emoji;
  final int color;
  final String privateNotes;
  final int sortOrder;
  final DateTime createdAt;
  const Woman({
    required this.id,
    required this.name,
    required this.initials,
    required this.emoji,
    required this.color,
    required this.privateNotes,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['initials'] = Variable<String>(initials);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    map['private_notes'] = Variable<String>(privateNotes);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WomenCompanion toCompanion(bool nullToAbsent) {
    return WomenCompanion(
      id: Value(id),
      name: Value(name),
      initials: Value(initials),
      emoji: Value(emoji),
      color: Value(color),
      privateNotes: Value(privateNotes),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Woman.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Woman(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      initials: serializer.fromJson<String>(json['initials']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
      privateNotes: serializer.fromJson<String>(json['privateNotes']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'initials': serializer.toJson<String>(initials),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
      'privateNotes': serializer.toJson<String>(privateNotes),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Woman copyWith({
    int? id,
    String? name,
    String? initials,
    String? emoji,
    int? color,
    String? privateNotes,
    int? sortOrder,
    DateTime? createdAt,
  }) => Woman(
    id: id ?? this.id,
    name: name ?? this.name,
    initials: initials ?? this.initials,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    privateNotes: privateNotes ?? this.privateNotes,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Woman copyWithCompanion(WomenCompanion data) {
    return Woman(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      initials: data.initials.present ? data.initials.value : this.initials,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      privateNotes: data.privateNotes.present
          ? data.privateNotes.value
          : this.privateNotes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Woman(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initials: $initials, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('privateNotes: $privateNotes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    initials,
    emoji,
    color,
    privateNotes,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Woman &&
          other.id == this.id &&
          other.name == this.name &&
          other.initials == this.initials &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.privateNotes == this.privateNotes &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class WomenCompanion extends UpdateCompanion<Woman> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> initials;
  final Value<String> emoji;
  final Value<int> color;
  final Value<String> privateNotes;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const WomenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.initials = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.privateNotes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WomenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String initials,
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.privateNotes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       initials = Value(initials),
       createdAt = Value(createdAt);
  static Insertable<Woman> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? initials,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<String>? privateNotes,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (initials != null) 'initials': initials,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (privateNotes != null) 'private_notes': privateNotes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WomenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? initials,
    Value<String>? emoji,
    Value<int>? color,
    Value<String>? privateNotes,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return WomenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      privateNotes: privateNotes ?? this.privateNotes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
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
    if (initials.present) {
      map['initials'] = Variable<String>(initials.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (privateNotes.present) {
      map['private_notes'] = Variable<String>(privateNotes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WomenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initials: $initials, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('privateNotes: $privateNotes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
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
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({int? id, String? name}) =>
      Tag(id: id ?? this.id, name: name ?? this.name);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WomanTagsTable extends WomanTags
    with TableInfo<$WomanTagsTable, WomanTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WomanTagsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, womanId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'woman_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<WomanTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {womanId, tagId},
  ];
  @override
  WomanTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WomanTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $WomanTagsTable createAlias(String alias) {
    return $WomanTagsTable(attachedDatabase, alias);
  }
}

class WomanTag extends DataClass implements Insertable<WomanTag> {
  final int id;
  final int womanId;
  final int tagId;
  const WomanTag({
    required this.id,
    required this.womanId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['woman_id'] = Variable<int>(womanId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  WomanTagsCompanion toCompanion(bool nullToAbsent) {
    return WomanTagsCompanion(
      id: Value(id),
      womanId: Value(womanId),
      tagId: Value(tagId),
    );
  }

  factory WomanTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WomanTag(
      id: serializer.fromJson<int>(json['id']),
      womanId: serializer.fromJson<int>(json['womanId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'womanId': serializer.toJson<int>(womanId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  WomanTag copyWith({int? id, int? womanId, int? tagId}) => WomanTag(
    id: id ?? this.id,
    womanId: womanId ?? this.womanId,
    tagId: tagId ?? this.tagId,
  );
  WomanTag copyWithCompanion(WomanTagsCompanion data) {
    return WomanTag(
      id: data.id.present ? data.id.value : this.id,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WomanTag(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, womanId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WomanTag &&
          other.id == this.id &&
          other.womanId == this.womanId &&
          other.tagId == this.tagId);
}

class WomanTagsCompanion extends UpdateCompanion<WomanTag> {
  final Value<int> id;
  final Value<int> womanId;
  final Value<int> tagId;
  const WomanTagsCompanion({
    this.id = const Value.absent(),
    this.womanId = const Value.absent(),
    this.tagId = const Value.absent(),
  });
  WomanTagsCompanion.insert({
    this.id = const Value.absent(),
    required int womanId,
    required int tagId,
  }) : womanId = Value(womanId),
       tagId = Value(tagId);
  static Insertable<WomanTag> custom({
    Expression<int>? id,
    Expression<int>? womanId,
    Expression<int>? tagId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (womanId != null) 'woman_id': womanId,
      if (tagId != null) 'tag_id': tagId,
    });
  }

  WomanTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? womanId,
    Value<int>? tagId,
  }) {
    return WomanTagsCompanion(
      id: id ?? this.id,
      womanId: womanId ?? this.womanId,
      tagId: tagId ?? this.tagId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WomanTagsCompanion(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }
}

class $PeriodLogsTable extends PeriodLogs
    with TableInfo<$PeriodLogsTable, PeriodLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flowLevelMeta = const VerificationMeta(
    'flowLevel',
  );
  @override
  late final GeneratedColumn<int> flowLevel = GeneratedColumn<int>(
    'flow_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    womanId,
    startDate,
    endDate,
    flowLevel,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('flow_level')) {
      context.handle(
        _flowLevelMeta,
        flowLevel.isAcceptableOrUnknown(data['flow_level']!, _flowLevelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      flowLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flow_level'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $PeriodLogsTable createAlias(String alias) {
    return $PeriodLogsTable(attachedDatabase, alias);
  }
}

class PeriodLog extends DataClass implements Insertable<PeriodLog> {
  final int id;
  final int womanId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? flowLevel;
  final String notes;
  const PeriodLog({
    required this.id,
    required this.womanId,
    required this.startDate,
    this.endDate,
    this.flowLevel,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['woman_id'] = Variable<int>(womanId);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || flowLevel != null) {
      map['flow_level'] = Variable<int>(flowLevel);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  PeriodLogsCompanion toCompanion(bool nullToAbsent) {
    return PeriodLogsCompanion(
      id: Value(id),
      womanId: Value(womanId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      flowLevel: flowLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(flowLevel),
      notes: Value(notes),
    );
  }

  factory PeriodLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodLog(
      id: serializer.fromJson<int>(json['id']),
      womanId: serializer.fromJson<int>(json['womanId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      flowLevel: serializer.fromJson<int?>(json['flowLevel']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'womanId': serializer.toJson<int>(womanId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'flowLevel': serializer.toJson<int?>(flowLevel),
      'notes': serializer.toJson<String>(notes),
    };
  }

  PeriodLog copyWith({
    int? id,
    int? womanId,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> flowLevel = const Value.absent(),
    String? notes,
  }) => PeriodLog(
    id: id ?? this.id,
    womanId: womanId ?? this.womanId,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    flowLevel: flowLevel.present ? flowLevel.value : this.flowLevel,
    notes: notes ?? this.notes,
  );
  PeriodLog copyWithCompanion(PeriodLogsCompanion data) {
    return PeriodLog(
      id: data.id.present ? data.id.value : this.id,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      flowLevel: data.flowLevel.present ? data.flowLevel.value : this.flowLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodLog(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, womanId, startDate, endDate, flowLevel, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodLog &&
          other.id == this.id &&
          other.womanId == this.womanId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.flowLevel == this.flowLevel &&
          other.notes == this.notes);
}

class PeriodLogsCompanion extends UpdateCompanion<PeriodLog> {
  final Value<int> id;
  final Value<int> womanId;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> flowLevel;
  final Value<String> notes;
  const PeriodLogsCompanion({
    this.id = const Value.absent(),
    this.womanId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.flowLevel = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PeriodLogsCompanion.insert({
    this.id = const Value.absent(),
    required int womanId,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.flowLevel = const Value.absent(),
    this.notes = const Value.absent(),
  }) : womanId = Value(womanId),
       startDate = Value(startDate);
  static Insertable<PeriodLog> custom({
    Expression<int>? id,
    Expression<int>? womanId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? flowLevel,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (womanId != null) 'woman_id': womanId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (flowLevel != null) 'flow_level': flowLevel,
      if (notes != null) 'notes': notes,
    });
  }

  PeriodLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? womanId,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? flowLevel,
    Value<String>? notes,
  }) {
    return PeriodLogsCompanion(
      id: id ?? this.id,
      womanId: womanId ?? this.womanId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowLevel: flowLevel ?? this.flowLevel,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (flowLevel.present) {
      map['flow_level'] = Variable<int>(flowLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodLogsCompanion(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $OvulationLogsTable extends OvulationLogs
    with TableInfo<$OvulationLogsTable, OvulationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OvulationLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cervicalMucusMeta = const VerificationMeta(
    'cervicalMucus',
  );
  @override
  late final GeneratedColumn<String> cervicalMucus = GeneratedColumn<String>(
    'cervical_mucus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lhTestMeta = const VerificationMeta('lhTest');
  @override
  late final GeneratedColumn<bool> lhTest = GeneratedColumn<bool>(
    'lh_test',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lh_test" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    womanId,
    date,
    temperature,
    cervicalMucus,
    lhTest,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ovulation_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<OvulationLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('cervical_mucus')) {
      context.handle(
        _cervicalMucusMeta,
        cervicalMucus.isAcceptableOrUnknown(
          data['cervical_mucus']!,
          _cervicalMucusMeta,
        ),
      );
    }
    if (data.containsKey('lh_test')) {
      context.handle(
        _lhTestMeta,
        lhTest.isAcceptableOrUnknown(data['lh_test']!, _lhTestMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OvulationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OvulationLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      cervicalMucus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cervical_mucus'],
      ),
      lhTest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lh_test'],
      ),
    );
  }

  @override
  $OvulationLogsTable createAlias(String alias) {
    return $OvulationLogsTable(attachedDatabase, alias);
  }
}

class OvulationLog extends DataClass implements Insertable<OvulationLog> {
  final int id;
  final int womanId;
  final DateTime date;
  final double? temperature;
  final String? cervicalMucus;
  final bool? lhTest;
  const OvulationLog({
    required this.id,
    required this.womanId,
    required this.date,
    this.temperature,
    this.cervicalMucus,
    this.lhTest,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['woman_id'] = Variable<int>(womanId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || cervicalMucus != null) {
      map['cervical_mucus'] = Variable<String>(cervicalMucus);
    }
    if (!nullToAbsent || lhTest != null) {
      map['lh_test'] = Variable<bool>(lhTest);
    }
    return map;
  }

  OvulationLogsCompanion toCompanion(bool nullToAbsent) {
    return OvulationLogsCompanion(
      id: Value(id),
      womanId: Value(womanId),
      date: Value(date),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      cervicalMucus: cervicalMucus == null && nullToAbsent
          ? const Value.absent()
          : Value(cervicalMucus),
      lhTest: lhTest == null && nullToAbsent
          ? const Value.absent()
          : Value(lhTest),
    );
  }

  factory OvulationLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OvulationLog(
      id: serializer.fromJson<int>(json['id']),
      womanId: serializer.fromJson<int>(json['womanId']),
      date: serializer.fromJson<DateTime>(json['date']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      cervicalMucus: serializer.fromJson<String?>(json['cervicalMucus']),
      lhTest: serializer.fromJson<bool?>(json['lhTest']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'womanId': serializer.toJson<int>(womanId),
      'date': serializer.toJson<DateTime>(date),
      'temperature': serializer.toJson<double?>(temperature),
      'cervicalMucus': serializer.toJson<String?>(cervicalMucus),
      'lhTest': serializer.toJson<bool?>(lhTest),
    };
  }

  OvulationLog copyWith({
    int? id,
    int? womanId,
    DateTime? date,
    Value<double?> temperature = const Value.absent(),
    Value<String?> cervicalMucus = const Value.absent(),
    Value<bool?> lhTest = const Value.absent(),
  }) => OvulationLog(
    id: id ?? this.id,
    womanId: womanId ?? this.womanId,
    date: date ?? this.date,
    temperature: temperature.present ? temperature.value : this.temperature,
    cervicalMucus: cervicalMucus.present
        ? cervicalMucus.value
        : this.cervicalMucus,
    lhTest: lhTest.present ? lhTest.value : this.lhTest,
  );
  OvulationLog copyWithCompanion(OvulationLogsCompanion data) {
    return OvulationLog(
      id: data.id.present ? data.id.value : this.id,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      date: data.date.present ? data.date.value : this.date,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      cervicalMucus: data.cervicalMucus.present
          ? data.cervicalMucus.value
          : this.cervicalMucus,
      lhTest: data.lhTest.present ? data.lhTest.value : this.lhTest,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OvulationLog(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('date: $date, ')
          ..write('temperature: $temperature, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('lhTest: $lhTest')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, womanId, date, temperature, cervicalMucus, lhTest);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OvulationLog &&
          other.id == this.id &&
          other.womanId == this.womanId &&
          other.date == this.date &&
          other.temperature == this.temperature &&
          other.cervicalMucus == this.cervicalMucus &&
          other.lhTest == this.lhTest);
}

class OvulationLogsCompanion extends UpdateCompanion<OvulationLog> {
  final Value<int> id;
  final Value<int> womanId;
  final Value<DateTime> date;
  final Value<double?> temperature;
  final Value<String?> cervicalMucus;
  final Value<bool?> lhTest;
  const OvulationLogsCompanion({
    this.id = const Value.absent(),
    this.womanId = const Value.absent(),
    this.date = const Value.absent(),
    this.temperature = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.lhTest = const Value.absent(),
  });
  OvulationLogsCompanion.insert({
    this.id = const Value.absent(),
    required int womanId,
    required DateTime date,
    this.temperature = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.lhTest = const Value.absent(),
  }) : womanId = Value(womanId),
       date = Value(date);
  static Insertable<OvulationLog> custom({
    Expression<int>? id,
    Expression<int>? womanId,
    Expression<DateTime>? date,
    Expression<double>? temperature,
    Expression<String>? cervicalMucus,
    Expression<bool>? lhTest,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (womanId != null) 'woman_id': womanId,
      if (date != null) 'date': date,
      if (temperature != null) 'temperature': temperature,
      if (cervicalMucus != null) 'cervical_mucus': cervicalMucus,
      if (lhTest != null) 'lh_test': lhTest,
    });
  }

  OvulationLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? womanId,
    Value<DateTime>? date,
    Value<double?>? temperature,
    Value<String?>? cervicalMucus,
    Value<bool?>? lhTest,
  }) {
    return OvulationLogsCompanion(
      id: id ?? this.id,
      womanId: womanId ?? this.womanId,
      date: date ?? this.date,
      temperature: temperature ?? this.temperature,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      lhTest: lhTest ?? this.lhTest,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (cervicalMucus.present) {
      map['cervical_mucus'] = Variable<String>(cervicalMucus.value);
    }
    if (lhTest.present) {
      map['lh_test'] = Variable<bool>(lhTest.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OvulationLogsCompanion(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('date: $date, ')
          ..write('temperature: $temperature, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('lhTest: $lhTest')
          ..write(')'))
        .toString();
  }
}

class $SymptomsTable extends Symptoms
    with TableInfo<$SymptomsTable, SymptomLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    womanId,
    date,
    type,
    severity,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<SymptomLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $SymptomsTable createAlias(String alias) {
    return $SymptomsTable(attachedDatabase, alias);
  }
}

class SymptomLog extends DataClass implements Insertable<SymptomLog> {
  final int id;
  final int womanId;
  final DateTime date;
  final String type;
  final int severity;
  final String notes;
  const SymptomLog({
    required this.id,
    required this.womanId,
    required this.date,
    required this.type,
    required this.severity,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['woman_id'] = Variable<int>(womanId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<int>(severity);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  SymptomsCompanion toCompanion(bool nullToAbsent) {
    return SymptomsCompanion(
      id: Value(id),
      womanId: Value(womanId),
      date: Value(date),
      type: Value(type),
      severity: Value(severity),
      notes: Value(notes),
    );
  }

  factory SymptomLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomLog(
      id: serializer.fromJson<int>(json['id']),
      womanId: serializer.fromJson<int>(json['womanId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<int>(json['severity']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'womanId': serializer.toJson<int>(womanId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<int>(severity),
      'notes': serializer.toJson<String>(notes),
    };
  }

  SymptomLog copyWith({
    int? id,
    int? womanId,
    DateTime? date,
    String? type,
    int? severity,
    String? notes,
  }) => SymptomLog(
    id: id ?? this.id,
    womanId: womanId ?? this.womanId,
    date: date ?? this.date,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    notes: notes ?? this.notes,
  );
  SymptomLog copyWithCompanion(SymptomsCompanion data) {
    return SymptomLog(
      id: data.id.present ? data.id.value : this.id,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLog(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, womanId, date, type, severity, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomLog &&
          other.id == this.id &&
          other.womanId == this.womanId &&
          other.date == this.date &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.notes == this.notes);
}

class SymptomsCompanion extends UpdateCompanion<SymptomLog> {
  final Value<int> id;
  final Value<int> womanId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> severity;
  final Value<String> notes;
  const SymptomsCompanion({
    this.id = const Value.absent(),
    this.womanId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SymptomsCompanion.insert({
    this.id = const Value.absent(),
    required int womanId,
    required DateTime date,
    required String type,
    this.severity = const Value.absent(),
    this.notes = const Value.absent(),
  }) : womanId = Value(womanId),
       date = Value(date),
       type = Value(type);
  static Insertable<SymptomLog> custom({
    Expression<int>? id,
    Expression<int>? womanId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? severity,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (womanId != null) 'woman_id': womanId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (notes != null) 'notes': notes,
    });
  }

  SymptomsCompanion copyWith({
    Value<int>? id,
    Value<int>? womanId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int>? severity,
    Value<String>? notes,
  }) {
    return SymptomsCompanion(
      id: id ?? this.id,
      womanId: womanId ?? this.womanId,
      date: date ?? this.date,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomsCompanion(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _encounterTimeMeta = const VerificationMeta(
    'encounterTime',
  );
  @override
  late final GeneratedColumn<DateTime> encounterTime =
      GeneratedColumn<DateTime>(
        'date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _protectionMeta = const VerificationMeta(
    'protection',
  );
  @override
  late final GeneratedColumn<String> protection = GeneratedColumn<String>(
    'protection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterTime,
    protection,
    outcome,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Encounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_time')) {
      context.handle(
        _encounterTimeMeta,
        encounterTime.isAcceptableOrUnknown(
          data['date_time']!,
          _encounterTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterTimeMeta);
    }
    if (data.containsKey('protection')) {
      context.handle(
        _protectionMeta,
        protection.isAcceptableOrUnknown(data['protection']!, _protectionMeta),
      );
    } else if (isInserting) {
      context.missing(_protectionMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      encounterTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time'],
      )!,
      protection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protection'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final int id;
  final DateTime encounterTime;
  final String protection;
  final String? outcome;
  final String notes;
  const Encounter({
    required this.id,
    required this.encounterTime,
    required this.protection,
    this.outcome,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_time'] = Variable<DateTime>(encounterTime);
    map['protection'] = Variable<String>(protection);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      encounterTime: Value(encounterTime),
      protection: Value(protection),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      notes: Value(notes),
    );
  }

  factory Encounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<int>(json['id']),
      encounterTime: serializer.fromJson<DateTime>(json['encounterTime']),
      protection: serializer.fromJson<String>(json['protection']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encounterTime': serializer.toJson<DateTime>(encounterTime),
      'protection': serializer.toJson<String>(protection),
      'outcome': serializer.toJson<String?>(outcome),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Encounter copyWith({
    int? id,
    DateTime? encounterTime,
    String? protection,
    Value<String?> outcome = const Value.absent(),
    String? notes,
  }) => Encounter(
    id: id ?? this.id,
    encounterTime: encounterTime ?? this.encounterTime,
    protection: protection ?? this.protection,
    outcome: outcome.present ? outcome.value : this.outcome,
    notes: notes ?? this.notes,
  );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      encounterTime: data.encounterTime.present
          ? data.encounterTime.value
          : this.encounterTime,
      protection: data.protection.present
          ? data.protection.value
          : this.protection,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('encounterTime: $encounterTime, ')
          ..write('protection: $protection, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, encounterTime, protection, outcome, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.encounterTime == this.encounterTime &&
          other.protection == this.protection &&
          other.outcome == this.outcome &&
          other.notes == this.notes);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<int> id;
  final Value<DateTime> encounterTime;
  final Value<String> protection;
  final Value<String?> outcome;
  final Value<String> notes;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.encounterTime = const Value.absent(),
    this.protection = const Value.absent(),
    this.outcome = const Value.absent(),
    this.notes = const Value.absent(),
  });
  EncountersCompanion.insert({
    this.id = const Value.absent(),
    required DateTime encounterTime,
    required String protection,
    this.outcome = const Value.absent(),
    this.notes = const Value.absent(),
  }) : encounterTime = Value(encounterTime),
       protection = Value(protection);
  static Insertable<Encounter> custom({
    Expression<int>? id,
    Expression<DateTime>? encounterTime,
    Expression<String>? protection,
    Expression<String>? outcome,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterTime != null) 'date_time': encounterTime,
      if (protection != null) 'protection': protection,
      if (outcome != null) 'outcome': outcome,
      if (notes != null) 'notes': notes,
    });
  }

  EncountersCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? encounterTime,
    Value<String>? protection,
    Value<String?>? outcome,
    Value<String>? notes,
  }) {
    return EncountersCompanion(
      id: id ?? this.id,
      encounterTime: encounterTime ?? this.encounterTime,
      protection: protection ?? this.protection,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encounterTime.present) {
      map['date_time'] = Variable<DateTime>(encounterTime.value);
    }
    if (protection.present) {
      map['protection'] = Variable<String>(protection.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('encounterTime: $encounterTime, ')
          ..write('protection: $protection, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $EncounterWomenTable extends EncounterWomen
    with TableInfo<$EncounterWomenTable, EncounterWoman> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncounterWomenTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<int> encounterId = GeneratedColumn<int>(
    'encounter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounters (id)',
    ),
  );
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterId,
    womanId,
    relationshipType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounter_women';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncounterWoman> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncounterWoman map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncounterWoman(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounter_id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
    );
  }

  @override
  $EncounterWomenTable createAlias(String alias) {
    return $EncounterWomenTable(attachedDatabase, alias);
  }
}

class EncounterWoman extends DataClass implements Insertable<EncounterWoman> {
  final int id;
  final int encounterId;
  final int womanId;
  final String relationshipType;
  const EncounterWoman({
    required this.id,
    required this.encounterId,
    required this.womanId,
    required this.relationshipType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['encounter_id'] = Variable<int>(encounterId);
    map['woman_id'] = Variable<int>(womanId);
    map['relationship_type'] = Variable<String>(relationshipType);
    return map;
  }

  EncounterWomenCompanion toCompanion(bool nullToAbsent) {
    return EncounterWomenCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      womanId: Value(womanId),
      relationshipType: Value(relationshipType),
    );
  }

  factory EncounterWoman.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncounterWoman(
      id: serializer.fromJson<int>(json['id']),
      encounterId: serializer.fromJson<int>(json['encounterId']),
      womanId: serializer.fromJson<int>(json['womanId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encounterId': serializer.toJson<int>(encounterId),
      'womanId': serializer.toJson<int>(womanId),
      'relationshipType': serializer.toJson<String>(relationshipType),
    };
  }

  EncounterWoman copyWith({
    int? id,
    int? encounterId,
    int? womanId,
    String? relationshipType,
  }) => EncounterWoman(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    womanId: womanId ?? this.womanId,
    relationshipType: relationshipType ?? this.relationshipType,
  );
  EncounterWoman copyWithCompanion(EncounterWomenCompanion data) {
    return EncounterWoman(
      id: data.id.present ? data.id.value : this.id,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncounterWoman(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('womanId: $womanId, ')
          ..write('relationshipType: $relationshipType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, encounterId, womanId, relationshipType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncounterWoman &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.womanId == this.womanId &&
          other.relationshipType == this.relationshipType);
}

class EncounterWomenCompanion extends UpdateCompanion<EncounterWoman> {
  final Value<int> id;
  final Value<int> encounterId;
  final Value<int> womanId;
  final Value<String> relationshipType;
  const EncounterWomenCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.womanId = const Value.absent(),
    this.relationshipType = const Value.absent(),
  });
  EncounterWomenCompanion.insert({
    this.id = const Value.absent(),
    required int encounterId,
    required int womanId,
    this.relationshipType = const Value.absent(),
  }) : encounterId = Value(encounterId),
       womanId = Value(womanId);
  static Insertable<EncounterWoman> custom({
    Expression<int>? id,
    Expression<int>? encounterId,
    Expression<int>? womanId,
    Expression<String>? relationshipType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (womanId != null) 'woman_id': womanId,
      if (relationshipType != null) 'relationship_type': relationshipType,
    });
  }

  EncounterWomenCompanion copyWith({
    Value<int>? id,
    Value<int>? encounterId,
    Value<int>? womanId,
    Value<String>? relationshipType,
  }) {
    return EncounterWomenCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      womanId: womanId ?? this.womanId,
      relationshipType: relationshipType ?? this.relationshipType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<int>(encounterId.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncounterWomenCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('womanId: $womanId, ')
          ..write('relationshipType: $relationshipType')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _womanIdMeta = const VerificationMeta(
    'womanId',
  );
  @override
  late final GeneratedColumn<int> womanId = GeneratedColumn<int>(
    'woman_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES women (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cycleDayStartMeta = const VerificationMeta(
    'cycleDayStart',
  );
  @override
  late final GeneratedColumn<int> cycleDayStart = GeneratedColumn<int>(
    'cycle_day_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleDayEndMeta = const VerificationMeta(
    'cycleDayEnd',
  );
  @override
  late final GeneratedColumn<int> cycleDayEnd = GeneratedColumn<int>(
    'cycle_day_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    womanId,
    cycleDayStart,
    cycleDayEnd,
    message,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('woman_id')) {
      context.handle(
        _womanIdMeta,
        womanId.isAcceptableOrUnknown(data['woman_id']!, _womanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_womanIdMeta);
    }
    if (data.containsKey('cycle_day_start')) {
      context.handle(
        _cycleDayStartMeta,
        cycleDayStart.isAcceptableOrUnknown(
          data['cycle_day_start']!,
          _cycleDayStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleDayStartMeta);
    }
    if (data.containsKey('cycle_day_end')) {
      context.handle(
        _cycleDayEndMeta,
        cycleDayEnd.isAcceptableOrUnknown(
          data['cycle_day_end']!,
          _cycleDayEndMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleDayEndMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      womanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}woman_id'],
      )!,
      cycleDayStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_day_start'],
      )!,
      cycleDayEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_day_end'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int womanId;
  final int cycleDayStart;
  final int cycleDayEnd;
  final String message;
  final bool enabled;
  const Reminder({
    required this.id,
    required this.womanId,
    required this.cycleDayStart,
    required this.cycleDayEnd,
    required this.message,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['woman_id'] = Variable<int>(womanId);
    map['cycle_day_start'] = Variable<int>(cycleDayStart);
    map['cycle_day_end'] = Variable<int>(cycleDayEnd);
    map['message'] = Variable<String>(message);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      womanId: Value(womanId),
      cycleDayStart: Value(cycleDayStart),
      cycleDayEnd: Value(cycleDayEnd),
      message: Value(message),
      enabled: Value(enabled),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      womanId: serializer.fromJson<int>(json['womanId']),
      cycleDayStart: serializer.fromJson<int>(json['cycleDayStart']),
      cycleDayEnd: serializer.fromJson<int>(json['cycleDayEnd']),
      message: serializer.fromJson<String>(json['message']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'womanId': serializer.toJson<int>(womanId),
      'cycleDayStart': serializer.toJson<int>(cycleDayStart),
      'cycleDayEnd': serializer.toJson<int>(cycleDayEnd),
      'message': serializer.toJson<String>(message),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  Reminder copyWith({
    int? id,
    int? womanId,
    int? cycleDayStart,
    int? cycleDayEnd,
    String? message,
    bool? enabled,
  }) => Reminder(
    id: id ?? this.id,
    womanId: womanId ?? this.womanId,
    cycleDayStart: cycleDayStart ?? this.cycleDayStart,
    cycleDayEnd: cycleDayEnd ?? this.cycleDayEnd,
    message: message ?? this.message,
    enabled: enabled ?? this.enabled,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      womanId: data.womanId.present ? data.womanId.value : this.womanId,
      cycleDayStart: data.cycleDayStart.present
          ? data.cycleDayStart.value
          : this.cycleDayStart,
      cycleDayEnd: data.cycleDayEnd.present
          ? data.cycleDayEnd.value
          : this.cycleDayEnd,
      message: data.message.present ? data.message.value : this.message,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('cycleDayStart: $cycleDayStart, ')
          ..write('cycleDayEnd: $cycleDayEnd, ')
          ..write('message: $message, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, womanId, cycleDayStart, cycleDayEnd, message, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.womanId == this.womanId &&
          other.cycleDayStart == this.cycleDayStart &&
          other.cycleDayEnd == this.cycleDayEnd &&
          other.message == this.message &&
          other.enabled == this.enabled);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> womanId;
  final Value<int> cycleDayStart;
  final Value<int> cycleDayEnd;
  final Value<String> message;
  final Value<bool> enabled;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.womanId = const Value.absent(),
    this.cycleDayStart = const Value.absent(),
    this.cycleDayEnd = const Value.absent(),
    this.message = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int womanId,
    required int cycleDayStart,
    required int cycleDayEnd,
    required String message,
    this.enabled = const Value.absent(),
  }) : womanId = Value(womanId),
       cycleDayStart = Value(cycleDayStart),
       cycleDayEnd = Value(cycleDayEnd),
       message = Value(message);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? womanId,
    Expression<int>? cycleDayStart,
    Expression<int>? cycleDayEnd,
    Expression<String>? message,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (womanId != null) 'woman_id': womanId,
      if (cycleDayStart != null) 'cycle_day_start': cycleDayStart,
      if (cycleDayEnd != null) 'cycle_day_end': cycleDayEnd,
      if (message != null) 'message': message,
      if (enabled != null) 'enabled': enabled,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? womanId,
    Value<int>? cycleDayStart,
    Value<int>? cycleDayEnd,
    Value<String>? message,
    Value<bool>? enabled,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      womanId: womanId ?? this.womanId,
      cycleDayStart: cycleDayStart ?? this.cycleDayStart,
      cycleDayEnd: cycleDayEnd ?? this.cycleDayEnd,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (womanId.present) {
      map['woman_id'] = Variable<int>(womanId.value);
    }
    if (cycleDayStart.present) {
      map['cycle_day_start'] = Variable<int>(cycleDayStart.value);
    }
    if (cycleDayEnd.present) {
      map['cycle_day_end'] = Variable<int>(cycleDayEnd.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('womanId: $womanId, ')
          ..write('cycleDayStart: $cycleDayStart, ')
          ..write('cycleDayEnd: $cycleDayEnd, ')
          ..write('message: $message, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WomenTable women = $WomenTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $WomanTagsTable womanTags = $WomanTagsTable(this);
  late final $PeriodLogsTable periodLogs = $PeriodLogsTable(this);
  late final $OvulationLogsTable ovulationLogs = $OvulationLogsTable(this);
  late final $SymptomsTable symptoms = $SymptomsTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $EncounterWomenTable encounterWomen = $EncounterWomenTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    women,
    tags,
    womanTags,
    periodLogs,
    ovulationLogs,
    symptoms,
    encounters,
    encounterWomen,
    reminders,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('woman_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('woman_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('period_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ovulation_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('symptoms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('encounter_women', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'women',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WomenTableCreateCompanionBuilder =
    WomenCompanion Function({
      Value<int> id,
      required String name,
      required String initials,
      Value<String> emoji,
      Value<int> color,
      Value<String> privateNotes,
      Value<int> sortOrder,
      required DateTime createdAt,
    });
typedef $$WomenTableUpdateCompanionBuilder =
    WomenCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> initials,
      Value<String> emoji,
      Value<int> color,
      Value<String> privateNotes,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$WomenTableReferences
    extends BaseReferences<_$AppDatabase, $WomenTable, Woman> {
  $$WomenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WomanTagsTable, List<WomanTag>>
  _womanTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.womanTags,
    aliasName: $_aliasNameGenerator(db.women.id, db.womanTags.womanId),
  );

  $$WomanTagsTableProcessedTableManager get womanTagsRefs {
    final manager = $$WomanTagsTableTableManager(
      $_db,
      $_db.womanTags,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_womanTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PeriodLogsTable, List<PeriodLog>>
  _periodLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.periodLogs,
    aliasName: $_aliasNameGenerator(db.women.id, db.periodLogs.womanId),
  );

  $$PeriodLogsTableProcessedTableManager get periodLogsRefs {
    final manager = $$PeriodLogsTableTableManager(
      $_db,
      $_db.periodLogs,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_periodLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OvulationLogsTable, List<OvulationLog>>
  _ovulationLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ovulationLogs,
    aliasName: $_aliasNameGenerator(db.women.id, db.ovulationLogs.womanId),
  );

  $$OvulationLogsTableProcessedTableManager get ovulationLogsRefs {
    final manager = $$OvulationLogsTableTableManager(
      $_db,
      $_db.ovulationLogs,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ovulationLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SymptomsTable, List<SymptomLog>>
  _symptomsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.symptoms,
    aliasName: $_aliasNameGenerator(db.women.id, db.symptoms.womanId),
  );

  $$SymptomsTableProcessedTableManager get symptomsRefs {
    final manager = $$SymptomsTableTableManager(
      $_db,
      $_db.symptoms,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_symptomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EncounterWomenTable, List<EncounterWoman>>
  _encounterWomenRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.encounterWomen,
    aliasName: $_aliasNameGenerator(db.women.id, db.encounterWomen.womanId),
  );

  $$EncounterWomenTableProcessedTableManager get encounterWomenRefs {
    final manager = $$EncounterWomenTableTableManager(
      $_db,
      $_db.encounterWomen,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_encounterWomenRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: $_aliasNameGenerator(db.women.id, db.reminders.womanId),
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.womanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WomenTableFilterComposer extends Composer<_$AppDatabase, $WomenTable> {
  $$WomenTableFilterComposer({
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

  ColumnFilters<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> womanTagsRefs(
    Expression<bool> Function($$WomanTagsTableFilterComposer f) f,
  ) {
    final $$WomanTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.womanTags,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomanTagsTableFilterComposer(
            $db: $db,
            $table: $db.womanTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> periodLogsRefs(
    Expression<bool> Function($$PeriodLogsTableFilterComposer f) f,
  ) {
    final $$PeriodLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodLogs,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodLogsTableFilterComposer(
            $db: $db,
            $table: $db.periodLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ovulationLogsRefs(
    Expression<bool> Function($$OvulationLogsTableFilterComposer f) f,
  ) {
    final $$OvulationLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ovulationLogs,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OvulationLogsTableFilterComposer(
            $db: $db,
            $table: $db.ovulationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> symptomsRefs(
    Expression<bool> Function($$SymptomsTableFilterComposer f) f,
  ) {
    final $$SymptomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptoms,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomsTableFilterComposer(
            $db: $db,
            $table: $db.symptoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> encounterWomenRefs(
    Expression<bool> Function($$EncounterWomenTableFilterComposer f) f,
  ) {
    final $$EncounterWomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterWomen,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterWomenTableFilterComposer(
            $db: $db,
            $table: $db.encounterWomen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WomenTableOrderingComposer
    extends Composer<_$AppDatabase, $WomenTable> {
  $$WomenTableOrderingComposer({
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

  ColumnOrderings<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WomenTableAnnotationComposer
    extends Composer<_$AppDatabase, $WomenTable> {
  $$WomenTableAnnotationComposer({
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

  GeneratedColumn<String> get initials =>
      $composableBuilder(column: $table.initials, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get privateNotes => $composableBuilder(
    column: $table.privateNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> womanTagsRefs<T extends Object>(
    Expression<T> Function($$WomanTagsTableAnnotationComposer a) f,
  ) {
    final $$WomanTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.womanTags,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomanTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.womanTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> periodLogsRefs<T extends Object>(
    Expression<T> Function($$PeriodLogsTableAnnotationComposer a) f,
  ) {
    final $$PeriodLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodLogs,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.periodLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ovulationLogsRefs<T extends Object>(
    Expression<T> Function($$OvulationLogsTableAnnotationComposer a) f,
  ) {
    final $$OvulationLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ovulationLogs,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OvulationLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.ovulationLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> symptomsRefs<T extends Object>(
    Expression<T> Function($$SymptomsTableAnnotationComposer a) f,
  ) {
    final $$SymptomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptoms,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomsTableAnnotationComposer(
            $db: $db,
            $table: $db.symptoms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> encounterWomenRefs<T extends Object>(
    Expression<T> Function($$EncounterWomenTableAnnotationComposer a) f,
  ) {
    final $$EncounterWomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterWomen,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterWomenTableAnnotationComposer(
            $db: $db,
            $table: $db.encounterWomen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.womanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WomenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WomenTable,
          Woman,
          $$WomenTableFilterComposer,
          $$WomenTableOrderingComposer,
          $$WomenTableAnnotationComposer,
          $$WomenTableCreateCompanionBuilder,
          $$WomenTableUpdateCompanionBuilder,
          (Woman, $$WomenTableReferences),
          Woman,
          PrefetchHooks Function({
            bool womanTagsRefs,
            bool periodLogsRefs,
            bool ovulationLogsRefs,
            bool symptomsRefs,
            bool encounterWomenRefs,
            bool remindersRefs,
          })
        > {
  $$WomenTableTableManager(_$AppDatabase db, $WomenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WomenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WomenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WomenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> initials = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> privateNotes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WomenCompanion(
                id: id,
                name: name,
                initials: initials,
                emoji: emoji,
                color: color,
                privateNotes: privateNotes,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String initials,
                Value<String> emoji = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> privateNotes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
              }) => WomenCompanion.insert(
                id: id,
                name: name,
                initials: initials,
                emoji: emoji,
                color: color,
                privateNotes: privateNotes,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WomenTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                womanTagsRefs = false,
                periodLogsRefs = false,
                ovulationLogsRefs = false,
                symptomsRefs = false,
                encounterWomenRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (womanTagsRefs) db.womanTags,
                    if (periodLogsRefs) db.periodLogs,
                    if (ovulationLogsRefs) db.ovulationLogs,
                    if (symptomsRefs) db.symptoms,
                    if (encounterWomenRefs) db.encounterWomen,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (womanTagsRefs)
                        await $_getPrefetchedData<Woman, $WomenTable, WomanTag>(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._womanTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).womanTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (periodLogsRefs)
                        await $_getPrefetchedData<
                          Woman,
                          $WomenTable,
                          PeriodLog
                        >(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._periodLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).periodLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ovulationLogsRefs)
                        await $_getPrefetchedData<
                          Woman,
                          $WomenTable,
                          OvulationLog
                        >(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._ovulationLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).ovulationLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (symptomsRefs)
                        await $_getPrefetchedData<
                          Woman,
                          $WomenTable,
                          SymptomLog
                        >(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._symptomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).symptomsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (encounterWomenRefs)
                        await $_getPrefetchedData<
                          Woman,
                          $WomenTable,
                          EncounterWoman
                        >(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._encounterWomenRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).encounterWomenRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<Woman, $WomenTable, Reminder>(
                          currentTable: table,
                          referencedTable: $$WomenTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WomenTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.womanId == item.id,
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

typedef $$WomenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WomenTable,
      Woman,
      $$WomenTableFilterComposer,
      $$WomenTableOrderingComposer,
      $$WomenTableAnnotationComposer,
      $$WomenTableCreateCompanionBuilder,
      $$WomenTableUpdateCompanionBuilder,
      (Woman, $$WomenTableReferences),
      Woman,
      PrefetchHooks Function({
        bool womanTagsRefs,
        bool periodLogsRefs,
        bool ovulationLogsRefs,
        bool symptomsRefs,
        bool encounterWomenRefs,
        bool remindersRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({Value<int> id, required String name});
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({Value<int> id, Value<String> name});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WomanTagsTable, List<WomanTag>>
  _womanTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.womanTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.womanTags.tagId),
  );

  $$WomanTagsTableProcessedTableManager get womanTagsRefs {
    final manager = $$WomanTagsTableTableManager(
      $_db,
      $_db.womanTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_womanTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  Expression<bool> womanTagsRefs(
    Expression<bool> Function($$WomanTagsTableFilterComposer f) f,
  ) {
    final $$WomanTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.womanTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomanTagsTableFilterComposer(
            $db: $db,
            $table: $db.womanTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
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

  Expression<T> womanTagsRefs<T extends Object>(
    Expression<T> Function($$WomanTagsTableAnnotationComposer a) f,
  ) {
    final $$WomanTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.womanTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomanTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.womanTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool womanTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({womanTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (womanTagsRefs) db.womanTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (womanTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, WomanTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._womanTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).womanTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool womanTagsRefs})
    >;
typedef $$WomanTagsTableCreateCompanionBuilder =
    WomanTagsCompanion Function({
      Value<int> id,
      required int womanId,
      required int tagId,
    });
typedef $$WomanTagsTableUpdateCompanionBuilder =
    WomanTagsCompanion Function({
      Value<int> id,
      Value<int> womanId,
      Value<int> tagId,
    });

final class $$WomanTagsTableReferences
    extends BaseReferences<_$AppDatabase, $WomanTagsTable, WomanTag> {
  $$WomanTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.womanTags.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.womanTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WomanTagsTableFilterComposer
    extends Composer<_$AppDatabase, $WomanTagsTable> {
  $$WomanTagsTableFilterComposer({
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

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WomanTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $WomanTagsTable> {
  $$WomanTagsTableOrderingComposer({
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

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WomanTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WomanTagsTable> {
  $$WomanTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WomanTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WomanTagsTable,
          WomanTag,
          $$WomanTagsTableFilterComposer,
          $$WomanTagsTableOrderingComposer,
          $$WomanTagsTableAnnotationComposer,
          $$WomanTagsTableCreateCompanionBuilder,
          $$WomanTagsTableUpdateCompanionBuilder,
          (WomanTag, $$WomanTagsTableReferences),
          WomanTag,
          PrefetchHooks Function({bool womanId, bool tagId})
        > {
  $$WomanTagsTableTableManager(_$AppDatabase db, $WomanTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WomanTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WomanTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WomanTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
              }) => WomanTagsCompanion(id: id, womanId: womanId, tagId: tagId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int womanId,
                required int tagId,
              }) => WomanTagsCompanion.insert(
                id: id,
                womanId: womanId,
                tagId: tagId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WomanTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({womanId = false, tagId = false}) {
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
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$WomanTagsTableReferences
                                    ._womanIdTable(db),
                                referencedColumn: $$WomanTagsTableReferences
                                    ._womanIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$WomanTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$WomanTagsTableReferences
                                    ._tagIdTable(db)
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

typedef $$WomanTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WomanTagsTable,
      WomanTag,
      $$WomanTagsTableFilterComposer,
      $$WomanTagsTableOrderingComposer,
      $$WomanTagsTableAnnotationComposer,
      $$WomanTagsTableCreateCompanionBuilder,
      $$WomanTagsTableUpdateCompanionBuilder,
      (WomanTag, $$WomanTagsTableReferences),
      WomanTag,
      PrefetchHooks Function({bool womanId, bool tagId})
    >;
typedef $$PeriodLogsTableCreateCompanionBuilder =
    PeriodLogsCompanion Function({
      Value<int> id,
      required int womanId,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<int?> flowLevel,
      Value<String> notes,
    });
typedef $$PeriodLogsTableUpdateCompanionBuilder =
    PeriodLogsCompanion Function({
      Value<int> id,
      Value<int> womanId,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<int?> flowLevel,
      Value<String> notes,
    });

final class $$PeriodLogsTableReferences
    extends BaseReferences<_$AppDatabase, $PeriodLogsTable, PeriodLog> {
  $$PeriodLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.periodLogs.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PeriodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get flowLevel =>
      $composableBuilder(column: $table.flowLevel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodLogsTable,
          PeriodLog,
          $$PeriodLogsTableFilterComposer,
          $$PeriodLogsTableOrderingComposer,
          $$PeriodLogsTableAnnotationComposer,
          $$PeriodLogsTableCreateCompanionBuilder,
          $$PeriodLogsTableUpdateCompanionBuilder,
          (PeriodLog, $$PeriodLogsTableReferences),
          PeriodLog,
          PrefetchHooks Function({bool womanId})
        > {
  $$PeriodLogsTableTableManager(_$AppDatabase db, $PeriodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> flowLevel = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => PeriodLogsCompanion(
                id: id,
                womanId: womanId,
                startDate: startDate,
                endDate: endDate,
                flowLevel: flowLevel,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int womanId,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> flowLevel = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => PeriodLogsCompanion.insert(
                id: id,
                womanId: womanId,
                startDate: startDate,
                endDate: endDate,
                flowLevel: flowLevel,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PeriodLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({womanId = false}) {
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
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$PeriodLogsTableReferences
                                    ._womanIdTable(db),
                                referencedColumn: $$PeriodLogsTableReferences
                                    ._womanIdTable(db)
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

typedef $$PeriodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodLogsTable,
      PeriodLog,
      $$PeriodLogsTableFilterComposer,
      $$PeriodLogsTableOrderingComposer,
      $$PeriodLogsTableAnnotationComposer,
      $$PeriodLogsTableCreateCompanionBuilder,
      $$PeriodLogsTableUpdateCompanionBuilder,
      (PeriodLog, $$PeriodLogsTableReferences),
      PeriodLog,
      PrefetchHooks Function({bool womanId})
    >;
typedef $$OvulationLogsTableCreateCompanionBuilder =
    OvulationLogsCompanion Function({
      Value<int> id,
      required int womanId,
      required DateTime date,
      Value<double?> temperature,
      Value<String?> cervicalMucus,
      Value<bool?> lhTest,
    });
typedef $$OvulationLogsTableUpdateCompanionBuilder =
    OvulationLogsCompanion Function({
      Value<int> id,
      Value<int> womanId,
      Value<DateTime> date,
      Value<double?> temperature,
      Value<String?> cervicalMucus,
      Value<bool?> lhTest,
    });

final class $$OvulationLogsTableReferences
    extends BaseReferences<_$AppDatabase, $OvulationLogsTable, OvulationLog> {
  $$OvulationLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.ovulationLogs.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OvulationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $OvulationLogsTable> {
  $$OvulationLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lhTest => $composableBuilder(
    column: $table.lhTest,
    builder: (column) => ColumnFilters(column),
  );

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OvulationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $OvulationLogsTable> {
  $$OvulationLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lhTest => $composableBuilder(
    column: $table.lhTest,
    builder: (column) => ColumnOrderings(column),
  );

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OvulationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OvulationLogsTable> {
  $$OvulationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lhTest =>
      $composableBuilder(column: $table.lhTest, builder: (column) => column);

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OvulationLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OvulationLogsTable,
          OvulationLog,
          $$OvulationLogsTableFilterComposer,
          $$OvulationLogsTableOrderingComposer,
          $$OvulationLogsTableAnnotationComposer,
          $$OvulationLogsTableCreateCompanionBuilder,
          $$OvulationLogsTableUpdateCompanionBuilder,
          (OvulationLog, $$OvulationLogsTableReferences),
          OvulationLog,
          PrefetchHooks Function({bool womanId})
        > {
  $$OvulationLogsTableTableManager(_$AppDatabase db, $OvulationLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OvulationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OvulationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OvulationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<String?> cervicalMucus = const Value.absent(),
                Value<bool?> lhTest = const Value.absent(),
              }) => OvulationLogsCompanion(
                id: id,
                womanId: womanId,
                date: date,
                temperature: temperature,
                cervicalMucus: cervicalMucus,
                lhTest: lhTest,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int womanId,
                required DateTime date,
                Value<double?> temperature = const Value.absent(),
                Value<String?> cervicalMucus = const Value.absent(),
                Value<bool?> lhTest = const Value.absent(),
              }) => OvulationLogsCompanion.insert(
                id: id,
                womanId: womanId,
                date: date,
                temperature: temperature,
                cervicalMucus: cervicalMucus,
                lhTest: lhTest,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OvulationLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({womanId = false}) {
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
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$OvulationLogsTableReferences
                                    ._womanIdTable(db),
                                referencedColumn: $$OvulationLogsTableReferences
                                    ._womanIdTable(db)
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

typedef $$OvulationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OvulationLogsTable,
      OvulationLog,
      $$OvulationLogsTableFilterComposer,
      $$OvulationLogsTableOrderingComposer,
      $$OvulationLogsTableAnnotationComposer,
      $$OvulationLogsTableCreateCompanionBuilder,
      $$OvulationLogsTableUpdateCompanionBuilder,
      (OvulationLog, $$OvulationLogsTableReferences),
      OvulationLog,
      PrefetchHooks Function({bool womanId})
    >;
typedef $$SymptomsTableCreateCompanionBuilder =
    SymptomsCompanion Function({
      Value<int> id,
      required int womanId,
      required DateTime date,
      required String type,
      Value<int> severity,
      Value<String> notes,
    });
typedef $$SymptomsTableUpdateCompanionBuilder =
    SymptomsCompanion Function({
      Value<int> id,
      Value<int> womanId,
      Value<DateTime> date,
      Value<String> type,
      Value<int> severity,
      Value<String> notes,
    });

final class $$SymptomsTableReferences
    extends BaseReferences<_$AppDatabase, $SymptomsTable, SymptomLog> {
  $$SymptomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.symptoms.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomsTable,
          SymptomLog,
          $$SymptomsTableFilterComposer,
          $$SymptomsTableOrderingComposer,
          $$SymptomsTableAnnotationComposer,
          $$SymptomsTableCreateCompanionBuilder,
          $$SymptomsTableUpdateCompanionBuilder,
          (SymptomLog, $$SymptomsTableReferences),
          SymptomLog,
          PrefetchHooks Function({bool womanId})
        > {
  $$SymptomsTableTableManager(_$AppDatabase db, $SymptomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SymptomsCompanion(
                id: id,
                womanId: womanId,
                date: date,
                type: type,
                severity: severity,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int womanId,
                required DateTime date,
                required String type,
                Value<int> severity = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SymptomsCompanion.insert(
                id: id,
                womanId: womanId,
                date: date,
                type: type,
                severity: severity,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SymptomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({womanId = false}) {
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
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$SymptomsTableReferences
                                    ._womanIdTable(db),
                                referencedColumn: $$SymptomsTableReferences
                                    ._womanIdTable(db)
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

typedef $$SymptomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomsTable,
      SymptomLog,
      $$SymptomsTableFilterComposer,
      $$SymptomsTableOrderingComposer,
      $$SymptomsTableAnnotationComposer,
      $$SymptomsTableCreateCompanionBuilder,
      $$SymptomsTableUpdateCompanionBuilder,
      (SymptomLog, $$SymptomsTableReferences),
      SymptomLog,
      PrefetchHooks Function({bool womanId})
    >;
typedef $$EncountersTableCreateCompanionBuilder =
    EncountersCompanion Function({
      Value<int> id,
      required DateTime encounterTime,
      required String protection,
      Value<String?> outcome,
      Value<String> notes,
    });
typedef $$EncountersTableUpdateCompanionBuilder =
    EncountersCompanion Function({
      Value<int> id,
      Value<DateTime> encounterTime,
      Value<String> protection,
      Value<String?> outcome,
      Value<String> notes,
    });

final class $$EncountersTableReferences
    extends BaseReferences<_$AppDatabase, $EncountersTable, Encounter> {
  $$EncountersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EncounterWomenTable, List<EncounterWoman>>
  _encounterWomenRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.encounterWomen,
    aliasName: $_aliasNameGenerator(
      db.encounters.id,
      db.encounterWomen.encounterId,
    ),
  );

  $$EncounterWomenTableProcessedTableManager get encounterWomenRefs {
    final manager = $$EncounterWomenTableTableManager(
      $_db,
      $_db.encounterWomen,
    ).filter((f) => f.encounterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_encounterWomenRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EncountersTableFilterComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableFilterComposer({
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

  ColumnFilters<DateTime> get encounterTime => $composableBuilder(
    column: $table.encounterTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> encounterWomenRefs(
    Expression<bool> Function($$EncounterWomenTableFilterComposer f) f,
  ) {
    final $$EncounterWomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterWomen,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterWomenTableFilterComposer(
            $db: $db,
            $table: $db.encounterWomen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableOrderingComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get encounterTime => $composableBuilder(
    column: $table.encounterTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get encounterTime => $composableBuilder(
    column: $table.encounterTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protection => $composableBuilder(
    column: $table.protection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> encounterWomenRefs<T extends Object>(
    Expression<T> Function($$EncounterWomenTableAnnotationComposer a) f,
  ) {
    final $$EncounterWomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.encounterWomen,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncounterWomenTableAnnotationComposer(
            $db: $db,
            $table: $db.encounterWomen,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EncountersTable,
          Encounter,
          $$EncountersTableFilterComposer,
          $$EncountersTableOrderingComposer,
          $$EncountersTableAnnotationComposer,
          $$EncountersTableCreateCompanionBuilder,
          $$EncountersTableUpdateCompanionBuilder,
          (Encounter, $$EncountersTableReferences),
          Encounter,
          PrefetchHooks Function({bool encounterWomenRefs})
        > {
  $$EncountersTableTableManager(_$AppDatabase db, $EncountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> encounterTime = const Value.absent(),
                Value<String> protection = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => EncountersCompanion(
                id: id,
                encounterTime: encounterTime,
                protection: protection,
                outcome: outcome,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime encounterTime,
                required String protection,
                Value<String?> outcome = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => EncountersCompanion.insert(
                id: id,
                encounterTime: encounterTime,
                protection: protection,
                outcome: outcome,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EncountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({encounterWomenRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (encounterWomenRefs) db.encounterWomen,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (encounterWomenRefs)
                    await $_getPrefetchedData<
                      Encounter,
                      $EncountersTable,
                      EncounterWoman
                    >(
                      currentTable: table,
                      referencedTable: $$EncountersTableReferences
                          ._encounterWomenRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EncountersTableReferences(
                            db,
                            table,
                            p0,
                          ).encounterWomenRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.encounterId == item.id,
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

typedef $$EncountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EncountersTable,
      Encounter,
      $$EncountersTableFilterComposer,
      $$EncountersTableOrderingComposer,
      $$EncountersTableAnnotationComposer,
      $$EncountersTableCreateCompanionBuilder,
      $$EncountersTableUpdateCompanionBuilder,
      (Encounter, $$EncountersTableReferences),
      Encounter,
      PrefetchHooks Function({bool encounterWomenRefs})
    >;
typedef $$EncounterWomenTableCreateCompanionBuilder =
    EncounterWomenCompanion Function({
      Value<int> id,
      required int encounterId,
      required int womanId,
      Value<String> relationshipType,
    });
typedef $$EncounterWomenTableUpdateCompanionBuilder =
    EncounterWomenCompanion Function({
      Value<int> id,
      Value<int> encounterId,
      Value<int> womanId,
      Value<String> relationshipType,
    });

final class $$EncounterWomenTableReferences
    extends
        BaseReferences<_$AppDatabase, $EncounterWomenTable, EncounterWoman> {
  $$EncounterWomenTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EncountersTable _encounterIdTable(_$AppDatabase db) =>
      db.encounters.createAlias(
        $_aliasNameGenerator(db.encounterWomen.encounterId, db.encounters.id),
      );

  $$EncountersTableProcessedTableManager get encounterId {
    final $_column = $_itemColumn<int>('encounter_id')!;

    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encounterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.encounterWomen.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EncounterWomenTableFilterComposer
    extends Composer<_$AppDatabase, $EncounterWomenTable> {
  $$EncounterWomenTableFilterComposer({
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

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  $$EncountersTableFilterComposer get encounterId {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterWomenTableOrderingComposer
    extends Composer<_$AppDatabase, $EncounterWomenTable> {
  $$EncounterWomenTableOrderingComposer({
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

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  $$EncountersTableOrderingComposer get encounterId {
    final $$EncountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableOrderingComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterWomenTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncounterWomenTable> {
  $$EncounterWomenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  $$EncountersTableAnnotationComposer get encounterId {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EncounterWomenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EncounterWomenTable,
          EncounterWoman,
          $$EncounterWomenTableFilterComposer,
          $$EncounterWomenTableOrderingComposer,
          $$EncounterWomenTableAnnotationComposer,
          $$EncounterWomenTableCreateCompanionBuilder,
          $$EncounterWomenTableUpdateCompanionBuilder,
          (EncounterWoman, $$EncounterWomenTableReferences),
          EncounterWoman,
          PrefetchHooks Function({bool encounterId, bool womanId})
        > {
  $$EncounterWomenTableTableManager(
    _$AppDatabase db,
    $EncounterWomenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncounterWomenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncounterWomenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncounterWomenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> encounterId = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
              }) => EncounterWomenCompanion(
                id: id,
                encounterId: encounterId,
                womanId: womanId,
                relationshipType: relationshipType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int encounterId,
                required int womanId,
                Value<String> relationshipType = const Value.absent(),
              }) => EncounterWomenCompanion.insert(
                id: id,
                encounterId: encounterId,
                womanId: womanId,
                relationshipType: relationshipType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EncounterWomenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({encounterId = false, womanId = false}) {
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
                    if (encounterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.encounterId,
                                referencedTable: $$EncounterWomenTableReferences
                                    ._encounterIdTable(db),
                                referencedColumn:
                                    $$EncounterWomenTableReferences
                                        ._encounterIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$EncounterWomenTableReferences
                                    ._womanIdTable(db),
                                referencedColumn:
                                    $$EncounterWomenTableReferences
                                        ._womanIdTable(db)
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

typedef $$EncounterWomenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EncounterWomenTable,
      EncounterWoman,
      $$EncounterWomenTableFilterComposer,
      $$EncounterWomenTableOrderingComposer,
      $$EncounterWomenTableAnnotationComposer,
      $$EncounterWomenTableCreateCompanionBuilder,
      $$EncounterWomenTableUpdateCompanionBuilder,
      (EncounterWoman, $$EncounterWomenTableReferences),
      EncounterWoman,
      PrefetchHooks Function({bool encounterId, bool womanId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int womanId,
      required int cycleDayStart,
      required int cycleDayEnd,
      required String message,
      Value<bool> enabled,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> womanId,
      Value<int> cycleDayStart,
      Value<int> cycleDayEnd,
      Value<String> message,
      Value<bool> enabled,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WomenTable _womanIdTable(_$AppDatabase db) => db.women.createAlias(
    $_aliasNameGenerator(db.reminders.womanId, db.women.id),
  );

  $$WomenTableProcessedTableManager get womanId {
    final $_column = $_itemColumn<int>('woman_id')!;

    final manager = $$WomenTableTableManager(
      $_db,
      $_db.women,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_womanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<int> get cycleDayStart => $composableBuilder(
    column: $table.cycleDayStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleDayEnd => $composableBuilder(
    column: $table.cycleDayEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$WomenTableFilterComposer get womanId {
    final $$WomenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableFilterComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<int> get cycleDayStart => $composableBuilder(
    column: $table.cycleDayStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleDayEnd => $composableBuilder(
    column: $table.cycleDayEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$WomenTableOrderingComposer get womanId {
    final $$WomenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableOrderingComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleDayStart => $composableBuilder(
    column: $table.cycleDayStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cycleDayEnd => $composableBuilder(
    column: $table.cycleDayEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$WomenTableAnnotationComposer get womanId {
    final $$WomenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.womanId,
      referencedTable: $db.women,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WomenTableAnnotationComposer(
            $db: $db,
            $table: $db.women,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool womanId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> womanId = const Value.absent(),
                Value<int> cycleDayStart = const Value.absent(),
                Value<int> cycleDayEnd = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                womanId: womanId,
                cycleDayStart: cycleDayStart,
                cycleDayEnd: cycleDayEnd,
                message: message,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int womanId,
                required int cycleDayStart,
                required int cycleDayEnd,
                required String message,
                Value<bool> enabled = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                womanId: womanId,
                cycleDayStart: cycleDayStart,
                cycleDayEnd: cycleDayEnd,
                message: message,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({womanId = false}) {
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
                    if (womanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.womanId,
                                referencedTable: $$RemindersTableReferences
                                    ._womanIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._womanIdTable(db)
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

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool womanId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WomenTableTableManager get women =>
      $$WomenTableTableManager(_db, _db.women);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$WomanTagsTableTableManager get womanTags =>
      $$WomanTagsTableTableManager(_db, _db.womanTags);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db, _db.periodLogs);
  $$OvulationLogsTableTableManager get ovulationLogs =>
      $$OvulationLogsTableTableManager(_db, _db.ovulationLogs);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db, _db.symptoms);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$EncounterWomenTableTableManager get encounterWomen =>
      $$EncounterWomenTableTableManager(_db, _db.encounterWomen);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
