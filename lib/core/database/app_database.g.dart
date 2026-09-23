// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, Currency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBaseMeta = const VerificationMeta('isBase');
  @override
  late final GeneratedColumn<bool> isBase = GeneratedColumn<bool>(
    'is_base',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_base" IN (0, 1))',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    symbol,
    isBase,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Currency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('is_base')) {
      context.handle(
        _isBaseMeta,
        isBase.isAcceptableOrUnknown(data['is_base']!, _isBaseMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Currency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Currency(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      isBase: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_base'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class Currency extends DataClass implements Insertable<Currency> {
  final String code;
  final String name;
  final String symbol;
  final bool isBase;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.isBase,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['is_base'] = Variable<bool>(isBase);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      name: Value(name),
      symbol: Value(symbol),
      isBase: Value(isBase),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Currency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Currency(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      isBase: serializer.fromJson<bool>(json['isBase']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'isBase': serializer.toJson<bool>(isBase),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    bool? isBase,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Currency(
    code: code ?? this.code,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    isBase: isBase ?? this.isBase,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Currency copyWithCompanion(CurrenciesCompanion data) {
    return Currency(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      isBase: data.isBase.present ? data.isBase.value : this.isBase,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Currency(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isBase: $isBase, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, symbol, isBase, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          other.code == this.code &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.isBase == this.isBase &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CurrenciesCompanion extends UpdateCompanion<Currency> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> symbol;
  final Value<bool> isBase;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.isBase = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required String name,
    required String symbol,
    this.isBase = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       symbol = Value(symbol),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Currency> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<bool>? isBase,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (isBase != null) 'is_base': isBase,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? symbol,
    Value<bool>? isBase,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isBase: isBase ?? this.isBase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (isBase.present) {
      map['is_base'] = Variable<bool>(isBase.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isBase: $isBase, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTable extends FxRates with TableInfo<$FxRatesTable, FxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCurrencyMeta = const VerificationMeta(
    'targetCurrency',
  );
  @override
  late final GeneratedColumn<String> targetCurrency = GeneratedColumn<String>(
    'target_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>(
        'effective_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseCurrency,
    targetCurrency,
    rate,
    effectiveDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('target_currency')) {
      context.handle(
        _targetCurrencyMeta,
        targetCurrency.isAcceptableOrUnknown(
          data['target_currency']!,
          _targetCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FxRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      targetCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_currency'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $FxRatesTable createAlias(String alias) {
    return $FxRatesTable(attachedDatabase, alias);
  }
}

class FxRate extends DataClass implements Insertable<FxRate> {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final String rate;
  final DateTime effectiveDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const FxRate({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.effectiveDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['target_currency'] = Variable<String>(targetCurrency);
    map['rate'] = Variable<String>(rate);
    map['effective_date'] = Variable<DateTime>(effectiveDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FxRatesCompanion toCompanion(bool nullToAbsent) {
    return FxRatesCompanion(
      id: Value(id),
      baseCurrency: Value(baseCurrency),
      targetCurrency: Value(targetCurrency),
      rate: Value(rate),
      effectiveDate: Value(effectiveDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory FxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FxRate(
      id: serializer.fromJson<String>(json['id']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      targetCurrency: serializer.fromJson<String>(json['targetCurrency']),
      rate: serializer.fromJson<String>(json['rate']),
      effectiveDate: serializer.fromJson<DateTime>(json['effectiveDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'targetCurrency': serializer.toJson<String>(targetCurrency),
      'rate': serializer.toJson<String>(rate),
      'effectiveDate': serializer.toJson<DateTime>(effectiveDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  FxRate copyWith({
    String? id,
    String? baseCurrency,
    String? targetCurrency,
    String? rate,
    DateTime? effectiveDate,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => FxRate(
    id: id ?? this.id,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    targetCurrency: targetCurrency ?? this.targetCurrency,
    rate: rate ?? this.rate,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  FxRate copyWithCompanion(FxRatesCompanion data) {
    return FxRate(
      id: data.id.present ? data.id.value : this.id,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      targetCurrency: data.targetCurrency.present
          ? data.targetCurrency.value
          : this.targetCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FxRate(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('targetCurrency: $targetCurrency, ')
          ..write('rate: $rate, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baseCurrency,
    targetCurrency,
    rate,
    effectiveDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FxRate &&
          other.id == this.id &&
          other.baseCurrency == this.baseCurrency &&
          other.targetCurrency == this.targetCurrency &&
          other.rate == this.rate &&
          other.effectiveDate == this.effectiveDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FxRatesCompanion extends UpdateCompanion<FxRate> {
  final Value<String> id;
  final Value<String> baseCurrency;
  final Value<String> targetCurrency;
  final Value<String> rate;
  final Value<DateTime> effectiveDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FxRatesCompanion({
    this.id = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.targetCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FxRatesCompanion.insert({
    required String id,
    required String baseCurrency,
    required String targetCurrency,
    required String rate,
    required DateTime effectiveDate,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baseCurrency = Value(baseCurrency),
       targetCurrency = Value(targetCurrency),
       rate = Value(rate),
       effectiveDate = Value(effectiveDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FxRate> custom({
    Expression<String>? id,
    Expression<String>? baseCurrency,
    Expression<String>? targetCurrency,
    Expression<String>? rate,
    Expression<DateTime>? effectiveDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (targetCurrency != null) 'target_currency': targetCurrency,
      if (rate != null) 'rate': rate,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FxRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? baseCurrency,
    Value<String>? targetCurrency,
    Value<String>? rate,
    Value<DateTime>? effectiveDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return FxRatesCompanion(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (targetCurrency.present) {
      map['target_currency'] = Variable<String>(targetCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesCompanion(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('targetCurrency: $targetCurrency, ')
          ..write('rate: $rate, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _accountTypeMeta = const VerificationMeta(
    'accountType',
  );
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDomesticMeta = const VerificationMeta(
    'isDomestic',
  );
  @override
  late final GeneratedColumn<bool> isDomestic = GeneratedColumn<bool>(
    'is_domestic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_domestic" IN (0, 1))',
    ),
  );
  static const VerificationMeta _closingDayMeta = const VerificationMeta(
    'closingDay',
  );
  @override
  late final GeneratedColumn<int> closingDay = GeneratedColumn<int>(
    'closing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitSatangMeta = const VerificationMeta(
    'creditLimitSatang',
  );
  @override
  late final GeneratedColumn<int> creditLimitSatang = GeneratedColumn<int>(
    'credit_limit_satang',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    accountType,
    currencyCode,
    isDomestic,
    closingDay,
    dueDay,
    creditLimitSatang,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
        _accountTypeMeta,
        accountType.isAcceptableOrUnknown(
          data['account_type']!,
          _accountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('is_domestic')) {
      context.handle(
        _isDomesticMeta,
        isDomestic.isAcceptableOrUnknown(data['is_domestic']!, _isDomesticMeta),
      );
    } else if (isInserting) {
      context.missing(_isDomesticMeta);
    }
    if (data.containsKey('closing_day')) {
      context.handle(
        _closingDayMeta,
        closingDay.isAcceptableOrUnknown(data['closing_day']!, _closingDayMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('credit_limit_satang')) {
      context.handle(
        _creditLimitSatangMeta,
        creditLimitSatang.isAcceptableOrUnknown(
          data['credit_limit_satang']!,
          _creditLimitSatangMeta,
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_type'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      isDomestic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_domestic'],
      )!,
      closingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day'],
      ),
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      ),
      creditLimitSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_satang'],
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String accountType;
  final String currencyCode;
  final bool isDomestic;
  final int? closingDay;
  final int? dueDay;
  final int? creditLimitSatang;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.currencyCode,
    required this.isDomestic,
    this.closingDay,
    this.dueDay,
    this.creditLimitSatang,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['account_type'] = Variable<String>(accountType);
    map['currency_code'] = Variable<String>(currencyCode);
    map['is_domestic'] = Variable<bool>(isDomestic);
    if (!nullToAbsent || closingDay != null) {
      map['closing_day'] = Variable<int>(closingDay);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    if (!nullToAbsent || creditLimitSatang != null) {
      map['credit_limit_satang'] = Variable<int>(creditLimitSatang);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      accountType: Value(accountType),
      currencyCode: Value(currencyCode),
      isDomestic: Value(isDomestic),
      closingDay: closingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(closingDay),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
      creditLimitSatang: creditLimitSatang == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitSatang),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountType: serializer.fromJson<String>(json['accountType']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      isDomestic: serializer.fromJson<bool>(json['isDomestic']),
      closingDay: serializer.fromJson<int?>(json['closingDay']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      creditLimitSatang: serializer.fromJson<int?>(json['creditLimitSatang']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accountType': serializer.toJson<String>(accountType),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'isDomestic': serializer.toJson<bool>(isDomestic),
      'closingDay': serializer.toJson<int?>(closingDay),
      'dueDay': serializer.toJson<int?>(dueDay),
      'creditLimitSatang': serializer.toJson<int?>(creditLimitSatang),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? accountType,
    String? currencyCode,
    bool? isDomestic,
    Value<int?> closingDay = const Value.absent(),
    Value<int?> dueDay = const Value.absent(),
    Value<int?> creditLimitSatang = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    currencyCode: currencyCode ?? this.currencyCode,
    isDomestic: isDomestic ?? this.isDomestic,
    closingDay: closingDay.present ? closingDay.value : this.closingDay,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    creditLimitSatang: creditLimitSatang.present
        ? creditLimitSatang.value
        : this.creditLimitSatang,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      isDomestic: data.isDomestic.present
          ? data.isDomestic.value
          : this.isDomestic,
      closingDay: data.closingDay.present
          ? data.closingDay.value
          : this.closingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      creditLimitSatang: data.creditLimitSatang.present
          ? data.creditLimitSatang.value
          : this.creditLimitSatang,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isDomestic: $isDomestic, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('creditLimitSatang: $creditLimitSatang, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    accountType,
    currencyCode,
    isDomestic,
    closingDay,
    dueDay,
    creditLimitSatang,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.currencyCode == this.currencyCode &&
          other.isDomestic == this.isDomestic &&
          other.closingDay == this.closingDay &&
          other.dueDay == this.dueDay &&
          other.creditLimitSatang == this.creditLimitSatang &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> accountType;
  final Value<String> currencyCode;
  final Value<bool> isDomestic;
  final Value<int?> closingDay;
  final Value<int?> dueDay;
  final Value<int?> creditLimitSatang;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.isDomestic = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.creditLimitSatang = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String accountType,
    required String currencyCode,
    required bool isDomestic,
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.creditLimitSatang = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       accountType = Value(accountType),
       currencyCode = Value(currencyCode),
       isDomestic = Value(isDomestic),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? accountType,
    Expression<String>? currencyCode,
    Expression<bool>? isDomestic,
    Expression<int>? closingDay,
    Expression<int>? dueDay,
    Expression<int>? creditLimitSatang,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (isDomestic != null) 'is_domestic': isDomestic,
      if (closingDay != null) 'closing_day': closingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (creditLimitSatang != null) 'credit_limit_satang': creditLimitSatang,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? accountType,
    Value<String>? currencyCode,
    Value<bool>? isDomestic,
    Value<int?>? closingDay,
    Value<int?>? dueDay,
    Value<int?>? creditLimitSatang,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currencyCode: currencyCode ?? this.currencyCode,
      isDomestic: isDomestic ?? this.isDomestic,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      creditLimitSatang: creditLimitSatang ?? this.creditLimitSatang,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (isDomestic.present) {
      map['is_domestic'] = Variable<bool>(isDomestic.value);
    }
    if (closingDay.present) {
      map['closing_day'] = Variable<int>(closingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (creditLimitSatang.present) {
      map['credit_limit_satang'] = Variable<int>(creditLimitSatang.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isDomestic: $isDomestic, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('creditLimitSatang: $creditLimitSatang, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameThMeta = const VerificationMeta('nameTh');
  @override
  late final GeneratedColumn<String> nameTh = GeneratedColumn<String>(
    'name_th',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryTypeMeta = const VerificationMeta(
    'categoryType',
  );
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxIncomeTypeMeta = const VerificationMeta(
    'taxIncomeType',
  );
  @override
  late final GeneratedColumn<String> taxIncomeType = GeneratedColumn<String>(
    'tax_income_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameTh,
    nameEn,
    categoryType,
    parentId,
    taxIncomeType,
    icon,
    color,
    isSystem,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_th')) {
      context.handle(
        _nameThMeta,
        nameTh.isAcceptableOrUnknown(data['name_th']!, _nameThMeta),
      );
    } else if (isInserting) {
      context.missing(_nameThMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('category_type')) {
      context.handle(
        _categoryTypeMeta,
        categoryType.isAcceptableOrUnknown(
          data['category_type']!,
          _categoryTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryTypeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('tax_income_type')) {
      context.handle(
        _taxIncomeTypeMeta,
        taxIncomeType.isAcceptableOrUnknown(
          data['tax_income_type']!,
          _taxIncomeTypeMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameTh: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_th'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      categoryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      taxIncomeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_income_type'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String nameTh;
  final String nameEn;
  final String categoryType;
  final String? parentId;
  final String? taxIncomeType;
  final String? icon;
  final String? color;
  final bool isSystem;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const Category({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.categoryType,
    this.parentId,
    this.taxIncomeType,
    this.icon,
    this.color,
    required this.isSystem,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_th'] = Variable<String>(nameTh);
    map['name_en'] = Variable<String>(nameEn);
    map['category_type'] = Variable<String>(categoryType);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || taxIncomeType != null) {
      map['tax_income_type'] = Variable<String>(taxIncomeType);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      nameTh: Value(nameTh),
      nameEn: Value(nameEn),
      categoryType: Value(categoryType),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      taxIncomeType: taxIncomeType == null && nullToAbsent
          ? const Value.absent()
          : Value(taxIncomeType),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      nameTh: serializer.fromJson<String>(json['nameTh']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      taxIncomeType: serializer.fromJson<String?>(json['taxIncomeType']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameTh': serializer.toJson<String>(nameTh),
      'nameEn': serializer.toJson<String>(nameEn),
      'categoryType': serializer.toJson<String>(categoryType),
      'parentId': serializer.toJson<String?>(parentId),
      'taxIncomeType': serializer.toJson<String?>(taxIncomeType),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  Category copyWith({
    String? id,
    String? nameTh,
    String? nameEn,
    String? categoryType,
    Value<String?> parentId = const Value.absent(),
    Value<String?> taxIncomeType = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isSystem,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => Category(
    id: id ?? this.id,
    nameTh: nameTh ?? this.nameTh,
    nameEn: nameEn ?? this.nameEn,
    categoryType: categoryType ?? this.categoryType,
    parentId: parentId.present ? parentId.value : this.parentId,
    taxIncomeType: taxIncomeType.present
        ? taxIncomeType.value
        : this.taxIncomeType,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      nameTh: data.nameTh.present ? data.nameTh.value : this.nameTh,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      taxIncomeType: data.taxIncomeType.present
          ? data.taxIncomeType.value
          : this.taxIncomeType,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('nameTh: $nameTh, ')
          ..write('nameEn: $nameEn, ')
          ..write('categoryType: $categoryType, ')
          ..write('parentId: $parentId, ')
          ..write('taxIncomeType: $taxIncomeType, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameTh,
    nameEn,
    categoryType,
    parentId,
    taxIncomeType,
    icon,
    color,
    isSystem,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.nameTh == this.nameTh &&
          other.nameEn == this.nameEn &&
          other.categoryType == this.categoryType &&
          other.parentId == this.parentId &&
          other.taxIncomeType == this.taxIncomeType &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> nameTh;
  final Value<String> nameEn;
  final Value<String> categoryType;
  final Value<String?> parentId;
  final Value<String?> taxIncomeType;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.nameTh = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.parentId = const Value.absent(),
    this.taxIncomeType = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String nameTh,
    required String nameEn,
    required String categoryType,
    this.parentId = const Value.absent(),
    this.taxIncomeType = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameTh = Value(nameTh),
       nameEn = Value(nameEn),
       categoryType = Value(categoryType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? nameTh,
    Expression<String>? nameEn,
    Expression<String>? categoryType,
    Expression<String>? parentId,
    Expression<String>? taxIncomeType,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameTh != null) 'name_th': nameTh,
      if (nameEn != null) 'name_en': nameEn,
      if (categoryType != null) 'category_type': categoryType,
      if (parentId != null) 'parent_id': parentId,
      if (taxIncomeType != null) 'tax_income_type': taxIncomeType,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? nameTh,
    Value<String>? nameEn,
    Value<String>? categoryType,
    Value<String?>? parentId,
    Value<String?>? taxIncomeType,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      nameTh: nameTh ?? this.nameTh,
      nameEn: nameEn ?? this.nameEn,
      categoryType: categoryType ?? this.categoryType,
      parentId: parentId ?? this.parentId,
      taxIncomeType: taxIncomeType ?? this.taxIncomeType,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameTh.present) {
      map['name_th'] = Variable<String>(nameTh.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (taxIncomeType.present) {
      map['tax_income_type'] = Variable<String>(taxIncomeType.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('nameTh: $nameTh, ')
          ..write('nameEn: $nameEn, ')
          ..write('categoryType: $categoryType, ')
          ..write('parentId: $parentId, ')
          ..write('taxIncomeType: $taxIncomeType, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultAccountIdMeta = const VerificationMeta(
    'defaultAccountId',
  );
  @override
  late final GeneratedColumn<String> defaultAccountId = GeneratedColumn<String>(
    'default_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraDetailsJsonMeta = const VerificationMeta(
    'extraDetailsJson',
  );
  @override
  late final GeneratedColumn<String> extraDetailsJson = GeneratedColumn<String>(
    'extra_details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    name,
    assetType,
    currencyCode,
    defaultAccountId,
    market,
    note,
    extraDetailsJson,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('default_account_id')) {
      context.handle(
        _defaultAccountIdMeta,
        defaultAccountId.isAcceptableOrUnknown(
          data['default_account_id']!,
          _defaultAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultAccountIdMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('extra_details_json')) {
      context.handle(
        _extraDetailsJsonMeta,
        extraDetailsJson.isAcceptableOrUnknown(
          data['extra_details_json']!,
          _extraDetailsJsonMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      assetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_type'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      defaultAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_account_id'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      extraDetailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_details_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final String id;
  final String symbol;
  final String name;
  final String assetType;
  final String currencyCode;
  final String defaultAccountId;
  final String? market;
  final String? note;
  final String? extraDetailsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.assetType,
    required this.currencyCode,
    required this.defaultAccountId,
    this.market,
    this.note,
    this.extraDetailsJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['asset_type'] = Variable<String>(assetType);
    map['currency_code'] = Variable<String>(currencyCode);
    map['default_account_id'] = Variable<String>(defaultAccountId);
    if (!nullToAbsent || market != null) {
      map['market'] = Variable<String>(market);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || extraDetailsJson != null) {
      map['extra_details_json'] = Variable<String>(extraDetailsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      name: Value(name),
      assetType: Value(assetType),
      currencyCode: Value(currencyCode),
      defaultAccountId: Value(defaultAccountId),
      market: market == null && nullToAbsent
          ? const Value.absent()
          : Value(market),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      extraDetailsJson: extraDetailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extraDetailsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      assetType: serializer.fromJson<String>(json['assetType']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      defaultAccountId: serializer.fromJson<String>(json['defaultAccountId']),
      market: serializer.fromJson<String?>(json['market']),
      note: serializer.fromJson<String?>(json['note']),
      extraDetailsJson: serializer.fromJson<String?>(json['extraDetailsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'assetType': serializer.toJson<String>(assetType),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'defaultAccountId': serializer.toJson<String>(defaultAccountId),
      'market': serializer.toJson<String?>(market),
      'note': serializer.toJson<String?>(note),
      'extraDetailsJson': serializer.toJson<String?>(extraDetailsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Asset copyWith({
    String? id,
    String? symbol,
    String? name,
    String? assetType,
    String? currencyCode,
    String? defaultAccountId,
    Value<String?> market = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> extraDetailsJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Asset(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    assetType: assetType ?? this.assetType,
    currencyCode: currencyCode ?? this.currencyCode,
    defaultAccountId: defaultAccountId ?? this.defaultAccountId,
    market: market.present ? market.value : this.market,
    note: note.present ? note.value : this.note,
    extraDetailsJson: extraDetailsJson.present
        ? extraDetailsJson.value
        : this.extraDetailsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      defaultAccountId: data.defaultAccountId.present
          ? data.defaultAccountId.value
          : this.defaultAccountId,
      market: data.market.present ? data.market.value : this.market,
      note: data.note.present ? data.note.value : this.note,
      extraDetailsJson: data.extraDetailsJson.present
          ? data.extraDetailsJson.value
          : this.extraDetailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('assetType: $assetType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('market: $market, ')
          ..write('note: $note, ')
          ..write('extraDetailsJson: $extraDetailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    name,
    assetType,
    currencyCode,
    defaultAccountId,
    market,
    note,
    extraDetailsJson,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.assetType == this.assetType &&
          other.currencyCode == this.currencyCode &&
          other.defaultAccountId == this.defaultAccountId &&
          other.market == this.market &&
          other.note == this.note &&
          other.extraDetailsJson == this.extraDetailsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> name;
  final Value<String> assetType;
  final Value<String> currencyCode;
  final Value<String> defaultAccountId;
  final Value<String?> market;
  final Value<String?> note;
  final Value<String?> extraDetailsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.assetType = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.market = const Value.absent(),
    this.note = const Value.absent(),
    this.extraDetailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String symbol,
    required String name,
    required String assetType,
    required String currencyCode,
    required String defaultAccountId,
    this.market = const Value.absent(),
    this.note = const Value.absent(),
    this.extraDetailsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       symbol = Value(symbol),
       name = Value(name),
       assetType = Value(assetType),
       currencyCode = Value(currencyCode),
       defaultAccountId = Value(defaultAccountId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Asset> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? assetType,
    Expression<String>? currencyCode,
    Expression<String>? defaultAccountId,
    Expression<String>? market,
    Expression<String>? note,
    Expression<String>? extraDetailsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (assetType != null) 'asset_type': assetType,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (defaultAccountId != null) 'default_account_id': defaultAccountId,
      if (market != null) 'market': market,
      if (note != null) 'note': note,
      if (extraDetailsJson != null) 'extra_details_json': extraDetailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? symbol,
    Value<String>? name,
    Value<String>? assetType,
    Value<String>? currencyCode,
    Value<String>? defaultAccountId,
    Value<String?>? market,
    Value<String?>? note,
    Value<String?>? extraDetailsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      assetType: assetType ?? this.assetType,
      currencyCode: currencyCode ?? this.currencyCode,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      market: market ?? this.market,
      note: note ?? this.note,
      extraDetailsJson: extraDetailsJson ?? this.extraDetailsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (defaultAccountId.present) {
      map['default_account_id'] = Variable<String>(defaultAccountId.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (extraDetailsJson.present) {
      map['extra_details_json'] = Variable<String>(extraDetailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('assetType: $assetType, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('market: $market, ')
          ..write('note: $note, ')
          ..write('extraDetailsJson: $extraDetailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<String> importBatchId = GeneratedColumn<String>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountOriginalSatangMeta =
      const VerificationMeta('amountOriginalSatang');
  @override
  late final GeneratedColumn<int> amountOriginalSatang = GeneratedColumn<int>(
    'amount_original_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<String> fxRate = GeneratedColumn<String>(
    'fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.000000'),
  );
  static const VerificationMeta _amountThbSatangMeta = const VerificationMeta(
    'amountThbSatang',
  );
  @override
  late final GeneratedColumn<int> amountThbSatang = GeneratedColumn<int>(
    'amount_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeThbSatangMeta = const VerificationMeta(
    'feeThbSatang',
  );
  @override
  late final GeneratedColumn<int> feeThbSatang = GeneratedColumn<int>(
    'fee_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxCategoryMeta = const VerificationMeta(
    'taxCategory',
  );
  @override
  late final GeneratedColumn<String> taxCategory = GeneratedColumn<String>(
    'tax_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _withholdingTaxSatangMeta =
      const VerificationMeta('withholdingTaxSatang');
  @override
  late final GeneratedColumn<int> withholdingTaxSatang = GeneratedColumn<int>(
    'withholding_tax_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _workPeriodMeta = const VerificationMeta(
    'workPeriod',
  );
  @override
  late final GeneratedColumn<String> workPeriod = GeneratedColumn<String>(
    'work_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedAmountSatangMeta =
      const VerificationMeta('expectedAmountSatang');
  @override
  late final GeneratedColumn<int> expectedAmountSatang = GeneratedColumn<int>(
    'expected_amount_satang',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isClearedMeta = const VerificationMeta(
    'isCleared',
  );
  @override
  late final GeneratedColumn<bool> isCleared = GeneratedColumn<bool>(
    'is_cleared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cleared" IN (0, 1))',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionType,
    sourceAccountId,
    destinationAccountId,
    categoryId,
    assetId,
    importBatchId,
    amountOriginalSatang,
    currencyCode,
    fxRate,
    amountThbSatang,
    feeThbSatang,
    tag,
    taxCategory,
    withholdingTaxSatang,
    transactionDate,
    workPeriod,
    expectedAmountSatang,
    note,
    isCleared,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_original_satang')) {
      context.handle(
        _amountOriginalSatangMeta,
        amountOriginalSatang.isAcceptableOrUnknown(
          data['amount_original_satang']!,
          _amountOriginalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountOriginalSatangMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    }
    if (data.containsKey('amount_thb_satang')) {
      context.handle(
        _amountThbSatangMeta,
        amountThbSatang.isAcceptableOrUnknown(
          data['amount_thb_satang']!,
          _amountThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountThbSatangMeta);
    }
    if (data.containsKey('fee_thb_satang')) {
      context.handle(
        _feeThbSatangMeta,
        feeThbSatang.isAcceptableOrUnknown(
          data['fee_thb_satang']!,
          _feeThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('tax_category')) {
      context.handle(
        _taxCategoryMeta,
        taxCategory.isAcceptableOrUnknown(
          data['tax_category']!,
          _taxCategoryMeta,
        ),
      );
    }
    if (data.containsKey('withholding_tax_satang')) {
      context.handle(
        _withholdingTaxSatangMeta,
        withholdingTaxSatang.isAcceptableOrUnknown(
          data['withholding_tax_satang']!,
          _withholdingTaxSatangMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('work_period')) {
      context.handle(
        _workPeriodMeta,
        workPeriod.isAcceptableOrUnknown(data['work_period']!, _workPeriodMeta),
      );
    }
    if (data.containsKey('expected_amount_satang')) {
      context.handle(
        _expectedAmountSatangMeta,
        expectedAmountSatang.isAcceptableOrUnknown(
          data['expected_amount_satang']!,
          _expectedAmountSatangMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_cleared')) {
      context.handle(
        _isClearedMeta,
        isCleared.isAcceptableOrUnknown(data['is_cleared']!, _isClearedMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      ),
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      ),
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch_id'],
      ),
      amountOriginalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_original_satang'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fx_rate'],
      )!,
      amountThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_thb_satang'],
      )!,
      feeThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_thb_satang'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      taxCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_category'],
      ),
      withholdingTaxSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}withholding_tax_satang'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      workPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_period'],
      ),
      expectedAmountSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount_satang'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isCleared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cleared'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String transactionType;
  final String? sourceAccountId;
  final String? destinationAccountId;
  final String? categoryId;
  final String? assetId;
  final String? importBatchId;
  final int amountOriginalSatang;
  final String currencyCode;
  final String fxRate;
  final int amountThbSatang;
  final int feeThbSatang;
  final String? tag;
  final String? taxCategory;
  final int withholdingTaxSatang;
  final DateTime transactionDate;
  final String? workPeriod;
  final int? expectedAmountSatang;
  final String? note;
  final bool isCleared;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const Transaction({
    required this.id,
    required this.transactionType,
    this.sourceAccountId,
    this.destinationAccountId,
    this.categoryId,
    this.assetId,
    this.importBatchId,
    required this.amountOriginalSatang,
    required this.currencyCode,
    required this.fxRate,
    required this.amountThbSatang,
    required this.feeThbSatang,
    this.tag,
    this.taxCategory,
    required this.withholdingTaxSatang,
    required this.transactionDate,
    this.workPeriod,
    this.expectedAmountSatang,
    this.note,
    required this.isCleared,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || sourceAccountId != null) {
      map['source_account_id'] = Variable<String>(sourceAccountId);
    }
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || assetId != null) {
      map['asset_id'] = Variable<String>(assetId);
    }
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<String>(importBatchId);
    }
    map['amount_original_satang'] = Variable<int>(amountOriginalSatang);
    map['currency_code'] = Variable<String>(currencyCode);
    map['fx_rate'] = Variable<String>(fxRate);
    map['amount_thb_satang'] = Variable<int>(amountThbSatang);
    map['fee_thb_satang'] = Variable<int>(feeThbSatang);
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    if (!nullToAbsent || taxCategory != null) {
      map['tax_category'] = Variable<String>(taxCategory);
    }
    map['withholding_tax_satang'] = Variable<int>(withholdingTaxSatang);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || workPeriod != null) {
      map['work_period'] = Variable<String>(workPeriod);
    }
    if (!nullToAbsent || expectedAmountSatang != null) {
      map['expected_amount_satang'] = Variable<int>(expectedAmountSatang);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_cleared'] = Variable<bool>(isCleared);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      transactionType: Value(transactionType),
      sourceAccountId: sourceAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAccountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      assetId: assetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetId),
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
      amountOriginalSatang: Value(amountOriginalSatang),
      currencyCode: Value(currencyCode),
      fxRate: Value(fxRate),
      amountThbSatang: Value(amountThbSatang),
      feeThbSatang: Value(feeThbSatang),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      taxCategory: taxCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(taxCategory),
      withholdingTaxSatang: Value(withholdingTaxSatang),
      transactionDate: Value(transactionDate),
      workPeriod: workPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(workPeriod),
      expectedAmountSatang: expectedAmountSatang == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedAmountSatang),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isCleared: Value(isCleared),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      sourceAccountId: serializer.fromJson<String?>(json['sourceAccountId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      assetId: serializer.fromJson<String?>(json['assetId']),
      importBatchId: serializer.fromJson<String?>(json['importBatchId']),
      amountOriginalSatang: serializer.fromJson<int>(
        json['amountOriginalSatang'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      fxRate: serializer.fromJson<String>(json['fxRate']),
      amountThbSatang: serializer.fromJson<int>(json['amountThbSatang']),
      feeThbSatang: serializer.fromJson<int>(json['feeThbSatang']),
      tag: serializer.fromJson<String?>(json['tag']),
      taxCategory: serializer.fromJson<String?>(json['taxCategory']),
      withholdingTaxSatang: serializer.fromJson<int>(
        json['withholdingTaxSatang'],
      ),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      workPeriod: serializer.fromJson<String?>(json['workPeriod']),
      expectedAmountSatang: serializer.fromJson<int?>(
        json['expectedAmountSatang'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      isCleared: serializer.fromJson<bool>(json['isCleared']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionType': serializer.toJson<String>(transactionType),
      'sourceAccountId': serializer.toJson<String?>(sourceAccountId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'assetId': serializer.toJson<String?>(assetId),
      'importBatchId': serializer.toJson<String?>(importBatchId),
      'amountOriginalSatang': serializer.toJson<int>(amountOriginalSatang),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'fxRate': serializer.toJson<String>(fxRate),
      'amountThbSatang': serializer.toJson<int>(amountThbSatang),
      'feeThbSatang': serializer.toJson<int>(feeThbSatang),
      'tag': serializer.toJson<String?>(tag),
      'taxCategory': serializer.toJson<String?>(taxCategory),
      'withholdingTaxSatang': serializer.toJson<int>(withholdingTaxSatang),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'workPeriod': serializer.toJson<String?>(workPeriod),
      'expectedAmountSatang': serializer.toJson<int?>(expectedAmountSatang),
      'note': serializer.toJson<String?>(note),
      'isCleared': serializer.toJson<bool>(isCleared),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  Transaction copyWith({
    String? id,
    String? transactionType,
    Value<String?> sourceAccountId = const Value.absent(),
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> assetId = const Value.absent(),
    Value<String?> importBatchId = const Value.absent(),
    int? amountOriginalSatang,
    String? currencyCode,
    String? fxRate,
    int? amountThbSatang,
    int? feeThbSatang,
    Value<String?> tag = const Value.absent(),
    Value<String?> taxCategory = const Value.absent(),
    int? withholdingTaxSatang,
    DateTime? transactionDate,
    Value<String?> workPeriod = const Value.absent(),
    Value<int?> expectedAmountSatang = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isCleared,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => Transaction(
    id: id ?? this.id,
    transactionType: transactionType ?? this.transactionType,
    sourceAccountId: sourceAccountId.present
        ? sourceAccountId.value
        : this.sourceAccountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    assetId: assetId.present ? assetId.value : this.assetId,
    importBatchId: importBatchId.present
        ? importBatchId.value
        : this.importBatchId,
    amountOriginalSatang: amountOriginalSatang ?? this.amountOriginalSatang,
    currencyCode: currencyCode ?? this.currencyCode,
    fxRate: fxRate ?? this.fxRate,
    amountThbSatang: amountThbSatang ?? this.amountThbSatang,
    feeThbSatang: feeThbSatang ?? this.feeThbSatang,
    tag: tag.present ? tag.value : this.tag,
    taxCategory: taxCategory.present ? taxCategory.value : this.taxCategory,
    withholdingTaxSatang: withholdingTaxSatang ?? this.withholdingTaxSatang,
    transactionDate: transactionDate ?? this.transactionDate,
    workPeriod: workPeriod.present ? workPeriod.value : this.workPeriod,
    expectedAmountSatang: expectedAmountSatang.present
        ? expectedAmountSatang.value
        : this.expectedAmountSatang,
    note: note.present ? note.value : this.note,
    isCleared: isCleared ?? this.isCleared,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
      amountOriginalSatang: data.amountOriginalSatang.present
          ? data.amountOriginalSatang.value
          : this.amountOriginalSatang,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      amountThbSatang: data.amountThbSatang.present
          ? data.amountThbSatang.value
          : this.amountThbSatang,
      feeThbSatang: data.feeThbSatang.present
          ? data.feeThbSatang.value
          : this.feeThbSatang,
      tag: data.tag.present ? data.tag.value : this.tag,
      taxCategory: data.taxCategory.present
          ? data.taxCategory.value
          : this.taxCategory,
      withholdingTaxSatang: data.withholdingTaxSatang.present
          ? data.withholdingTaxSatang.value
          : this.withholdingTaxSatang,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      workPeriod: data.workPeriod.present
          ? data.workPeriod.value
          : this.workPeriod,
      expectedAmountSatang: data.expectedAmountSatang.present
          ? data.expectedAmountSatang.value
          : this.expectedAmountSatang,
      note: data.note.present ? data.note.value : this.note,
      isCleared: data.isCleared.present ? data.isCleared.value : this.isCleared,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('assetId: $assetId, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('amountOriginalSatang: $amountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('amountThbSatang: $amountThbSatang, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('tag: $tag, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('withholdingTaxSatang: $withholdingTaxSatang, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('workPeriod: $workPeriod, ')
          ..write('expectedAmountSatang: $expectedAmountSatang, ')
          ..write('note: $note, ')
          ..write('isCleared: $isCleared, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    transactionType,
    sourceAccountId,
    destinationAccountId,
    categoryId,
    assetId,
    importBatchId,
    amountOriginalSatang,
    currencyCode,
    fxRate,
    amountThbSatang,
    feeThbSatang,
    tag,
    taxCategory,
    withholdingTaxSatang,
    transactionDate,
    workPeriod,
    expectedAmountSatang,
    note,
    isCleared,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.transactionType == this.transactionType &&
          other.sourceAccountId == this.sourceAccountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.categoryId == this.categoryId &&
          other.assetId == this.assetId &&
          other.importBatchId == this.importBatchId &&
          other.amountOriginalSatang == this.amountOriginalSatang &&
          other.currencyCode == this.currencyCode &&
          other.fxRate == this.fxRate &&
          other.amountThbSatang == this.amountThbSatang &&
          other.feeThbSatang == this.feeThbSatang &&
          other.tag == this.tag &&
          other.taxCategory == this.taxCategory &&
          other.withholdingTaxSatang == this.withholdingTaxSatang &&
          other.transactionDate == this.transactionDate &&
          other.workPeriod == this.workPeriod &&
          other.expectedAmountSatang == this.expectedAmountSatang &&
          other.note == this.note &&
          other.isCleared == this.isCleared &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> transactionType;
  final Value<String?> sourceAccountId;
  final Value<String?> destinationAccountId;
  final Value<String?> categoryId;
  final Value<String?> assetId;
  final Value<String?> importBatchId;
  final Value<int> amountOriginalSatang;
  final Value<String> currencyCode;
  final Value<String> fxRate;
  final Value<int> amountThbSatang;
  final Value<int> feeThbSatang;
  final Value<String?> tag;
  final Value<String?> taxCategory;
  final Value<int> withholdingTaxSatang;
  final Value<DateTime> transactionDate;
  final Value<String?> workPeriod;
  final Value<int?> expectedAmountSatang;
  final Value<String?> note;
  final Value<bool> isCleared;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.amountOriginalSatang = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.amountThbSatang = const Value.absent(),
    this.feeThbSatang = const Value.absent(),
    this.tag = const Value.absent(),
    this.taxCategory = const Value.absent(),
    this.withholdingTaxSatang = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.workPeriod = const Value.absent(),
    this.expectedAmountSatang = const Value.absent(),
    this.note = const Value.absent(),
    this.isCleared = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String transactionType,
    this.sourceAccountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.importBatchId = const Value.absent(),
    required int amountOriginalSatang,
    required String currencyCode,
    this.fxRate = const Value.absent(),
    required int amountThbSatang,
    this.feeThbSatang = const Value.absent(),
    this.tag = const Value.absent(),
    this.taxCategory = const Value.absent(),
    this.withholdingTaxSatang = const Value.absent(),
    required DateTime transactionDate,
    this.workPeriod = const Value.absent(),
    this.expectedAmountSatang = const Value.absent(),
    this.note = const Value.absent(),
    this.isCleared = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionType = Value(transactionType),
       amountOriginalSatang = Value(amountOriginalSatang),
       currencyCode = Value(currencyCode),
       amountThbSatang = Value(amountThbSatang),
       transactionDate = Value(transactionDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? transactionType,
    Expression<String>? sourceAccountId,
    Expression<String>? destinationAccountId,
    Expression<String>? categoryId,
    Expression<String>? assetId,
    Expression<String>? importBatchId,
    Expression<int>? amountOriginalSatang,
    Expression<String>? currencyCode,
    Expression<String>? fxRate,
    Expression<int>? amountThbSatang,
    Expression<int>? feeThbSatang,
    Expression<String>? tag,
    Expression<String>? taxCategory,
    Expression<int>? withholdingTaxSatang,
    Expression<DateTime>? transactionDate,
    Expression<String>? workPeriod,
    Expression<int>? expectedAmountSatang,
    Expression<String>? note,
    Expression<bool>? isCleared,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (assetId != null) 'asset_id': assetId,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (amountOriginalSatang != null)
        'amount_original_satang': amountOriginalSatang,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (fxRate != null) 'fx_rate': fxRate,
      if (amountThbSatang != null) 'amount_thb_satang': amountThbSatang,
      if (feeThbSatang != null) 'fee_thb_satang': feeThbSatang,
      if (tag != null) 'tag': tag,
      if (taxCategory != null) 'tax_category': taxCategory,
      if (withholdingTaxSatang != null)
        'withholding_tax_satang': withholdingTaxSatang,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (workPeriod != null) 'work_period': workPeriod,
      if (expectedAmountSatang != null)
        'expected_amount_satang': expectedAmountSatang,
      if (note != null) 'note': note,
      if (isCleared != null) 'is_cleared': isCleared,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionType,
    Value<String?>? sourceAccountId,
    Value<String?>? destinationAccountId,
    Value<String?>? categoryId,
    Value<String?>? assetId,
    Value<String?>? importBatchId,
    Value<int>? amountOriginalSatang,
    Value<String>? currencyCode,
    Value<String>? fxRate,
    Value<int>? amountThbSatang,
    Value<int>? feeThbSatang,
    Value<String?>? tag,
    Value<String?>? taxCategory,
    Value<int>? withholdingTaxSatang,
    Value<DateTime>? transactionDate,
    Value<String?>? workPeriod,
    Value<int?>? expectedAmountSatang,
    Value<String?>? note,
    Value<bool>? isCleared,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      assetId: assetId ?? this.assetId,
      importBatchId: importBatchId ?? this.importBatchId,
      amountOriginalSatang: amountOriginalSatang ?? this.amountOriginalSatang,
      currencyCode: currencyCode ?? this.currencyCode,
      fxRate: fxRate ?? this.fxRate,
      amountThbSatang: amountThbSatang ?? this.amountThbSatang,
      feeThbSatang: feeThbSatang ?? this.feeThbSatang,
      tag: tag ?? this.tag,
      taxCategory: taxCategory ?? this.taxCategory,
      withholdingTaxSatang: withholdingTaxSatang ?? this.withholdingTaxSatang,
      transactionDate: transactionDate ?? this.transactionDate,
      workPeriod: workPeriod ?? this.workPeriod,
      expectedAmountSatang: expectedAmountSatang ?? this.expectedAmountSatang,
      note: note ?? this.note,
      isCleared: isCleared ?? this.isCleared,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<String>(importBatchId.value);
    }
    if (amountOriginalSatang.present) {
      map['amount_original_satang'] = Variable<int>(amountOriginalSatang.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(fxRate.value);
    }
    if (amountThbSatang.present) {
      map['amount_thb_satang'] = Variable<int>(amountThbSatang.value);
    }
    if (feeThbSatang.present) {
      map['fee_thb_satang'] = Variable<int>(feeThbSatang.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (taxCategory.present) {
      map['tax_category'] = Variable<String>(taxCategory.value);
    }
    if (withholdingTaxSatang.present) {
      map['withholding_tax_satang'] = Variable<int>(withholdingTaxSatang.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (workPeriod.present) {
      map['work_period'] = Variable<String>(workPeriod.value);
    }
    if (expectedAmountSatang.present) {
      map['expected_amount_satang'] = Variable<int>(expectedAmountSatang.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isCleared.present) {
      map['is_cleared'] = Variable<bool>(isCleared.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('assetId: $assetId, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('amountOriginalSatang: $amountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('amountThbSatang: $amountThbSatang, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('tag: $tag, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('withholdingTaxSatang: $withholdingTaxSatang, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('workPeriod: $workPeriod, ')
          ..write('expectedAmountSatang: $expectedAmountSatang, ')
          ..write('note: $note, ')
          ..write('isCleared: $isCleared, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeDataJsonMeta = const VerificationMeta(
    'beforeDataJson',
  );
  @override
  late final GeneratedColumn<String> beforeDataJson = GeneratedColumn<String>(
    'before_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterDataJsonMeta = const VerificationMeta(
    'afterDataJson',
  );
  @override
  late final GeneratedColumn<String> afterDataJson = GeneratedColumn<String>(
    'after_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeTimestampMeta = const VerificationMeta(
    'changeTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> changeTimestamp =
      GeneratedColumn<DateTime>(
        'change_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    entityId,
    action,
    beforeDataJson,
    afterDataJson,
    changeTimestamp,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('before_data_json')) {
      context.handle(
        _beforeDataJsonMeta,
        beforeDataJson.isAcceptableOrUnknown(
          data['before_data_json']!,
          _beforeDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('after_data_json')) {
      context.handle(
        _afterDataJsonMeta,
        afterDataJson.isAcceptableOrUnknown(
          data['after_data_json']!,
          _afterDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('change_timestamp')) {
      context.handle(
        _changeTimestampMeta,
        changeTimestamp.isAcceptableOrUnknown(
          data['change_timestamp']!,
          _changeTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeTimestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      beforeDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_data_json'],
      ),
      afterDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_data_json'],
      ),
      changeTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}change_timestamp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String entityTable;
  final String entityId;
  final String action;
  final String? beforeDataJson;
  final String? afterDataJson;
  final DateTime changeTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AuditLog({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.action,
    this.beforeDataJson,
    this.afterDataJson,
    required this.changeTimestamp,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || beforeDataJson != null) {
      map['before_data_json'] = Variable<String>(beforeDataJson);
    }
    if (!nullToAbsent || afterDataJson != null) {
      map['after_data_json'] = Variable<String>(afterDataJson);
    }
    map['change_timestamp'] = Variable<DateTime>(changeTimestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      action: Value(action),
      beforeDataJson: beforeDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeDataJson),
      afterDataJson: afterDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(afterDataJson),
      changeTimestamp: Value(changeTimestamp),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      beforeDataJson: serializer.fromJson<String?>(json['beforeDataJson']),
      afterDataJson: serializer.fromJson<String?>(json['afterDataJson']),
      changeTimestamp: serializer.fromJson<DateTime>(json['changeTimestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'beforeDataJson': serializer.toJson<String?>(beforeDataJson),
      'afterDataJson': serializer.toJson<String?>(afterDataJson),
      'changeTimestamp': serializer.toJson<DateTime>(changeTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AuditLog copyWith({
    String? id,
    String? entityTable,
    String? entityId,
    String? action,
    Value<String?> beforeDataJson = const Value.absent(),
    Value<String?> afterDataJson = const Value.absent(),
    DateTime? changeTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AuditLog(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    beforeDataJson: beforeDataJson.present
        ? beforeDataJson.value
        : this.beforeDataJson,
    afterDataJson: afterDataJson.present
        ? afterDataJson.value
        : this.afterDataJson,
    changeTimestamp: changeTimestamp ?? this.changeTimestamp,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      beforeDataJson: data.beforeDataJson.present
          ? data.beforeDataJson.value
          : this.beforeDataJson,
      afterDataJson: data.afterDataJson.present
          ? data.afterDataJson.value
          : this.afterDataJson,
      changeTimestamp: data.changeTimestamp.present
          ? data.changeTimestamp.value
          : this.changeTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('beforeDataJson: $beforeDataJson, ')
          ..write('afterDataJson: $afterDataJson, ')
          ..write('changeTimestamp: $changeTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    entityId,
    action,
    beforeDataJson,
    afterDataJson,
    changeTimestamp,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.beforeDataJson == this.beforeDataJson &&
          other.afterDataJson == this.afterDataJson &&
          other.changeTimestamp == this.changeTimestamp &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> beforeDataJson;
  final Value<String?> afterDataJson;
  final Value<DateTime> changeTimestamp;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.beforeDataJson = const Value.absent(),
    this.afterDataJson = const Value.absent(),
    this.changeTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String entityTable,
    required String entityId,
    required String action,
    this.beforeDataJson = const Value.absent(),
    this.afterDataJson = const Value.absent(),
    required DateTime changeTimestamp,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityTable = Value(entityTable),
       entityId = Value(entityId),
       action = Value(action),
       changeTimestamp = Value(changeTimestamp),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? beforeDataJson,
    Expression<String>? afterDataJson,
    Expression<DateTime>? changeTimestamp,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (beforeDataJson != null) 'before_data_json': beforeDataJson,
      if (afterDataJson != null) 'after_data_json': afterDataJson,
      if (changeTimestamp != null) 'change_timestamp': changeTimestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? beforeDataJson,
    Value<String?>? afterDataJson,
    Value<DateTime>? changeTimestamp,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      beforeDataJson: beforeDataJson ?? this.beforeDataJson,
      afterDataJson: afterDataJson ?? this.afterDataJson,
      changeTimestamp: changeTimestamp ?? this.changeTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (beforeDataJson.present) {
      map['before_data_json'] = Variable<String>(beforeDataJson.value);
    }
    if (afterDataJson.present) {
      map['after_data_json'] = Variable<String>(afterDataJson.value);
    }
    if (changeTimestamp.present) {
      map['change_timestamp'] = Variable<DateTime>(changeTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('beforeDataJson: $beforeDataJson, ')
          ..write('afterDataJson: $afterDataJson, ')
          ..write('changeTimestamp: $changeTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditCardInstallmentsTable extends CreditCardInstallments
    with TableInfo<$CreditCardInstallmentsTable, CreditCardInstallment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardInstallmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountSatangMeta = const VerificationMeta(
    'totalAmountSatang',
  );
  @override
  late final GeneratedColumn<int> totalAmountSatang = GeneratedColumn<int>(
    'total_amount_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyAmountSatangMeta =
      const VerificationMeta('monthlyAmountSatang');
  @override
  late final GeneratedColumn<int> monthlyAmountSatang = GeneratedColumn<int>(
    'monthly_amount_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalTenorMonthsMeta = const VerificationMeta(
    'totalTenorMonths',
  );
  @override
  late final GeneratedColumn<int> totalTenorMonths = GeneratedColumn<int>(
    'total_tenor_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingTenorMonthsMeta =
      const VerificationMeta('remainingTenorMonths');
  @override
  late final GeneratedColumn<int> remainingTenorMonths = GeneratedColumn<int>(
    'remaining_tenor_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    accountId,
    totalAmountSatang,
    monthlyAmountSatang,
    totalTenorMonths,
    remainingTenorMonths,
    startDate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_card_installments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreditCardInstallment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('total_amount_satang')) {
      context.handle(
        _totalAmountSatangMeta,
        totalAmountSatang.isAcceptableOrUnknown(
          data['total_amount_satang']!,
          _totalAmountSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountSatangMeta);
    }
    if (data.containsKey('monthly_amount_satang')) {
      context.handle(
        _monthlyAmountSatangMeta,
        monthlyAmountSatang.isAcceptableOrUnknown(
          data['monthly_amount_satang']!,
          _monthlyAmountSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyAmountSatangMeta);
    }
    if (data.containsKey('total_tenor_months')) {
      context.handle(
        _totalTenorMonthsMeta,
        totalTenorMonths.isAcceptableOrUnknown(
          data['total_tenor_months']!,
          _totalTenorMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalTenorMonthsMeta);
    }
    if (data.containsKey('remaining_tenor_months')) {
      context.handle(
        _remainingTenorMonthsMeta,
        remainingTenorMonths.isAcceptableOrUnknown(
          data['remaining_tenor_months']!,
          _remainingTenorMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingTenorMonthsMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCardInstallment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCardInstallment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      totalAmountSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_satang'],
      )!,
      monthlyAmountSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_amount_satang'],
      )!,
      totalTenorMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tenor_months'],
      )!,
      remainingTenorMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_tenor_months'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CreditCardInstallmentsTable createAlias(String alias) {
    return $CreditCardInstallmentsTable(attachedDatabase, alias);
  }
}

class CreditCardInstallment extends DataClass
    implements Insertable<CreditCardInstallment> {
  final String id;
  final String transactionId;
  final String accountId;
  final int totalAmountSatang;
  final int monthlyAmountSatang;
  final int totalTenorMonths;
  final int remainingTenorMonths;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CreditCardInstallment({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.totalAmountSatang,
    required this.monthlyAmountSatang,
    required this.totalTenorMonths,
    required this.remainingTenorMonths,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['account_id'] = Variable<String>(accountId);
    map['total_amount_satang'] = Variable<int>(totalAmountSatang);
    map['monthly_amount_satang'] = Variable<int>(monthlyAmountSatang);
    map['total_tenor_months'] = Variable<int>(totalTenorMonths);
    map['remaining_tenor_months'] = Variable<int>(remainingTenorMonths);
    map['start_date'] = Variable<DateTime>(startDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CreditCardInstallmentsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardInstallmentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      accountId: Value(accountId),
      totalAmountSatang: Value(totalAmountSatang),
      monthlyAmountSatang: Value(monthlyAmountSatang),
      totalTenorMonths: Value(totalTenorMonths),
      remainingTenorMonths: Value(remainingTenorMonths),
      startDate: Value(startDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CreditCardInstallment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCardInstallment(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      totalAmountSatang: serializer.fromJson<int>(json['totalAmountSatang']),
      monthlyAmountSatang: serializer.fromJson<int>(
        json['monthlyAmountSatang'],
      ),
      totalTenorMonths: serializer.fromJson<int>(json['totalTenorMonths']),
      remainingTenorMonths: serializer.fromJson<int>(
        json['remainingTenorMonths'],
      ),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'accountId': serializer.toJson<String>(accountId),
      'totalAmountSatang': serializer.toJson<int>(totalAmountSatang),
      'monthlyAmountSatang': serializer.toJson<int>(monthlyAmountSatang),
      'totalTenorMonths': serializer.toJson<int>(totalTenorMonths),
      'remainingTenorMonths': serializer.toJson<int>(remainingTenorMonths),
      'startDate': serializer.toJson<DateTime>(startDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CreditCardInstallment copyWith({
    String? id,
    String? transactionId,
    String? accountId,
    int? totalAmountSatang,
    int? monthlyAmountSatang,
    int? totalTenorMonths,
    int? remainingTenorMonths,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CreditCardInstallment(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    accountId: accountId ?? this.accountId,
    totalAmountSatang: totalAmountSatang ?? this.totalAmountSatang,
    monthlyAmountSatang: monthlyAmountSatang ?? this.monthlyAmountSatang,
    totalTenorMonths: totalTenorMonths ?? this.totalTenorMonths,
    remainingTenorMonths: remainingTenorMonths ?? this.remainingTenorMonths,
    startDate: startDate ?? this.startDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CreditCardInstallment copyWithCompanion(
    CreditCardInstallmentsCompanion data,
  ) {
    return CreditCardInstallment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      totalAmountSatang: data.totalAmountSatang.present
          ? data.totalAmountSatang.value
          : this.totalAmountSatang,
      monthlyAmountSatang: data.monthlyAmountSatang.present
          ? data.monthlyAmountSatang.value
          : this.monthlyAmountSatang,
      totalTenorMonths: data.totalTenorMonths.present
          ? data.totalTenorMonths.value
          : this.totalTenorMonths,
      remainingTenorMonths: data.remainingTenorMonths.present
          ? data.remainingTenorMonths.value
          : this.remainingTenorMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardInstallment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('totalAmountSatang: $totalAmountSatang, ')
          ..write('monthlyAmountSatang: $monthlyAmountSatang, ')
          ..write('totalTenorMonths: $totalTenorMonths, ')
          ..write('remainingTenorMonths: $remainingTenorMonths, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    accountId,
    totalAmountSatang,
    monthlyAmountSatang,
    totalTenorMonths,
    remainingTenorMonths,
    startDate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCardInstallment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.accountId == this.accountId &&
          other.totalAmountSatang == this.totalAmountSatang &&
          other.monthlyAmountSatang == this.monthlyAmountSatang &&
          other.totalTenorMonths == this.totalTenorMonths &&
          other.remainingTenorMonths == this.remainingTenorMonths &&
          other.startDate == this.startDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CreditCardInstallmentsCompanion
    extends UpdateCompanion<CreditCardInstallment> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> accountId;
  final Value<int> totalAmountSatang;
  final Value<int> monthlyAmountSatang;
  final Value<int> totalTenorMonths;
  final Value<int> remainingTenorMonths;
  final Value<DateTime> startDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CreditCardInstallmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.totalAmountSatang = const Value.absent(),
    this.monthlyAmountSatang = const Value.absent(),
    this.totalTenorMonths = const Value.absent(),
    this.remainingTenorMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditCardInstallmentsCompanion.insert({
    required String id,
    required String transactionId,
    required String accountId,
    required int totalAmountSatang,
    required int monthlyAmountSatang,
    required int totalTenorMonths,
    required int remainingTenorMonths,
    required DateTime startDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       accountId = Value(accountId),
       totalAmountSatang = Value(totalAmountSatang),
       monthlyAmountSatang = Value(monthlyAmountSatang),
       totalTenorMonths = Value(totalTenorMonths),
       remainingTenorMonths = Value(remainingTenorMonths),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CreditCardInstallment> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? accountId,
    Expression<int>? totalAmountSatang,
    Expression<int>? monthlyAmountSatang,
    Expression<int>? totalTenorMonths,
    Expression<int>? remainingTenorMonths,
    Expression<DateTime>? startDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (accountId != null) 'account_id': accountId,
      if (totalAmountSatang != null) 'total_amount_satang': totalAmountSatang,
      if (monthlyAmountSatang != null)
        'monthly_amount_satang': monthlyAmountSatang,
      if (totalTenorMonths != null) 'total_tenor_months': totalTenorMonths,
      if (remainingTenorMonths != null)
        'remaining_tenor_months': remainingTenorMonths,
      if (startDate != null) 'start_date': startDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditCardInstallmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? accountId,
    Value<int>? totalAmountSatang,
    Value<int>? monthlyAmountSatang,
    Value<int>? totalTenorMonths,
    Value<int>? remainingTenorMonths,
    Value<DateTime>? startDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CreditCardInstallmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      totalAmountSatang: totalAmountSatang ?? this.totalAmountSatang,
      monthlyAmountSatang: monthlyAmountSatang ?? this.monthlyAmountSatang,
      totalTenorMonths: totalTenorMonths ?? this.totalTenorMonths,
      remainingTenorMonths: remainingTenorMonths ?? this.remainingTenorMonths,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (totalAmountSatang.present) {
      map['total_amount_satang'] = Variable<int>(totalAmountSatang.value);
    }
    if (monthlyAmountSatang.present) {
      map['monthly_amount_satang'] = Variable<int>(monthlyAmountSatang.value);
    }
    if (totalTenorMonths.present) {
      map['total_tenor_months'] = Variable<int>(totalTenorMonths.value);
    }
    if (remainingTenorMonths.present) {
      map['remaining_tenor_months'] = Variable<int>(remainingTenorMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardInstallmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('totalAmountSatang: $totalAmountSatang, ')
          ..write('monthlyAmountSatang: $monthlyAmountSatang, ')
          ..write('totalTenorMonths: $totalTenorMonths, ')
          ..write('remainingTenorMonths: $remainingTenorMonths, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentLotsTable extends InvestmentLots
    with TableInfo<$InvestmentLotsTable, InvestmentLot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentLotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyTransactionIdMeta = const VerificationMeta(
    'buyTransactionId',
  );
  @override
  late final GeneratedColumn<String> buyTransactionId = GeneratedColumn<String>(
    'buy_transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyDateMeta = const VerificationMeta(
    'buyDate',
  );
  @override
  late final GeneratedColumn<DateTime> buyDate = GeneratedColumn<DateTime>(
    'buy_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingQuantityMeta = const VerificationMeta(
    'remainingQuantity',
  );
  @override
  late final GeneratedColumn<String> remainingQuantity =
      GeneratedColumn<String>(
        'remaining_quantity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _costPerUnitOriginalSatangMeta =
      const VerificationMeta('costPerUnitOriginalSatang');
  @override
  late final GeneratedColumn<int> costPerUnitOriginalSatang =
      GeneratedColumn<int>(
        'cost_per_unit_original_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<String> fxRate = GeneratedColumn<String>(
    'fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPerUnitThbSatangMeta =
      const VerificationMeta('costPerUnitThbSatang');
  @override
  late final GeneratedColumn<int> costPerUnitThbSatang = GeneratedColumn<int>(
    'cost_per_unit_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeThbSatangMeta = const VerificationMeta(
    'feeThbSatang',
  );
  @override
  late final GeneratedColumn<int> feeThbSatang = GeneratedColumn<int>(
    'fee_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostThbSatangMeta =
      const VerificationMeta('totalCostThbSatang');
  @override
  late final GeneratedColumn<int> totalCostThbSatang = GeneratedColumn<int>(
    'total_cost_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remainingCostThbSatangMeta =
      const VerificationMeta('remainingCostThbSatang');
  @override
  late final GeneratedColumn<int> remainingCostThbSatang = GeneratedColumn<int>(
    'remaining_cost_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    buyTransactionId,
    buyDate,
    quantity,
    remainingQuantity,
    costPerUnitOriginalSatang,
    fxRate,
    costPerUnitThbSatang,
    feeThbSatang,
    totalCostThbSatang,
    remainingCostThbSatang,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentLot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('buy_transaction_id')) {
      context.handle(
        _buyTransactionIdMeta,
        buyTransactionId.isAcceptableOrUnknown(
          data['buy_transaction_id']!,
          _buyTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buyTransactionIdMeta);
    }
    if (data.containsKey('buy_date')) {
      context.handle(
        _buyDateMeta,
        buyDate.isAcceptableOrUnknown(data['buy_date']!, _buyDateMeta),
      );
    } else if (isInserting) {
      context.missing(_buyDateMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('remaining_quantity')) {
      context.handle(
        _remainingQuantityMeta,
        remainingQuantity.isAcceptableOrUnknown(
          data['remaining_quantity']!,
          _remainingQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingQuantityMeta);
    }
    if (data.containsKey('cost_per_unit_original_satang')) {
      context.handle(
        _costPerUnitOriginalSatangMeta,
        costPerUnitOriginalSatang.isAcceptableOrUnknown(
          data['cost_per_unit_original_satang']!,
          _costPerUnitOriginalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costPerUnitOriginalSatangMeta);
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    } else if (isInserting) {
      context.missing(_fxRateMeta);
    }
    if (data.containsKey('cost_per_unit_thb_satang')) {
      context.handle(
        _costPerUnitThbSatangMeta,
        costPerUnitThbSatang.isAcceptableOrUnknown(
          data['cost_per_unit_thb_satang']!,
          _costPerUnitThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costPerUnitThbSatangMeta);
    }
    if (data.containsKey('fee_thb_satang')) {
      context.handle(
        _feeThbSatangMeta,
        feeThbSatang.isAcceptableOrUnknown(
          data['fee_thb_satang']!,
          _feeThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feeThbSatangMeta);
    }
    if (data.containsKey('total_cost_thb_satang')) {
      context.handle(
        _totalCostThbSatangMeta,
        totalCostThbSatang.isAcceptableOrUnknown(
          data['total_cost_thb_satang']!,
          _totalCostThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('remaining_cost_thb_satang')) {
      context.handle(
        _remainingCostThbSatangMeta,
        remainingCostThbSatang.isAcceptableOrUnknown(
          data['remaining_cost_thb_satang']!,
          _remainingCostThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentLot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentLot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      buyTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buy_transaction_id'],
      )!,
      buyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}buy_date'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      remainingQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remaining_quantity'],
      )!,
      costPerUnitOriginalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_per_unit_original_satang'],
      )!,
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fx_rate'],
      )!,
      costPerUnitThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_per_unit_thb_satang'],
      )!,
      feeThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_thb_satang'],
      )!,
      totalCostThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_thb_satang'],
      )!,
      remainingCostThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_cost_thb_satang'],
      )!,
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InvestmentLotsTable createAlias(String alias) {
    return $InvestmentLotsTable(attachedDatabase, alias);
  }
}

class InvestmentLot extends DataClass implements Insertable<InvestmentLot> {
  final String id;
  final String assetId;
  final String buyTransactionId;
  final DateTime buyDate;
  final String quantity;
  final String remainingQuantity;
  final int costPerUnitOriginalSatang;
  final String fxRate;
  final int costPerUnitThbSatang;
  final int feeThbSatang;
  final int totalCostThbSatang;
  final int remainingCostThbSatang;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InvestmentLot({
    required this.id,
    required this.assetId,
    required this.buyTransactionId,
    required this.buyDate,
    required this.quantity,
    required this.remainingQuantity,
    required this.costPerUnitOriginalSatang,
    required this.fxRate,
    required this.costPerUnitThbSatang,
    required this.feeThbSatang,
    required this.totalCostThbSatang,
    required this.remainingCostThbSatang,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['buy_transaction_id'] = Variable<String>(buyTransactionId);
    map['buy_date'] = Variable<DateTime>(buyDate);
    map['quantity'] = Variable<String>(quantity);
    map['remaining_quantity'] = Variable<String>(remainingQuantity);
    map['cost_per_unit_original_satang'] = Variable<int>(
      costPerUnitOriginalSatang,
    );
    map['fx_rate'] = Variable<String>(fxRate);
    map['cost_per_unit_thb_satang'] = Variable<int>(costPerUnitThbSatang);
    map['fee_thb_satang'] = Variable<int>(feeThbSatang);
    map['total_cost_thb_satang'] = Variable<int>(totalCostThbSatang);
    map['remaining_cost_thb_satang'] = Variable<int>(remainingCostThbSatang);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InvestmentLotsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentLotsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      buyTransactionId: Value(buyTransactionId),
      buyDate: Value(buyDate),
      quantity: Value(quantity),
      remainingQuantity: Value(remainingQuantity),
      costPerUnitOriginalSatang: Value(costPerUnitOriginalSatang),
      fxRate: Value(fxRate),
      costPerUnitThbSatang: Value(costPerUnitThbSatang),
      feeThbSatang: Value(feeThbSatang),
      totalCostThbSatang: Value(totalCostThbSatang),
      remainingCostThbSatang: Value(remainingCostThbSatang),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InvestmentLot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentLot(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      buyTransactionId: serializer.fromJson<String>(json['buyTransactionId']),
      buyDate: serializer.fromJson<DateTime>(json['buyDate']),
      quantity: serializer.fromJson<String>(json['quantity']),
      remainingQuantity: serializer.fromJson<String>(json['remainingQuantity']),
      costPerUnitOriginalSatang: serializer.fromJson<int>(
        json['costPerUnitOriginalSatang'],
      ),
      fxRate: serializer.fromJson<String>(json['fxRate']),
      costPerUnitThbSatang: serializer.fromJson<int>(
        json['costPerUnitThbSatang'],
      ),
      feeThbSatang: serializer.fromJson<int>(json['feeThbSatang']),
      totalCostThbSatang: serializer.fromJson<int>(json['totalCostThbSatang']),
      remainingCostThbSatang: serializer.fromJson<int>(
        json['remainingCostThbSatang'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'buyTransactionId': serializer.toJson<String>(buyTransactionId),
      'buyDate': serializer.toJson<DateTime>(buyDate),
      'quantity': serializer.toJson<String>(quantity),
      'remainingQuantity': serializer.toJson<String>(remainingQuantity),
      'costPerUnitOriginalSatang': serializer.toJson<int>(
        costPerUnitOriginalSatang,
      ),
      'fxRate': serializer.toJson<String>(fxRate),
      'costPerUnitThbSatang': serializer.toJson<int>(costPerUnitThbSatang),
      'feeThbSatang': serializer.toJson<int>(feeThbSatang),
      'totalCostThbSatang': serializer.toJson<int>(totalCostThbSatang),
      'remainingCostThbSatang': serializer.toJson<int>(remainingCostThbSatang),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InvestmentLot copyWith({
    String? id,
    String? assetId,
    String? buyTransactionId,
    DateTime? buyDate,
    String? quantity,
    String? remainingQuantity,
    int? costPerUnitOriginalSatang,
    String? fxRate,
    int? costPerUnitThbSatang,
    int? feeThbSatang,
    int? totalCostThbSatang,
    int? remainingCostThbSatang,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InvestmentLot(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    buyTransactionId: buyTransactionId ?? this.buyTransactionId,
    buyDate: buyDate ?? this.buyDate,
    quantity: quantity ?? this.quantity,
    remainingQuantity: remainingQuantity ?? this.remainingQuantity,
    costPerUnitOriginalSatang:
        costPerUnitOriginalSatang ?? this.costPerUnitOriginalSatang,
    fxRate: fxRate ?? this.fxRate,
    costPerUnitThbSatang: costPerUnitThbSatang ?? this.costPerUnitThbSatang,
    feeThbSatang: feeThbSatang ?? this.feeThbSatang,
    totalCostThbSatang: totalCostThbSatang ?? this.totalCostThbSatang,
    remainingCostThbSatang:
        remainingCostThbSatang ?? this.remainingCostThbSatang,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InvestmentLot copyWithCompanion(InvestmentLotsCompanion data) {
    return InvestmentLot(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      buyTransactionId: data.buyTransactionId.present
          ? data.buyTransactionId.value
          : this.buyTransactionId,
      buyDate: data.buyDate.present ? data.buyDate.value : this.buyDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      remainingQuantity: data.remainingQuantity.present
          ? data.remainingQuantity.value
          : this.remainingQuantity,
      costPerUnitOriginalSatang: data.costPerUnitOriginalSatang.present
          ? data.costPerUnitOriginalSatang.value
          : this.costPerUnitOriginalSatang,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      costPerUnitThbSatang: data.costPerUnitThbSatang.present
          ? data.costPerUnitThbSatang.value
          : this.costPerUnitThbSatang,
      feeThbSatang: data.feeThbSatang.present
          ? data.feeThbSatang.value
          : this.feeThbSatang,
      totalCostThbSatang: data.totalCostThbSatang.present
          ? data.totalCostThbSatang.value
          : this.totalCostThbSatang,
      remainingCostThbSatang: data.remainingCostThbSatang.present
          ? data.remainingCostThbSatang.value
          : this.remainingCostThbSatang,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLot(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('buyTransactionId: $buyTransactionId, ')
          ..write('buyDate: $buyDate, ')
          ..write('quantity: $quantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('costPerUnitOriginalSatang: $costPerUnitOriginalSatang, ')
          ..write('fxRate: $fxRate, ')
          ..write('costPerUnitThbSatang: $costPerUnitThbSatang, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('totalCostThbSatang: $totalCostThbSatang, ')
          ..write('remainingCostThbSatang: $remainingCostThbSatang, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    buyTransactionId,
    buyDate,
    quantity,
    remainingQuantity,
    costPerUnitOriginalSatang,
    fxRate,
    costPerUnitThbSatang,
    feeThbSatang,
    totalCostThbSatang,
    remainingCostThbSatang,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentLot &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.buyTransactionId == this.buyTransactionId &&
          other.buyDate == this.buyDate &&
          other.quantity == this.quantity &&
          other.remainingQuantity == this.remainingQuantity &&
          other.costPerUnitOriginalSatang == this.costPerUnitOriginalSatang &&
          other.fxRate == this.fxRate &&
          other.costPerUnitThbSatang == this.costPerUnitThbSatang &&
          other.feeThbSatang == this.feeThbSatang &&
          other.totalCostThbSatang == this.totalCostThbSatang &&
          other.remainingCostThbSatang == this.remainingCostThbSatang &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InvestmentLotsCompanion extends UpdateCompanion<InvestmentLot> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<String> buyTransactionId;
  final Value<DateTime> buyDate;
  final Value<String> quantity;
  final Value<String> remainingQuantity;
  final Value<int> costPerUnitOriginalSatang;
  final Value<String> fxRate;
  final Value<int> costPerUnitThbSatang;
  final Value<int> feeThbSatang;
  final Value<int> totalCostThbSatang;
  final Value<int> remainingCostThbSatang;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InvestmentLotsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.buyTransactionId = const Value.absent(),
    this.buyDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.remainingQuantity = const Value.absent(),
    this.costPerUnitOriginalSatang = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.costPerUnitThbSatang = const Value.absent(),
    this.feeThbSatang = const Value.absent(),
    this.totalCostThbSatang = const Value.absent(),
    this.remainingCostThbSatang = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentLotsCompanion.insert({
    required String id,
    required String assetId,
    required String buyTransactionId,
    required DateTime buyDate,
    required String quantity,
    required String remainingQuantity,
    required int costPerUnitOriginalSatang,
    required String fxRate,
    required int costPerUnitThbSatang,
    required int feeThbSatang,
    this.totalCostThbSatang = const Value.absent(),
    this.remainingCostThbSatang = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assetId = Value(assetId),
       buyTransactionId = Value(buyTransactionId),
       buyDate = Value(buyDate),
       quantity = Value(quantity),
       remainingQuantity = Value(remainingQuantity),
       costPerUnitOriginalSatang = Value(costPerUnitOriginalSatang),
       fxRate = Value(fxRate),
       costPerUnitThbSatang = Value(costPerUnitThbSatang),
       feeThbSatang = Value(feeThbSatang),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InvestmentLot> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<String>? buyTransactionId,
    Expression<DateTime>? buyDate,
    Expression<String>? quantity,
    Expression<String>? remainingQuantity,
    Expression<int>? costPerUnitOriginalSatang,
    Expression<String>? fxRate,
    Expression<int>? costPerUnitThbSatang,
    Expression<int>? feeThbSatang,
    Expression<int>? totalCostThbSatang,
    Expression<int>? remainingCostThbSatang,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (buyTransactionId != null) 'buy_transaction_id': buyTransactionId,
      if (buyDate != null) 'buy_date': buyDate,
      if (quantity != null) 'quantity': quantity,
      if (remainingQuantity != null) 'remaining_quantity': remainingQuantity,
      if (costPerUnitOriginalSatang != null)
        'cost_per_unit_original_satang': costPerUnitOriginalSatang,
      if (fxRate != null) 'fx_rate': fxRate,
      if (costPerUnitThbSatang != null)
        'cost_per_unit_thb_satang': costPerUnitThbSatang,
      if (feeThbSatang != null) 'fee_thb_satang': feeThbSatang,
      if (totalCostThbSatang != null)
        'total_cost_thb_satang': totalCostThbSatang,
      if (remainingCostThbSatang != null)
        'remaining_cost_thb_satang': remainingCostThbSatang,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentLotsCompanion copyWith({
    Value<String>? id,
    Value<String>? assetId,
    Value<String>? buyTransactionId,
    Value<DateTime>? buyDate,
    Value<String>? quantity,
    Value<String>? remainingQuantity,
    Value<int>? costPerUnitOriginalSatang,
    Value<String>? fxRate,
    Value<int>? costPerUnitThbSatang,
    Value<int>? feeThbSatang,
    Value<int>? totalCostThbSatang,
    Value<int>? remainingCostThbSatang,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InvestmentLotsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      buyTransactionId: buyTransactionId ?? this.buyTransactionId,
      buyDate: buyDate ?? this.buyDate,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      costPerUnitOriginalSatang:
          costPerUnitOriginalSatang ?? this.costPerUnitOriginalSatang,
      fxRate: fxRate ?? this.fxRate,
      costPerUnitThbSatang: costPerUnitThbSatang ?? this.costPerUnitThbSatang,
      feeThbSatang: feeThbSatang ?? this.feeThbSatang,
      totalCostThbSatang: totalCostThbSatang ?? this.totalCostThbSatang,
      remainingCostThbSatang:
          remainingCostThbSatang ?? this.remainingCostThbSatang,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (buyTransactionId.present) {
      map['buy_transaction_id'] = Variable<String>(buyTransactionId.value);
    }
    if (buyDate.present) {
      map['buy_date'] = Variable<DateTime>(buyDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (remainingQuantity.present) {
      map['remaining_quantity'] = Variable<String>(remainingQuantity.value);
    }
    if (costPerUnitOriginalSatang.present) {
      map['cost_per_unit_original_satang'] = Variable<int>(
        costPerUnitOriginalSatang.value,
      );
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(fxRate.value);
    }
    if (costPerUnitThbSatang.present) {
      map['cost_per_unit_thb_satang'] = Variable<int>(
        costPerUnitThbSatang.value,
      );
    }
    if (feeThbSatang.present) {
      map['fee_thb_satang'] = Variable<int>(feeThbSatang.value);
    }
    if (totalCostThbSatang.present) {
      map['total_cost_thb_satang'] = Variable<int>(totalCostThbSatang.value);
    }
    if (remainingCostThbSatang.present) {
      map['remaining_cost_thb_satang'] = Variable<int>(
        remainingCostThbSatang.value,
      );
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLotsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('buyTransactionId: $buyTransactionId, ')
          ..write('buyDate: $buyDate, ')
          ..write('quantity: $quantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('costPerUnitOriginalSatang: $costPerUnitOriginalSatang, ')
          ..write('fxRate: $fxRate, ')
          ..write('costPerUnitThbSatang: $costPerUnitThbSatang, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('totalCostThbSatang: $totalCostThbSatang, ')
          ..write('remainingCostThbSatang: $remainingCostThbSatang, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentSalesTable extends InvestmentSales
    with TableInfo<$InvestmentSalesTable, InvestmentSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellTransactionIdMeta = const VerificationMeta(
    'sellTransactionId',
  );
  @override
  late final GeneratedColumn<String> sellTransactionId =
      GeneratedColumn<String>(
        'sell_transaction_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellDateMeta = const VerificationMeta(
    'sellDate',
  );
  @override
  late final GeneratedColumn<DateTime> sellDate = GeneratedColumn<DateTime>(
    'sell_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantitySoldMeta = const VerificationMeta(
    'quantitySold',
  );
  @override
  late final GeneratedColumn<String> quantitySold = GeneratedColumn<String>(
    'quantity_sold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellPriceThbSatangMeta =
      const VerificationMeta('sellPriceThbSatang');
  @override
  late final GeneratedColumn<int> sellPriceThbSatang = GeneratedColumn<int>(
    'sell_price_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costThbSatangMeta = const VerificationMeta(
    'costThbSatang',
  );
  @override
  late final GeneratedColumn<int> costThbSatang = GeneratedColumn<int>(
    'cost_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _realizedGainLossThbSatangMeta =
      const VerificationMeta('realizedGainLossThbSatang');
  @override
  late final GeneratedColumn<int> realizedGainLossThbSatang =
      GeneratedColumn<int>(
        'realized_gain_loss_thb_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _priceGainLossThbSatangMeta =
      const VerificationMeta('priceGainLossThbSatang');
  @override
  late final GeneratedColumn<int> priceGainLossThbSatang = GeneratedColumn<int>(
    'price_gain_loss_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fxGainLossThbSatangMeta =
      const VerificationMeta('fxGainLossThbSatang');
  @override
  late final GeneratedColumn<int> fxGainLossThbSatang = GeneratedColumn<int>(
    'fx_gain_loss_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sellFxRateMeta = const VerificationMeta(
    'sellFxRate',
  );
  @override
  late final GeneratedColumn<String> sellFxRate = GeneratedColumn<String>(
    'sell_fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.000000'),
  );
  static const VerificationMeta _buyFxRateMeta = const VerificationMeta(
    'buyFxRate',
  );
  @override
  late final GeneratedColumn<String> buyFxRate = GeneratedColumn<String>(
    'buy_fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.000000'),
  );
  static const VerificationMeta _feeThbSatangMeta = const VerificationMeta(
    'feeThbSatang',
  );
  @override
  late final GeneratedColumn<int> feeThbSatang = GeneratedColumn<int>(
    'fee_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sellTransactionId,
    lotId,
    sellDate,
    quantitySold,
    sellPriceThbSatang,
    costThbSatang,
    realizedGainLossThbSatang,
    priceGainLossThbSatang,
    fxGainLossThbSatang,
    sellFxRate,
    buyFxRate,
    feeThbSatang,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sell_transaction_id')) {
      context.handle(
        _sellTransactionIdMeta,
        sellTransactionId.isAcceptableOrUnknown(
          data['sell_transaction_id']!,
          _sellTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellTransactionIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('sell_date')) {
      context.handle(
        _sellDateMeta,
        sellDate.isAcceptableOrUnknown(data['sell_date']!, _sellDateMeta),
      );
    } else if (isInserting) {
      context.missing(_sellDateMeta);
    }
    if (data.containsKey('quantity_sold')) {
      context.handle(
        _quantitySoldMeta,
        quantitySold.isAcceptableOrUnknown(
          data['quantity_sold']!,
          _quantitySoldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantitySoldMeta);
    }
    if (data.containsKey('sell_price_thb_satang')) {
      context.handle(
        _sellPriceThbSatangMeta,
        sellPriceThbSatang.isAcceptableOrUnknown(
          data['sell_price_thb_satang']!,
          _sellPriceThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellPriceThbSatangMeta);
    }
    if (data.containsKey('cost_thb_satang')) {
      context.handle(
        _costThbSatangMeta,
        costThbSatang.isAcceptableOrUnknown(
          data['cost_thb_satang']!,
          _costThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costThbSatangMeta);
    }
    if (data.containsKey('realized_gain_loss_thb_satang')) {
      context.handle(
        _realizedGainLossThbSatangMeta,
        realizedGainLossThbSatang.isAcceptableOrUnknown(
          data['realized_gain_loss_thb_satang']!,
          _realizedGainLossThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_realizedGainLossThbSatangMeta);
    }
    if (data.containsKey('price_gain_loss_thb_satang')) {
      context.handle(
        _priceGainLossThbSatangMeta,
        priceGainLossThbSatang.isAcceptableOrUnknown(
          data['price_gain_loss_thb_satang']!,
          _priceGainLossThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('fx_gain_loss_thb_satang')) {
      context.handle(
        _fxGainLossThbSatangMeta,
        fxGainLossThbSatang.isAcceptableOrUnknown(
          data['fx_gain_loss_thb_satang']!,
          _fxGainLossThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('sell_fx_rate')) {
      context.handle(
        _sellFxRateMeta,
        sellFxRate.isAcceptableOrUnknown(
          data['sell_fx_rate']!,
          _sellFxRateMeta,
        ),
      );
    }
    if (data.containsKey('buy_fx_rate')) {
      context.handle(
        _buyFxRateMeta,
        buyFxRate.isAcceptableOrUnknown(data['buy_fx_rate']!, _buyFxRateMeta),
      );
    }
    if (data.containsKey('fee_thb_satang')) {
      context.handle(
        _feeThbSatangMeta,
        feeThbSatang.isAcceptableOrUnknown(
          data['fee_thb_satang']!,
          _feeThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feeThbSatangMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentSale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sellTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sell_transaction_id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      sellDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sell_date'],
      )!,
      quantitySold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_sold'],
      )!,
      sellPriceThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_price_thb_satang'],
      )!,
      costThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_thb_satang'],
      )!,
      realizedGainLossThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}realized_gain_loss_thb_satang'],
      )!,
      priceGainLossThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_gain_loss_thb_satang'],
      )!,
      fxGainLossThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fx_gain_loss_thb_satang'],
      )!,
      sellFxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sell_fx_rate'],
      )!,
      buyFxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buy_fx_rate'],
      )!,
      feeThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee_thb_satang'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InvestmentSalesTable createAlias(String alias) {
    return $InvestmentSalesTable(attachedDatabase, alias);
  }
}

class InvestmentSale extends DataClass implements Insertable<InvestmentSale> {
  final String id;
  final String sellTransactionId;
  final String lotId;
  final DateTime sellDate;
  final String quantitySold;
  final int sellPriceThbSatang;
  final int costThbSatang;
  final int realizedGainLossThbSatang;
  final int priceGainLossThbSatang;
  final int fxGainLossThbSatang;
  final String sellFxRate;
  final String buyFxRate;
  final int feeThbSatang;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InvestmentSale({
    required this.id,
    required this.sellTransactionId,
    required this.lotId,
    required this.sellDate,
    required this.quantitySold,
    required this.sellPriceThbSatang,
    required this.costThbSatang,
    required this.realizedGainLossThbSatang,
    required this.priceGainLossThbSatang,
    required this.fxGainLossThbSatang,
    required this.sellFxRate,
    required this.buyFxRate,
    required this.feeThbSatang,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sell_transaction_id'] = Variable<String>(sellTransactionId);
    map['lot_id'] = Variable<String>(lotId);
    map['sell_date'] = Variable<DateTime>(sellDate);
    map['quantity_sold'] = Variable<String>(quantitySold);
    map['sell_price_thb_satang'] = Variable<int>(sellPriceThbSatang);
    map['cost_thb_satang'] = Variable<int>(costThbSatang);
    map['realized_gain_loss_thb_satang'] = Variable<int>(
      realizedGainLossThbSatang,
    );
    map['price_gain_loss_thb_satang'] = Variable<int>(priceGainLossThbSatang);
    map['fx_gain_loss_thb_satang'] = Variable<int>(fxGainLossThbSatang);
    map['sell_fx_rate'] = Variable<String>(sellFxRate);
    map['buy_fx_rate'] = Variable<String>(buyFxRate);
    map['fee_thb_satang'] = Variable<int>(feeThbSatang);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InvestmentSalesCompanion toCompanion(bool nullToAbsent) {
    return InvestmentSalesCompanion(
      id: Value(id),
      sellTransactionId: Value(sellTransactionId),
      lotId: Value(lotId),
      sellDate: Value(sellDate),
      quantitySold: Value(quantitySold),
      sellPriceThbSatang: Value(sellPriceThbSatang),
      costThbSatang: Value(costThbSatang),
      realizedGainLossThbSatang: Value(realizedGainLossThbSatang),
      priceGainLossThbSatang: Value(priceGainLossThbSatang),
      fxGainLossThbSatang: Value(fxGainLossThbSatang),
      sellFxRate: Value(sellFxRate),
      buyFxRate: Value(buyFxRate),
      feeThbSatang: Value(feeThbSatang),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InvestmentSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentSale(
      id: serializer.fromJson<String>(json['id']),
      sellTransactionId: serializer.fromJson<String>(json['sellTransactionId']),
      lotId: serializer.fromJson<String>(json['lotId']),
      sellDate: serializer.fromJson<DateTime>(json['sellDate']),
      quantitySold: serializer.fromJson<String>(json['quantitySold']),
      sellPriceThbSatang: serializer.fromJson<int>(json['sellPriceThbSatang']),
      costThbSatang: serializer.fromJson<int>(json['costThbSatang']),
      realizedGainLossThbSatang: serializer.fromJson<int>(
        json['realizedGainLossThbSatang'],
      ),
      priceGainLossThbSatang: serializer.fromJson<int>(
        json['priceGainLossThbSatang'],
      ),
      fxGainLossThbSatang: serializer.fromJson<int>(
        json['fxGainLossThbSatang'],
      ),
      sellFxRate: serializer.fromJson<String>(json['sellFxRate']),
      buyFxRate: serializer.fromJson<String>(json['buyFxRate']),
      feeThbSatang: serializer.fromJson<int>(json['feeThbSatang']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sellTransactionId': serializer.toJson<String>(sellTransactionId),
      'lotId': serializer.toJson<String>(lotId),
      'sellDate': serializer.toJson<DateTime>(sellDate),
      'quantitySold': serializer.toJson<String>(quantitySold),
      'sellPriceThbSatang': serializer.toJson<int>(sellPriceThbSatang),
      'costThbSatang': serializer.toJson<int>(costThbSatang),
      'realizedGainLossThbSatang': serializer.toJson<int>(
        realizedGainLossThbSatang,
      ),
      'priceGainLossThbSatang': serializer.toJson<int>(priceGainLossThbSatang),
      'fxGainLossThbSatang': serializer.toJson<int>(fxGainLossThbSatang),
      'sellFxRate': serializer.toJson<String>(sellFxRate),
      'buyFxRate': serializer.toJson<String>(buyFxRate),
      'feeThbSatang': serializer.toJson<int>(feeThbSatang),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InvestmentSale copyWith({
    String? id,
    String? sellTransactionId,
    String? lotId,
    DateTime? sellDate,
    String? quantitySold,
    int? sellPriceThbSatang,
    int? costThbSatang,
    int? realizedGainLossThbSatang,
    int? priceGainLossThbSatang,
    int? fxGainLossThbSatang,
    String? sellFxRate,
    String? buyFxRate,
    int? feeThbSatang,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InvestmentSale(
    id: id ?? this.id,
    sellTransactionId: sellTransactionId ?? this.sellTransactionId,
    lotId: lotId ?? this.lotId,
    sellDate: sellDate ?? this.sellDate,
    quantitySold: quantitySold ?? this.quantitySold,
    sellPriceThbSatang: sellPriceThbSatang ?? this.sellPriceThbSatang,
    costThbSatang: costThbSatang ?? this.costThbSatang,
    realizedGainLossThbSatang:
        realizedGainLossThbSatang ?? this.realizedGainLossThbSatang,
    priceGainLossThbSatang:
        priceGainLossThbSatang ?? this.priceGainLossThbSatang,
    fxGainLossThbSatang: fxGainLossThbSatang ?? this.fxGainLossThbSatang,
    sellFxRate: sellFxRate ?? this.sellFxRate,
    buyFxRate: buyFxRate ?? this.buyFxRate,
    feeThbSatang: feeThbSatang ?? this.feeThbSatang,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InvestmentSale copyWithCompanion(InvestmentSalesCompanion data) {
    return InvestmentSale(
      id: data.id.present ? data.id.value : this.id,
      sellTransactionId: data.sellTransactionId.present
          ? data.sellTransactionId.value
          : this.sellTransactionId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      sellDate: data.sellDate.present ? data.sellDate.value : this.sellDate,
      quantitySold: data.quantitySold.present
          ? data.quantitySold.value
          : this.quantitySold,
      sellPriceThbSatang: data.sellPriceThbSatang.present
          ? data.sellPriceThbSatang.value
          : this.sellPriceThbSatang,
      costThbSatang: data.costThbSatang.present
          ? data.costThbSatang.value
          : this.costThbSatang,
      realizedGainLossThbSatang: data.realizedGainLossThbSatang.present
          ? data.realizedGainLossThbSatang.value
          : this.realizedGainLossThbSatang,
      priceGainLossThbSatang: data.priceGainLossThbSatang.present
          ? data.priceGainLossThbSatang.value
          : this.priceGainLossThbSatang,
      fxGainLossThbSatang: data.fxGainLossThbSatang.present
          ? data.fxGainLossThbSatang.value
          : this.fxGainLossThbSatang,
      sellFxRate: data.sellFxRate.present
          ? data.sellFxRate.value
          : this.sellFxRate,
      buyFxRate: data.buyFxRate.present ? data.buyFxRate.value : this.buyFxRate,
      feeThbSatang: data.feeThbSatang.present
          ? data.feeThbSatang.value
          : this.feeThbSatang,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentSale(')
          ..write('id: $id, ')
          ..write('sellTransactionId: $sellTransactionId, ')
          ..write('lotId: $lotId, ')
          ..write('sellDate: $sellDate, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('sellPriceThbSatang: $sellPriceThbSatang, ')
          ..write('costThbSatang: $costThbSatang, ')
          ..write('realizedGainLossThbSatang: $realizedGainLossThbSatang, ')
          ..write('priceGainLossThbSatang: $priceGainLossThbSatang, ')
          ..write('fxGainLossThbSatang: $fxGainLossThbSatang, ')
          ..write('sellFxRate: $sellFxRate, ')
          ..write('buyFxRate: $buyFxRate, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sellTransactionId,
    lotId,
    sellDate,
    quantitySold,
    sellPriceThbSatang,
    costThbSatang,
    realizedGainLossThbSatang,
    priceGainLossThbSatang,
    fxGainLossThbSatang,
    sellFxRate,
    buyFxRate,
    feeThbSatang,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentSale &&
          other.id == this.id &&
          other.sellTransactionId == this.sellTransactionId &&
          other.lotId == this.lotId &&
          other.sellDate == this.sellDate &&
          other.quantitySold == this.quantitySold &&
          other.sellPriceThbSatang == this.sellPriceThbSatang &&
          other.costThbSatang == this.costThbSatang &&
          other.realizedGainLossThbSatang == this.realizedGainLossThbSatang &&
          other.priceGainLossThbSatang == this.priceGainLossThbSatang &&
          other.fxGainLossThbSatang == this.fxGainLossThbSatang &&
          other.sellFxRate == this.sellFxRate &&
          other.buyFxRate == this.buyFxRate &&
          other.feeThbSatang == this.feeThbSatang &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InvestmentSalesCompanion extends UpdateCompanion<InvestmentSale> {
  final Value<String> id;
  final Value<String> sellTransactionId;
  final Value<String> lotId;
  final Value<DateTime> sellDate;
  final Value<String> quantitySold;
  final Value<int> sellPriceThbSatang;
  final Value<int> costThbSatang;
  final Value<int> realizedGainLossThbSatang;
  final Value<int> priceGainLossThbSatang;
  final Value<int> fxGainLossThbSatang;
  final Value<String> sellFxRate;
  final Value<String> buyFxRate;
  final Value<int> feeThbSatang;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InvestmentSalesCompanion({
    this.id = const Value.absent(),
    this.sellTransactionId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.sellDate = const Value.absent(),
    this.quantitySold = const Value.absent(),
    this.sellPriceThbSatang = const Value.absent(),
    this.costThbSatang = const Value.absent(),
    this.realizedGainLossThbSatang = const Value.absent(),
    this.priceGainLossThbSatang = const Value.absent(),
    this.fxGainLossThbSatang = const Value.absent(),
    this.sellFxRate = const Value.absent(),
    this.buyFxRate = const Value.absent(),
    this.feeThbSatang = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentSalesCompanion.insert({
    required String id,
    required String sellTransactionId,
    required String lotId,
    required DateTime sellDate,
    required String quantitySold,
    required int sellPriceThbSatang,
    required int costThbSatang,
    required int realizedGainLossThbSatang,
    this.priceGainLossThbSatang = const Value.absent(),
    this.fxGainLossThbSatang = const Value.absent(),
    this.sellFxRate = const Value.absent(),
    this.buyFxRate = const Value.absent(),
    required int feeThbSatang,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sellTransactionId = Value(sellTransactionId),
       lotId = Value(lotId),
       sellDate = Value(sellDate),
       quantitySold = Value(quantitySold),
       sellPriceThbSatang = Value(sellPriceThbSatang),
       costThbSatang = Value(costThbSatang),
       realizedGainLossThbSatang = Value(realizedGainLossThbSatang),
       feeThbSatang = Value(feeThbSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InvestmentSale> custom({
    Expression<String>? id,
    Expression<String>? sellTransactionId,
    Expression<String>? lotId,
    Expression<DateTime>? sellDate,
    Expression<String>? quantitySold,
    Expression<int>? sellPriceThbSatang,
    Expression<int>? costThbSatang,
    Expression<int>? realizedGainLossThbSatang,
    Expression<int>? priceGainLossThbSatang,
    Expression<int>? fxGainLossThbSatang,
    Expression<String>? sellFxRate,
    Expression<String>? buyFxRate,
    Expression<int>? feeThbSatang,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sellTransactionId != null) 'sell_transaction_id': sellTransactionId,
      if (lotId != null) 'lot_id': lotId,
      if (sellDate != null) 'sell_date': sellDate,
      if (quantitySold != null) 'quantity_sold': quantitySold,
      if (sellPriceThbSatang != null)
        'sell_price_thb_satang': sellPriceThbSatang,
      if (costThbSatang != null) 'cost_thb_satang': costThbSatang,
      if (realizedGainLossThbSatang != null)
        'realized_gain_loss_thb_satang': realizedGainLossThbSatang,
      if (priceGainLossThbSatang != null)
        'price_gain_loss_thb_satang': priceGainLossThbSatang,
      if (fxGainLossThbSatang != null)
        'fx_gain_loss_thb_satang': fxGainLossThbSatang,
      if (sellFxRate != null) 'sell_fx_rate': sellFxRate,
      if (buyFxRate != null) 'buy_fx_rate': buyFxRate,
      if (feeThbSatang != null) 'fee_thb_satang': feeThbSatang,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentSalesCompanion copyWith({
    Value<String>? id,
    Value<String>? sellTransactionId,
    Value<String>? lotId,
    Value<DateTime>? sellDate,
    Value<String>? quantitySold,
    Value<int>? sellPriceThbSatang,
    Value<int>? costThbSatang,
    Value<int>? realizedGainLossThbSatang,
    Value<int>? priceGainLossThbSatang,
    Value<int>? fxGainLossThbSatang,
    Value<String>? sellFxRate,
    Value<String>? buyFxRate,
    Value<int>? feeThbSatang,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InvestmentSalesCompanion(
      id: id ?? this.id,
      sellTransactionId: sellTransactionId ?? this.sellTransactionId,
      lotId: lotId ?? this.lotId,
      sellDate: sellDate ?? this.sellDate,
      quantitySold: quantitySold ?? this.quantitySold,
      sellPriceThbSatang: sellPriceThbSatang ?? this.sellPriceThbSatang,
      costThbSatang: costThbSatang ?? this.costThbSatang,
      realizedGainLossThbSatang:
          realizedGainLossThbSatang ?? this.realizedGainLossThbSatang,
      priceGainLossThbSatang:
          priceGainLossThbSatang ?? this.priceGainLossThbSatang,
      fxGainLossThbSatang: fxGainLossThbSatang ?? this.fxGainLossThbSatang,
      sellFxRate: sellFxRate ?? this.sellFxRate,
      buyFxRate: buyFxRate ?? this.buyFxRate,
      feeThbSatang: feeThbSatang ?? this.feeThbSatang,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sellTransactionId.present) {
      map['sell_transaction_id'] = Variable<String>(sellTransactionId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (sellDate.present) {
      map['sell_date'] = Variable<DateTime>(sellDate.value);
    }
    if (quantitySold.present) {
      map['quantity_sold'] = Variable<String>(quantitySold.value);
    }
    if (sellPriceThbSatang.present) {
      map['sell_price_thb_satang'] = Variable<int>(sellPriceThbSatang.value);
    }
    if (costThbSatang.present) {
      map['cost_thb_satang'] = Variable<int>(costThbSatang.value);
    }
    if (realizedGainLossThbSatang.present) {
      map['realized_gain_loss_thb_satang'] = Variable<int>(
        realizedGainLossThbSatang.value,
      );
    }
    if (priceGainLossThbSatang.present) {
      map['price_gain_loss_thb_satang'] = Variable<int>(
        priceGainLossThbSatang.value,
      );
    }
    if (fxGainLossThbSatang.present) {
      map['fx_gain_loss_thb_satang'] = Variable<int>(fxGainLossThbSatang.value);
    }
    if (sellFxRate.present) {
      map['sell_fx_rate'] = Variable<String>(sellFxRate.value);
    }
    if (buyFxRate.present) {
      map['buy_fx_rate'] = Variable<String>(buyFxRate.value);
    }
    if (feeThbSatang.present) {
      map['fee_thb_satang'] = Variable<int>(feeThbSatang.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentSalesCompanion(')
          ..write('id: $id, ')
          ..write('sellTransactionId: $sellTransactionId, ')
          ..write('lotId: $lotId, ')
          ..write('sellDate: $sellDate, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('sellPriceThbSatang: $sellPriceThbSatang, ')
          ..write('costThbSatang: $costThbSatang, ')
          ..write('realizedGainLossThbSatang: $realizedGainLossThbSatang, ')
          ..write('priceGainLossThbSatang: $priceGainLossThbSatang, ')
          ..write('fxGainLossThbSatang: $fxGainLossThbSatang, ')
          ..write('sellFxRate: $sellFxRate, ')
          ..write('buyFxRate: $buyFxRate, ')
          ..write('feeThbSatang: $feeThbSatang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetPricesTable extends AssetPrices
    with TableInfo<$AssetPricesTable, AssetPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceDateMeta = const VerificationMeta(
    'priceDate',
  );
  @override
  late final GeneratedColumn<DateTime> priceDate = GeneratedColumn<DateTime>(
    'price_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketPriceOriginalSatangMeta =
      const VerificationMeta('marketPriceOriginalSatang');
  @override
  late final GeneratedColumn<int> marketPriceOriginalSatang =
      GeneratedColumn<int>(
        'market_price_original_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<String> fxRate = GeneratedColumn<String>(
    'fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketPriceThbSatangMeta =
      const VerificationMeta('marketPriceThbSatang');
  @override
  late final GeneratedColumn<int> marketPriceThbSatang = GeneratedColumn<int>(
    'market_price_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    priceDate,
    marketPriceOriginalSatang,
    fxRate,
    marketPriceThbSatang,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('price_date')) {
      context.handle(
        _priceDateMeta,
        priceDate.isAcceptableOrUnknown(data['price_date']!, _priceDateMeta),
      );
    } else if (isInserting) {
      context.missing(_priceDateMeta);
    }
    if (data.containsKey('market_price_original_satang')) {
      context.handle(
        _marketPriceOriginalSatangMeta,
        marketPriceOriginalSatang.isAcceptableOrUnknown(
          data['market_price_original_satang']!,
          _marketPriceOriginalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marketPriceOriginalSatangMeta);
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    } else if (isInserting) {
      context.missing(_fxRateMeta);
    }
    if (data.containsKey('market_price_thb_satang')) {
      context.handle(
        _marketPriceThbSatangMeta,
        marketPriceThbSatang.isAcceptableOrUnknown(
          data['market_price_thb_satang']!,
          _marketPriceThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marketPriceThbSatangMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      priceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}price_date'],
      )!,
      marketPriceOriginalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}market_price_original_satang'],
      )!,
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fx_rate'],
      )!,
      marketPriceThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}market_price_thb_satang'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AssetPricesTable createAlias(String alias) {
    return $AssetPricesTable(attachedDatabase, alias);
  }
}

class AssetPrice extends DataClass implements Insertable<AssetPrice> {
  final String id;
  final String assetId;
  final DateTime priceDate;
  final int marketPriceOriginalSatang;
  final String fxRate;
  final int marketPriceThbSatang;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AssetPrice({
    required this.id,
    required this.assetId,
    required this.priceDate,
    required this.marketPriceOriginalSatang,
    required this.fxRate,
    required this.marketPriceThbSatang,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['price_date'] = Variable<DateTime>(priceDate);
    map['market_price_original_satang'] = Variable<int>(
      marketPriceOriginalSatang,
    );
    map['fx_rate'] = Variable<String>(fxRate);
    map['market_price_thb_satang'] = Variable<int>(marketPriceThbSatang);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AssetPricesCompanion toCompanion(bool nullToAbsent) {
    return AssetPricesCompanion(
      id: Value(id),
      assetId: Value(assetId),
      priceDate: Value(priceDate),
      marketPriceOriginalSatang: Value(marketPriceOriginalSatang),
      fxRate: Value(fxRate),
      marketPriceThbSatang: Value(marketPriceThbSatang),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AssetPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetPrice(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      priceDate: serializer.fromJson<DateTime>(json['priceDate']),
      marketPriceOriginalSatang: serializer.fromJson<int>(
        json['marketPriceOriginalSatang'],
      ),
      fxRate: serializer.fromJson<String>(json['fxRate']),
      marketPriceThbSatang: serializer.fromJson<int>(
        json['marketPriceThbSatang'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'priceDate': serializer.toJson<DateTime>(priceDate),
      'marketPriceOriginalSatang': serializer.toJson<int>(
        marketPriceOriginalSatang,
      ),
      'fxRate': serializer.toJson<String>(fxRate),
      'marketPriceThbSatang': serializer.toJson<int>(marketPriceThbSatang),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AssetPrice copyWith({
    String? id,
    String? assetId,
    DateTime? priceDate,
    int? marketPriceOriginalSatang,
    String? fxRate,
    int? marketPriceThbSatang,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AssetPrice(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    priceDate: priceDate ?? this.priceDate,
    marketPriceOriginalSatang:
        marketPriceOriginalSatang ?? this.marketPriceOriginalSatang,
    fxRate: fxRate ?? this.fxRate,
    marketPriceThbSatang: marketPriceThbSatang ?? this.marketPriceThbSatang,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AssetPrice copyWithCompanion(AssetPricesCompanion data) {
    return AssetPrice(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      priceDate: data.priceDate.present ? data.priceDate.value : this.priceDate,
      marketPriceOriginalSatang: data.marketPriceOriginalSatang.present
          ? data.marketPriceOriginalSatang.value
          : this.marketPriceOriginalSatang,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      marketPriceThbSatang: data.marketPriceThbSatang.present
          ? data.marketPriceThbSatang.value
          : this.marketPriceThbSatang,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetPrice(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('priceDate: $priceDate, ')
          ..write('marketPriceOriginalSatang: $marketPriceOriginalSatang, ')
          ..write('fxRate: $fxRate, ')
          ..write('marketPriceThbSatang: $marketPriceThbSatang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    priceDate,
    marketPriceOriginalSatang,
    fxRate,
    marketPriceThbSatang,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetPrice &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.priceDate == this.priceDate &&
          other.marketPriceOriginalSatang == this.marketPriceOriginalSatang &&
          other.fxRate == this.fxRate &&
          other.marketPriceThbSatang == this.marketPriceThbSatang &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AssetPricesCompanion extends UpdateCompanion<AssetPrice> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<DateTime> priceDate;
  final Value<int> marketPriceOriginalSatang;
  final Value<String> fxRate;
  final Value<int> marketPriceThbSatang;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AssetPricesCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.priceDate = const Value.absent(),
    this.marketPriceOriginalSatang = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.marketPriceThbSatang = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetPricesCompanion.insert({
    required String id,
    required String assetId,
    required DateTime priceDate,
    required int marketPriceOriginalSatang,
    required String fxRate,
    required int marketPriceThbSatang,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assetId = Value(assetId),
       priceDate = Value(priceDate),
       marketPriceOriginalSatang = Value(marketPriceOriginalSatang),
       fxRate = Value(fxRate),
       marketPriceThbSatang = Value(marketPriceThbSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssetPrice> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<DateTime>? priceDate,
    Expression<int>? marketPriceOriginalSatang,
    Expression<String>? fxRate,
    Expression<int>? marketPriceThbSatang,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (priceDate != null) 'price_date': priceDate,
      if (marketPriceOriginalSatang != null)
        'market_price_original_satang': marketPriceOriginalSatang,
      if (fxRate != null) 'fx_rate': fxRate,
      if (marketPriceThbSatang != null)
        'market_price_thb_satang': marketPriceThbSatang,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetPricesCompanion copyWith({
    Value<String>? id,
    Value<String>? assetId,
    Value<DateTime>? priceDate,
    Value<int>? marketPriceOriginalSatang,
    Value<String>? fxRate,
    Value<int>? marketPriceThbSatang,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AssetPricesCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      priceDate: priceDate ?? this.priceDate,
      marketPriceOriginalSatang:
          marketPriceOriginalSatang ?? this.marketPriceOriginalSatang,
      fxRate: fxRate ?? this.fxRate,
      marketPriceThbSatang: marketPriceThbSatang ?? this.marketPriceThbSatang,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (priceDate.present) {
      map['price_date'] = Variable<DateTime>(priceDate.value);
    }
    if (marketPriceOriginalSatang.present) {
      map['market_price_original_satang'] = Variable<int>(
        marketPriceOriginalSatang.value,
      );
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(fxRate.value);
    }
    if (marketPriceThbSatang.present) {
      map['market_price_thb_satang'] = Variable<int>(
        marketPriceThbSatang.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetPricesCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('priceDate: $priceDate, ')
          ..write('marketPriceOriginalSatang: $marketPriceOriginalSatang, ')
          ..write('fxRate: $fxRate, ')
          ..write('marketPriceThbSatang: $marketPriceThbSatang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitSatangMeta = const VerificationMeta(
    'limitSatang',
  );
  @override
  late final GeneratedColumn<int> limitSatang = GeneratedColumn<int>(
    'limit_satang',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    limitSatang,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('limit_satang')) {
      context.handle(
        _limitSatangMeta,
        limitSatang.isAcceptableOrUnknown(
          data['limit_satang']!,
          _limitSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitSatangMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      limitSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_satang'],
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String categoryId;
  final int limitSatang;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitSatang,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['limit_satang'] = Variable<int>(limitSatang);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitSatang: Value(limitSatang),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      limitSatang: serializer.fromJson<int>(json['limitSatang']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'limitSatang': serializer.toJson<int>(limitSatang),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    int? limitSatang,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Budget(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    limitSatang: limitSatang ?? this.limitSatang,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitSatang: data.limitSatang.present
          ? data.limitSatang.value
          : this.limitSatang,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitSatang: $limitSatang, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    limitSatang,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.limitSatang == this.limitSatang &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<int> limitSatang;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitSatang = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    required int limitSatang,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       limitSatang = Value(limitSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<int>? limitSatang,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (limitSatang != null) 'limit_satang': limitSatang,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<int>? limitSatang,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitSatang: limitSatang ?? this.limitSatang,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (limitSatang.present) {
      map['limit_satang'] = Variable<int>(limitSatang.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitSatang: $limitSatang, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountSatangMeta = const VerificationMeta(
    'amountSatang',
  );
  @override
  late final GeneratedColumn<int> amountSatang = GeneratedColumn<int>(
    'amount_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRunDateMeta = const VerificationMeta(
    'nextRunDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextRunDate = GeneratedColumn<DateTime>(
    'next_run_date',
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
  static const VerificationMeta _intervalUnitsMeta = const VerificationMeta(
    'intervalUnits',
  );
  @override
  late final GeneratedColumn<int> intervalUnits = GeneratedColumn<int>(
    'interval_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _autoPostMeta = const VerificationMeta(
    'autoPost',
  );
  @override
  late final GeneratedColumn<bool> autoPost = GeneratedColumn<bool>(
    'auto_post',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_post" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastPostedDateMeta = const VerificationMeta(
    'lastPostedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPostedDate =
      GeneratedColumn<DateTime>(
        'last_posted_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    transactionType,
    sourceAccountId,
    destinationAccountId,
    categoryId,
    amountSatang,
    currencyCode,
    frequency,
    dayOfMonth,
    nextRunDate,
    endDate,
    isActive,
    intervalUnits,
    autoPost,
    lastPostedDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount_satang')) {
      context.handle(
        _amountSatangMeta,
        amountSatang.isAcceptableOrUnknown(
          data['amount_satang']!,
          _amountSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountSatangMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('next_run_date')) {
      context.handle(
        _nextRunDateMeta,
        nextRunDate.isAcceptableOrUnknown(
          data['next_run_date']!,
          _nextRunDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextRunDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('interval_units')) {
      context.handle(
        _intervalUnitsMeta,
        intervalUnits.isAcceptableOrUnknown(
          data['interval_units']!,
          _intervalUnitsMeta,
        ),
      );
    }
    if (data.containsKey('auto_post')) {
      context.handle(
        _autoPostMeta,
        autoPost.isAcceptableOrUnknown(data['auto_post']!, _autoPostMeta),
      );
    }
    if (data.containsKey('last_posted_date')) {
      context.handle(
        _lastPostedDateMeta,
        lastPostedDate.isAcceptableOrUnknown(
          data['last_posted_date']!,
          _lastPostedDateMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      amountSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_satang'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      ),
      nextRunDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_run_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      intervalUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_units'],
      )!,
      autoPost: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_post'],
      )!,
      lastPostedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_posted_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final String id;
  final String title;
  final String transactionType;
  final String sourceAccountId;
  final String? destinationAccountId;
  final String? categoryId;
  final int amountSatang;
  final String currencyCode;
  final String frequency;
  final int? dayOfMonth;
  final DateTime nextRunDate;
  final DateTime? endDate;
  final bool isActive;
  final int intervalUnits;
  final bool autoPost;
  final DateTime? lastPostedDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const RecurringRule({
    required this.id,
    required this.title,
    required this.transactionType,
    required this.sourceAccountId,
    this.destinationAccountId,
    this.categoryId,
    required this.amountSatang,
    required this.currencyCode,
    required this.frequency,
    this.dayOfMonth,
    required this.nextRunDate,
    this.endDate,
    required this.isActive,
    required this.intervalUnits,
    required this.autoPost,
    this.lastPostedDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['transaction_type'] = Variable<String>(transactionType);
    map['source_account_id'] = Variable<String>(sourceAccountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount_satang'] = Variable<int>(amountSatang);
    map['currency_code'] = Variable<String>(currencyCode);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    map['next_run_date'] = Variable<DateTime>(nextRunDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['interval_units'] = Variable<int>(intervalUnits);
    map['auto_post'] = Variable<bool>(autoPost);
    if (!nullToAbsent || lastPostedDate != null) {
      map['last_posted_date'] = Variable<DateTime>(lastPostedDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      title: Value(title),
      transactionType: Value(transactionType),
      sourceAccountId: Value(sourceAccountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountSatang: Value(amountSatang),
      currencyCode: Value(currencyCode),
      frequency: Value(frequency),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      nextRunDate: Value(nextRunDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      intervalUnits: Value(intervalUnits),
      autoPost: Value(autoPost),
      lastPostedDate: lastPostedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostedDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amountSatang: serializer.fromJson<int>(json['amountSatang']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      frequency: serializer.fromJson<String>(json['frequency']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      nextRunDate: serializer.fromJson<DateTime>(json['nextRunDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      intervalUnits: serializer.fromJson<int>(json['intervalUnits']),
      autoPost: serializer.fromJson<bool>(json['autoPost']),
      lastPostedDate: serializer.fromJson<DateTime?>(json['lastPostedDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'transactionType': serializer.toJson<String>(transactionType),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amountSatang': serializer.toJson<int>(amountSatang),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'frequency': serializer.toJson<String>(frequency),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'nextRunDate': serializer.toJson<DateTime>(nextRunDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'intervalUnits': serializer.toJson<int>(intervalUnits),
      'autoPost': serializer.toJson<bool>(autoPost),
      'lastPostedDate': serializer.toJson<DateTime?>(lastPostedDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RecurringRule copyWith({
    String? id,
    String? title,
    String? transactionType,
    String? sourceAccountId,
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    int? amountSatang,
    String? currencyCode,
    String? frequency,
    Value<int?> dayOfMonth = const Value.absent(),
    DateTime? nextRunDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    int? intervalUnits,
    bool? autoPost,
    Value<DateTime?> lastPostedDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RecurringRule(
    id: id ?? this.id,
    title: title ?? this.title,
    transactionType: transactionType ?? this.transactionType,
    sourceAccountId: sourceAccountId ?? this.sourceAccountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amountSatang: amountSatang ?? this.amountSatang,
    currencyCode: currencyCode ?? this.currencyCode,
    frequency: frequency ?? this.frequency,
    dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
    nextRunDate: nextRunDate ?? this.nextRunDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    intervalUnits: intervalUnits ?? this.intervalUnits,
    autoPost: autoPost ?? this.autoPost,
    lastPostedDate: lastPostedDate.present
        ? lastPostedDate.value
        : this.lastPostedDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountSatang: data.amountSatang.present
          ? data.amountSatang.value
          : this.amountSatang,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      nextRunDate: data.nextRunDate.present
          ? data.nextRunDate.value
          : this.nextRunDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      intervalUnits: data.intervalUnits.present
          ? data.intervalUnits.value
          : this.intervalUnits,
      autoPost: data.autoPost.present ? data.autoPost.value : this.autoPost,
      lastPostedDate: data.lastPostedDate.present
          ? data.lastPostedDate.value
          : this.lastPostedDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('transactionType: $transactionType, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountSatang: $amountSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('intervalUnits: $intervalUnits, ')
          ..write('autoPost: $autoPost, ')
          ..write('lastPostedDate: $lastPostedDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    transactionType,
    sourceAccountId,
    destinationAccountId,
    categoryId,
    amountSatang,
    currencyCode,
    frequency,
    dayOfMonth,
    nextRunDate,
    endDate,
    isActive,
    intervalUnits,
    autoPost,
    lastPostedDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.title == this.title &&
          other.transactionType == this.transactionType &&
          other.sourceAccountId == this.sourceAccountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.categoryId == this.categoryId &&
          other.amountSatang == this.amountSatang &&
          other.currencyCode == this.currencyCode &&
          other.frequency == this.frequency &&
          other.dayOfMonth == this.dayOfMonth &&
          other.nextRunDate == this.nextRunDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.intervalUnits == this.intervalUnits &&
          other.autoPost == this.autoPost &&
          other.lastPostedDate == this.lastPostedDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> transactionType;
  final Value<String> sourceAccountId;
  final Value<String?> destinationAccountId;
  final Value<String?> categoryId;
  final Value<int> amountSatang;
  final Value<String> currencyCode;
  final Value<String> frequency;
  final Value<int?> dayOfMonth;
  final Value<DateTime> nextRunDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> intervalUnits;
  final Value<bool> autoPost;
  final Value<DateTime?> lastPostedDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountSatang = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.frequency = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.nextRunDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.intervalUnits = const Value.absent(),
    this.autoPost = const Value.absent(),
    this.lastPostedDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required String title,
    required String transactionType,
    required String sourceAccountId,
    this.destinationAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int amountSatang,
    required String currencyCode,
    required String frequency,
    this.dayOfMonth = const Value.absent(),
    required DateTime nextRunDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.intervalUnits = const Value.absent(),
    this.autoPost = const Value.absent(),
    this.lastPostedDate = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       transactionType = Value(transactionType),
       sourceAccountId = Value(sourceAccountId),
       amountSatang = Value(amountSatang),
       currencyCode = Value(currencyCode),
       frequency = Value(frequency),
       nextRunDate = Value(nextRunDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringRule> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? transactionType,
    Expression<String>? sourceAccountId,
    Expression<String>? destinationAccountId,
    Expression<String>? categoryId,
    Expression<int>? amountSatang,
    Expression<String>? currencyCode,
    Expression<String>? frequency,
    Expression<int>? dayOfMonth,
    Expression<DateTime>? nextRunDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<int>? intervalUnits,
    Expression<bool>? autoPost,
    Expression<DateTime>? lastPostedDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (transactionType != null) 'transaction_type': transactionType,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amountSatang != null) 'amount_satang': amountSatang,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (frequency != null) 'frequency': frequency,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (nextRunDate != null) 'next_run_date': nextRunDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (intervalUnits != null) 'interval_units': intervalUnits,
      if (autoPost != null) 'auto_post': autoPost,
      if (lastPostedDate != null) 'last_posted_date': lastPostedDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? transactionType,
    Value<String>? sourceAccountId,
    Value<String?>? destinationAccountId,
    Value<String?>? categoryId,
    Value<int>? amountSatang,
    Value<String>? currencyCode,
    Value<String>? frequency,
    Value<int?>? dayOfMonth,
    Value<DateTime>? nextRunDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? intervalUnits,
    Value<bool>? autoPost,
    Value<DateTime?>? lastPostedDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      transactionType: transactionType ?? this.transactionType,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      amountSatang: amountSatang ?? this.amountSatang,
      currencyCode: currencyCode ?? this.currencyCode,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      intervalUnits: intervalUnits ?? this.intervalUnits,
      autoPost: autoPost ?? this.autoPost,
      lastPostedDate: lastPostedDate ?? this.lastPostedDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountSatang.present) {
      map['amount_satang'] = Variable<int>(amountSatang.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (nextRunDate.present) {
      map['next_run_date'] = Variable<DateTime>(nextRunDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (intervalUnits.present) {
      map['interval_units'] = Variable<int>(intervalUnits.value);
    }
    if (autoPost.present) {
      map['auto_post'] = Variable<bool>(autoPost.value);
    }
    if (lastPostedDate.present) {
      map['last_posted_date'] = Variable<DateTime>(lastPostedDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('transactionType: $transactionType, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountSatang: $amountSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('frequency: $frequency, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('intervalUnits: $intervalUnits, ')
          ..write('autoPost: $autoPost, ')
          ..write('lastPostedDate: $lastPostedDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxDeductionsTable extends TaxDeductions
    with TableInfo<$TaxDeductionsTable, TaxDeduction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxDeductionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxYearMeta = const VerificationMeta(
    'taxYear',
  );
  @override
  late final GeneratedColumn<int> taxYear = GeneratedColumn<int>(
    'tax_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deductionGroupMeta = const VerificationMeta(
    'deductionGroup',
  );
  @override
  late final GeneratedColumn<String> deductionGroup = GeneratedColumn<String>(
    'deduction_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deductionTypeMeta = const VerificationMeta(
    'deductionType',
  );
  @override
  late final GeneratedColumn<String> deductionType = GeneratedColumn<String>(
    'deduction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountSatangMeta = const VerificationMeta(
    'amountSatang',
  );
  @override
  late final GeneratedColumn<int> amountSatang = GeneratedColumn<int>(
    'amount_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taxYear,
    deductionGroup,
    deductionType,
    amountSatang,
    transactionId,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_deductions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxDeduction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tax_year')) {
      context.handle(
        _taxYearMeta,
        taxYear.isAcceptableOrUnknown(data['tax_year']!, _taxYearMeta),
      );
    } else if (isInserting) {
      context.missing(_taxYearMeta);
    }
    if (data.containsKey('deduction_group')) {
      context.handle(
        _deductionGroupMeta,
        deductionGroup.isAcceptableOrUnknown(
          data['deduction_group']!,
          _deductionGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deductionGroupMeta);
    }
    if (data.containsKey('deduction_type')) {
      context.handle(
        _deductionTypeMeta,
        deductionType.isAcceptableOrUnknown(
          data['deduction_type']!,
          _deductionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deductionTypeMeta);
    }
    if (data.containsKey('amount_satang')) {
      context.handle(
        _amountSatangMeta,
        amountSatang.isAcceptableOrUnknown(
          data['amount_satang']!,
          _amountSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountSatangMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxDeduction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxDeduction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taxYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_year'],
      )!,
      deductionGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deduction_group'],
      )!,
      deductionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deduction_type'],
      )!,
      amountSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_satang'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TaxDeductionsTable createAlias(String alias) {
    return $TaxDeductionsTable(attachedDatabase, alias);
  }
}

class TaxDeduction extends DataClass implements Insertable<TaxDeduction> {
  final String id;
  final int taxYear;
  final String deductionGroup;
  final String deductionType;
  final int amountSatang;
  final String? transactionId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaxDeduction({
    required this.id,
    required this.taxYear,
    required this.deductionGroup,
    required this.deductionType,
    required this.amountSatang,
    this.transactionId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tax_year'] = Variable<int>(taxYear);
    map['deduction_group'] = Variable<String>(deductionGroup);
    map['deduction_type'] = Variable<String>(deductionType);
    map['amount_satang'] = Variable<int>(amountSatang);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaxDeductionsCompanion toCompanion(bool nullToAbsent) {
    return TaxDeductionsCompanion(
      id: Value(id),
      taxYear: Value(taxYear),
      deductionGroup: Value(deductionGroup),
      deductionType: Value(deductionType),
      amountSatang: Value(amountSatang),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaxDeduction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxDeduction(
      id: serializer.fromJson<String>(json['id']),
      taxYear: serializer.fromJson<int>(json['taxYear']),
      deductionGroup: serializer.fromJson<String>(json['deductionGroup']),
      deductionType: serializer.fromJson<String>(json['deductionType']),
      amountSatang: serializer.fromJson<int>(json['amountSatang']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taxYear': serializer.toJson<int>(taxYear),
      'deductionGroup': serializer.toJson<String>(deductionGroup),
      'deductionType': serializer.toJson<String>(deductionType),
      'amountSatang': serializer.toJson<int>(amountSatang),
      'transactionId': serializer.toJson<String?>(transactionId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaxDeduction copyWith({
    String? id,
    int? taxYear,
    String? deductionGroup,
    String? deductionType,
    int? amountSatang,
    Value<String?> transactionId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaxDeduction(
    id: id ?? this.id,
    taxYear: taxYear ?? this.taxYear,
    deductionGroup: deductionGroup ?? this.deductionGroup,
    deductionType: deductionType ?? this.deductionType,
    amountSatang: amountSatang ?? this.amountSatang,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaxDeduction copyWithCompanion(TaxDeductionsCompanion data) {
    return TaxDeduction(
      id: data.id.present ? data.id.value : this.id,
      taxYear: data.taxYear.present ? data.taxYear.value : this.taxYear,
      deductionGroup: data.deductionGroup.present
          ? data.deductionGroup.value
          : this.deductionGroup,
      deductionType: data.deductionType.present
          ? data.deductionType.value
          : this.deductionType,
      amountSatang: data.amountSatang.present
          ? data.amountSatang.value
          : this.amountSatang,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxDeduction(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('deductionGroup: $deductionGroup, ')
          ..write('deductionType: $deductionType, ')
          ..write('amountSatang: $amountSatang, ')
          ..write('transactionId: $transactionId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taxYear,
    deductionGroup,
    deductionType,
    amountSatang,
    transactionId,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxDeduction &&
          other.id == this.id &&
          other.taxYear == this.taxYear &&
          other.deductionGroup == this.deductionGroup &&
          other.deductionType == this.deductionType &&
          other.amountSatang == this.amountSatang &&
          other.transactionId == this.transactionId &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaxDeductionsCompanion extends UpdateCompanion<TaxDeduction> {
  final Value<String> id;
  final Value<int> taxYear;
  final Value<String> deductionGroup;
  final Value<String> deductionType;
  final Value<int> amountSatang;
  final Value<String?> transactionId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TaxDeductionsCompanion({
    this.id = const Value.absent(),
    this.taxYear = const Value.absent(),
    this.deductionGroup = const Value.absent(),
    this.deductionType = const Value.absent(),
    this.amountSatang = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxDeductionsCompanion.insert({
    required String id,
    required int taxYear,
    required String deductionGroup,
    required String deductionType,
    required int amountSatang,
    this.transactionId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taxYear = Value(taxYear),
       deductionGroup = Value(deductionGroup),
       deductionType = Value(deductionType),
       amountSatang = Value(amountSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaxDeduction> custom({
    Expression<String>? id,
    Expression<int>? taxYear,
    Expression<String>? deductionGroup,
    Expression<String>? deductionType,
    Expression<int>? amountSatang,
    Expression<String>? transactionId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxYear != null) 'tax_year': taxYear,
      if (deductionGroup != null) 'deduction_group': deductionGroup,
      if (deductionType != null) 'deduction_type': deductionType,
      if (amountSatang != null) 'amount_satang': amountSatang,
      if (transactionId != null) 'transaction_id': transactionId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxDeductionsCompanion copyWith({
    Value<String>? id,
    Value<int>? taxYear,
    Value<String>? deductionGroup,
    Value<String>? deductionType,
    Value<int>? amountSatang,
    Value<String?>? transactionId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TaxDeductionsCompanion(
      id: id ?? this.id,
      taxYear: taxYear ?? this.taxYear,
      deductionGroup: deductionGroup ?? this.deductionGroup,
      deductionType: deductionType ?? this.deductionType,
      amountSatang: amountSatang ?? this.amountSatang,
      transactionId: transactionId ?? this.transactionId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taxYear.present) {
      map['tax_year'] = Variable<int>(taxYear.value);
    }
    if (deductionGroup.present) {
      map['deduction_group'] = Variable<String>(deductionGroup.value);
    }
    if (deductionType.present) {
      map['deduction_type'] = Variable<String>(deductionType.value);
    }
    if (amountSatang.present) {
      map['amount_satang'] = Variable<int>(amountSatang.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxDeductionsCompanion(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('deductionGroup: $deductionGroup, ')
          ..write('deductionType: $deductionType, ')
          ..write('amountSatang: $amountSatang, ')
          ..write('transactionId: $transactionId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ForeignRemittancesTable extends ForeignRemittances
    with TableInfo<$ForeignRemittancesTable, ForeignRemittance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForeignRemittancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remittanceTransactionIdMeta =
      const VerificationMeta('remittanceTransactionId');
  @override
  late final GeneratedColumn<String> remittanceTransactionId =
      GeneratedColumn<String>(
        'remittance_transaction_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceAccountIdMeta = const VerificationMeta(
    'sourceAccountId',
  );
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
    'source_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _taxYearEarnedMeta = const VerificationMeta(
    'taxYearEarned',
  );
  @override
  late final GeneratedColumn<int> taxYearEarned = GeneratedColumn<int>(
    'tax_year_earned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxYearRemittedMeta = const VerificationMeta(
    'taxYearRemitted',
  );
  @override
  late final GeneratedColumn<int> taxYearRemitted = GeneratedColumn<int>(
    'tax_year_remitted',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remittanceDateMeta = const VerificationMeta(
    'remittanceDate',
  );
  @override
  late final GeneratedColumn<DateTime> remittanceDate =
      GeneratedColumn<DateTime>(
        'remittance_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _incomeSourceTypeMeta = const VerificationMeta(
    'incomeSourceType',
  );
  @override
  late final GeneratedColumn<String> incomeSourceType = GeneratedColumn<String>(
    'income_source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('capital_gain'),
  );
  static const VerificationMeta _isPrincipalMeta = const VerificationMeta(
    'isPrincipal',
  );
  @override
  late final GeneratedColumn<bool> isPrincipal = GeneratedColumn<bool>(
    'is_principal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_principal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _amountOriginalSatangMeta =
      const VerificationMeta('amountOriginalSatang');
  @override
  late final GeneratedColumn<int> amountOriginalSatang = GeneratedColumn<int>(
    'amount_original_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<String> fxRate = GeneratedColumn<String>(
    'fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountThbSatangMeta = const VerificationMeta(
    'amountThbSatang',
  );
  @override
  late final GeneratedColumn<int> amountThbSatang = GeneratedColumn<int>(
    'amount_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTaxableMeta = const VerificationMeta(
    'isTaxable',
  );
  @override
  late final GeneratedColumn<bool> isTaxable = GeneratedColumn<bool>(
    'is_taxable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_taxable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _taxableReasonMeta = const VerificationMeta(
    'taxableReason',
  );
  @override
  late final GeneratedColumn<String> taxableReason = GeneratedColumn<String>(
    'taxable_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remittanceTransactionId,
    sourceAccountId,
    destinationAccountId,
    taxYearEarned,
    taxYearRemitted,
    remittanceDate,
    incomeSourceType,
    isPrincipal,
    amountOriginalSatang,
    currencyCode,
    fxRate,
    amountThbSatang,
    isTaxable,
    taxableReason,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foreign_remittances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ForeignRemittance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remittance_transaction_id')) {
      context.handle(
        _remittanceTransactionIdMeta,
        remittanceTransactionId.isAcceptableOrUnknown(
          data['remittance_transaction_id']!,
          _remittanceTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remittanceTransactionIdMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
        _sourceAccountIdMeta,
        sourceAccountId.isAcceptableOrUnknown(
          data['source_account_id']!,
          _sourceAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('tax_year_earned')) {
      context.handle(
        _taxYearEarnedMeta,
        taxYearEarned.isAcceptableOrUnknown(
          data['tax_year_earned']!,
          _taxYearEarnedMeta,
        ),
      );
    }
    if (data.containsKey('tax_year_remitted')) {
      context.handle(
        _taxYearRemittedMeta,
        taxYearRemitted.isAcceptableOrUnknown(
          data['tax_year_remitted']!,
          _taxYearRemittedMeta,
        ),
      );
    }
    if (data.containsKey('remittance_date')) {
      context.handle(
        _remittanceDateMeta,
        remittanceDate.isAcceptableOrUnknown(
          data['remittance_date']!,
          _remittanceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remittanceDateMeta);
    }
    if (data.containsKey('income_source_type')) {
      context.handle(
        _incomeSourceTypeMeta,
        incomeSourceType.isAcceptableOrUnknown(
          data['income_source_type']!,
          _incomeSourceTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_principal')) {
      context.handle(
        _isPrincipalMeta,
        isPrincipal.isAcceptableOrUnknown(
          data['is_principal']!,
          _isPrincipalMeta,
        ),
      );
    }
    if (data.containsKey('amount_original_satang')) {
      context.handle(
        _amountOriginalSatangMeta,
        amountOriginalSatang.isAcceptableOrUnknown(
          data['amount_original_satang']!,
          _amountOriginalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountOriginalSatangMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    } else if (isInserting) {
      context.missing(_fxRateMeta);
    }
    if (data.containsKey('amount_thb_satang')) {
      context.handle(
        _amountThbSatangMeta,
        amountThbSatang.isAcceptableOrUnknown(
          data['amount_thb_satang']!,
          _amountThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountThbSatangMeta);
    }
    if (data.containsKey('is_taxable')) {
      context.handle(
        _isTaxableMeta,
        isTaxable.isAcceptableOrUnknown(data['is_taxable']!, _isTaxableMeta),
      );
    }
    if (data.containsKey('taxable_reason')) {
      context.handle(
        _taxableReasonMeta,
        taxableReason.isAcceptableOrUnknown(
          data['taxable_reason']!,
          _taxableReasonMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ForeignRemittance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ForeignRemittance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remittanceTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remittance_transaction_id'],
      )!,
      sourceAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      taxYearEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_year_earned'],
      ),
      taxYearRemitted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_year_remitted'],
      ),
      remittanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remittance_date'],
      )!,
      incomeSourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_source_type'],
      )!,
      isPrincipal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_principal'],
      )!,
      amountOriginalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_original_satang'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fx_rate'],
      )!,
      amountThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_thb_satang'],
      )!,
      isTaxable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_taxable'],
      )!,
      taxableReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxable_reason'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ForeignRemittancesTable createAlias(String alias) {
    return $ForeignRemittancesTable(attachedDatabase, alias);
  }
}

class ForeignRemittance extends DataClass
    implements Insertable<ForeignRemittance> {
  final String id;
  final String remittanceTransactionId;
  final String sourceAccountId;
  final String? destinationAccountId;
  final int? taxYearEarned;
  final int? taxYearRemitted;
  final DateTime remittanceDate;
  final String incomeSourceType;
  final bool isPrincipal;
  final int amountOriginalSatang;
  final String currencyCode;
  final String fxRate;
  final int amountThbSatang;
  final bool isTaxable;
  final String? taxableReason;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ForeignRemittance({
    required this.id,
    required this.remittanceTransactionId,
    required this.sourceAccountId,
    this.destinationAccountId,
    this.taxYearEarned,
    this.taxYearRemitted,
    required this.remittanceDate,
    required this.incomeSourceType,
    required this.isPrincipal,
    required this.amountOriginalSatang,
    required this.currencyCode,
    required this.fxRate,
    required this.amountThbSatang,
    required this.isTaxable,
    this.taxableReason,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['remittance_transaction_id'] = Variable<String>(
      remittanceTransactionId,
    );
    map['source_account_id'] = Variable<String>(sourceAccountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || taxYearEarned != null) {
      map['tax_year_earned'] = Variable<int>(taxYearEarned);
    }
    if (!nullToAbsent || taxYearRemitted != null) {
      map['tax_year_remitted'] = Variable<int>(taxYearRemitted);
    }
    map['remittance_date'] = Variable<DateTime>(remittanceDate);
    map['income_source_type'] = Variable<String>(incomeSourceType);
    map['is_principal'] = Variable<bool>(isPrincipal);
    map['amount_original_satang'] = Variable<int>(amountOriginalSatang);
    map['currency_code'] = Variable<String>(currencyCode);
    map['fx_rate'] = Variable<String>(fxRate);
    map['amount_thb_satang'] = Variable<int>(amountThbSatang);
    map['is_taxable'] = Variable<bool>(isTaxable);
    if (!nullToAbsent || taxableReason != null) {
      map['taxable_reason'] = Variable<String>(taxableReason);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ForeignRemittancesCompanion toCompanion(bool nullToAbsent) {
    return ForeignRemittancesCompanion(
      id: Value(id),
      remittanceTransactionId: Value(remittanceTransactionId),
      sourceAccountId: Value(sourceAccountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      taxYearEarned: taxYearEarned == null && nullToAbsent
          ? const Value.absent()
          : Value(taxYearEarned),
      taxYearRemitted: taxYearRemitted == null && nullToAbsent
          ? const Value.absent()
          : Value(taxYearRemitted),
      remittanceDate: Value(remittanceDate),
      incomeSourceType: Value(incomeSourceType),
      isPrincipal: Value(isPrincipal),
      amountOriginalSatang: Value(amountOriginalSatang),
      currencyCode: Value(currencyCode),
      fxRate: Value(fxRate),
      amountThbSatang: Value(amountThbSatang),
      isTaxable: Value(isTaxable),
      taxableReason: taxableReason == null && nullToAbsent
          ? const Value.absent()
          : Value(taxableReason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ForeignRemittance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ForeignRemittance(
      id: serializer.fromJson<String>(json['id']),
      remittanceTransactionId: serializer.fromJson<String>(
        json['remittanceTransactionId'],
      ),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      taxYearEarned: serializer.fromJson<int?>(json['taxYearEarned']),
      taxYearRemitted: serializer.fromJson<int?>(json['taxYearRemitted']),
      remittanceDate: serializer.fromJson<DateTime>(json['remittanceDate']),
      incomeSourceType: serializer.fromJson<String>(json['incomeSourceType']),
      isPrincipal: serializer.fromJson<bool>(json['isPrincipal']),
      amountOriginalSatang: serializer.fromJson<int>(
        json['amountOriginalSatang'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      fxRate: serializer.fromJson<String>(json['fxRate']),
      amountThbSatang: serializer.fromJson<int>(json['amountThbSatang']),
      isTaxable: serializer.fromJson<bool>(json['isTaxable']),
      taxableReason: serializer.fromJson<String?>(json['taxableReason']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remittanceTransactionId': serializer.toJson<String>(
        remittanceTransactionId,
      ),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'taxYearEarned': serializer.toJson<int?>(taxYearEarned),
      'taxYearRemitted': serializer.toJson<int?>(taxYearRemitted),
      'remittanceDate': serializer.toJson<DateTime>(remittanceDate),
      'incomeSourceType': serializer.toJson<String>(incomeSourceType),
      'isPrincipal': serializer.toJson<bool>(isPrincipal),
      'amountOriginalSatang': serializer.toJson<int>(amountOriginalSatang),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'fxRate': serializer.toJson<String>(fxRate),
      'amountThbSatang': serializer.toJson<int>(amountThbSatang),
      'isTaxable': serializer.toJson<bool>(isTaxable),
      'taxableReason': serializer.toJson<String?>(taxableReason),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ForeignRemittance copyWith({
    String? id,
    String? remittanceTransactionId,
    String? sourceAccountId,
    Value<String?> destinationAccountId = const Value.absent(),
    Value<int?> taxYearEarned = const Value.absent(),
    Value<int?> taxYearRemitted = const Value.absent(),
    DateTime? remittanceDate,
    String? incomeSourceType,
    bool? isPrincipal,
    int? amountOriginalSatang,
    String? currencyCode,
    String? fxRate,
    int? amountThbSatang,
    bool? isTaxable,
    Value<String?> taxableReason = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ForeignRemittance(
    id: id ?? this.id,
    remittanceTransactionId:
        remittanceTransactionId ?? this.remittanceTransactionId,
    sourceAccountId: sourceAccountId ?? this.sourceAccountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    taxYearEarned: taxYearEarned.present
        ? taxYearEarned.value
        : this.taxYearEarned,
    taxYearRemitted: taxYearRemitted.present
        ? taxYearRemitted.value
        : this.taxYearRemitted,
    remittanceDate: remittanceDate ?? this.remittanceDate,
    incomeSourceType: incomeSourceType ?? this.incomeSourceType,
    isPrincipal: isPrincipal ?? this.isPrincipal,
    amountOriginalSatang: amountOriginalSatang ?? this.amountOriginalSatang,
    currencyCode: currencyCode ?? this.currencyCode,
    fxRate: fxRate ?? this.fxRate,
    amountThbSatang: amountThbSatang ?? this.amountThbSatang,
    isTaxable: isTaxable ?? this.isTaxable,
    taxableReason: taxableReason.present
        ? taxableReason.value
        : this.taxableReason,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ForeignRemittance copyWithCompanion(ForeignRemittancesCompanion data) {
    return ForeignRemittance(
      id: data.id.present ? data.id.value : this.id,
      remittanceTransactionId: data.remittanceTransactionId.present
          ? data.remittanceTransactionId.value
          : this.remittanceTransactionId,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      taxYearEarned: data.taxYearEarned.present
          ? data.taxYearEarned.value
          : this.taxYearEarned,
      taxYearRemitted: data.taxYearRemitted.present
          ? data.taxYearRemitted.value
          : this.taxYearRemitted,
      remittanceDate: data.remittanceDate.present
          ? data.remittanceDate.value
          : this.remittanceDate,
      incomeSourceType: data.incomeSourceType.present
          ? data.incomeSourceType.value
          : this.incomeSourceType,
      isPrincipal: data.isPrincipal.present
          ? data.isPrincipal.value
          : this.isPrincipal,
      amountOriginalSatang: data.amountOriginalSatang.present
          ? data.amountOriginalSatang.value
          : this.amountOriginalSatang,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      amountThbSatang: data.amountThbSatang.present
          ? data.amountThbSatang.value
          : this.amountThbSatang,
      isTaxable: data.isTaxable.present ? data.isTaxable.value : this.isTaxable,
      taxableReason: data.taxableReason.present
          ? data.taxableReason.value
          : this.taxableReason,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ForeignRemittance(')
          ..write('id: $id, ')
          ..write('remittanceTransactionId: $remittanceTransactionId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('taxYearEarned: $taxYearEarned, ')
          ..write('taxYearRemitted: $taxYearRemitted, ')
          ..write('remittanceDate: $remittanceDate, ')
          ..write('incomeSourceType: $incomeSourceType, ')
          ..write('isPrincipal: $isPrincipal, ')
          ..write('amountOriginalSatang: $amountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('amountThbSatang: $amountThbSatang, ')
          ..write('isTaxable: $isTaxable, ')
          ..write('taxableReason: $taxableReason, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remittanceTransactionId,
    sourceAccountId,
    destinationAccountId,
    taxYearEarned,
    taxYearRemitted,
    remittanceDate,
    incomeSourceType,
    isPrincipal,
    amountOriginalSatang,
    currencyCode,
    fxRate,
    amountThbSatang,
    isTaxable,
    taxableReason,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForeignRemittance &&
          other.id == this.id &&
          other.remittanceTransactionId == this.remittanceTransactionId &&
          other.sourceAccountId == this.sourceAccountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.taxYearEarned == this.taxYearEarned &&
          other.taxYearRemitted == this.taxYearRemitted &&
          other.remittanceDate == this.remittanceDate &&
          other.incomeSourceType == this.incomeSourceType &&
          other.isPrincipal == this.isPrincipal &&
          other.amountOriginalSatang == this.amountOriginalSatang &&
          other.currencyCode == this.currencyCode &&
          other.fxRate == this.fxRate &&
          other.amountThbSatang == this.amountThbSatang &&
          other.isTaxable == this.isTaxable &&
          other.taxableReason == this.taxableReason &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ForeignRemittancesCompanion extends UpdateCompanion<ForeignRemittance> {
  final Value<String> id;
  final Value<String> remittanceTransactionId;
  final Value<String> sourceAccountId;
  final Value<String?> destinationAccountId;
  final Value<int?> taxYearEarned;
  final Value<int?> taxYearRemitted;
  final Value<DateTime> remittanceDate;
  final Value<String> incomeSourceType;
  final Value<bool> isPrincipal;
  final Value<int> amountOriginalSatang;
  final Value<String> currencyCode;
  final Value<String> fxRate;
  final Value<int> amountThbSatang;
  final Value<bool> isTaxable;
  final Value<String?> taxableReason;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ForeignRemittancesCompanion({
    this.id = const Value.absent(),
    this.remittanceTransactionId = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.taxYearEarned = const Value.absent(),
    this.taxYearRemitted = const Value.absent(),
    this.remittanceDate = const Value.absent(),
    this.incomeSourceType = const Value.absent(),
    this.isPrincipal = const Value.absent(),
    this.amountOriginalSatang = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.amountThbSatang = const Value.absent(),
    this.isTaxable = const Value.absent(),
    this.taxableReason = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForeignRemittancesCompanion.insert({
    required String id,
    required String remittanceTransactionId,
    required String sourceAccountId,
    this.destinationAccountId = const Value.absent(),
    this.taxYearEarned = const Value.absent(),
    this.taxYearRemitted = const Value.absent(),
    required DateTime remittanceDate,
    this.incomeSourceType = const Value.absent(),
    this.isPrincipal = const Value.absent(),
    required int amountOriginalSatang,
    required String currencyCode,
    required String fxRate,
    required int amountThbSatang,
    this.isTaxable = const Value.absent(),
    this.taxableReason = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       remittanceTransactionId = Value(remittanceTransactionId),
       sourceAccountId = Value(sourceAccountId),
       remittanceDate = Value(remittanceDate),
       amountOriginalSatang = Value(amountOriginalSatang),
       currencyCode = Value(currencyCode),
       fxRate = Value(fxRate),
       amountThbSatang = Value(amountThbSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ForeignRemittance> custom({
    Expression<String>? id,
    Expression<String>? remittanceTransactionId,
    Expression<String>? sourceAccountId,
    Expression<String>? destinationAccountId,
    Expression<int>? taxYearEarned,
    Expression<int>? taxYearRemitted,
    Expression<DateTime>? remittanceDate,
    Expression<String>? incomeSourceType,
    Expression<bool>? isPrincipal,
    Expression<int>? amountOriginalSatang,
    Expression<String>? currencyCode,
    Expression<String>? fxRate,
    Expression<int>? amountThbSatang,
    Expression<bool>? isTaxable,
    Expression<String>? taxableReason,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remittanceTransactionId != null)
        'remittance_transaction_id': remittanceTransactionId,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (taxYearEarned != null) 'tax_year_earned': taxYearEarned,
      if (taxYearRemitted != null) 'tax_year_remitted': taxYearRemitted,
      if (remittanceDate != null) 'remittance_date': remittanceDate,
      if (incomeSourceType != null) 'income_source_type': incomeSourceType,
      if (isPrincipal != null) 'is_principal': isPrincipal,
      if (amountOriginalSatang != null)
        'amount_original_satang': amountOriginalSatang,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (fxRate != null) 'fx_rate': fxRate,
      if (amountThbSatang != null) 'amount_thb_satang': amountThbSatang,
      if (isTaxable != null) 'is_taxable': isTaxable,
      if (taxableReason != null) 'taxable_reason': taxableReason,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForeignRemittancesCompanion copyWith({
    Value<String>? id,
    Value<String>? remittanceTransactionId,
    Value<String>? sourceAccountId,
    Value<String?>? destinationAccountId,
    Value<int?>? taxYearEarned,
    Value<int?>? taxYearRemitted,
    Value<DateTime>? remittanceDate,
    Value<String>? incomeSourceType,
    Value<bool>? isPrincipal,
    Value<int>? amountOriginalSatang,
    Value<String>? currencyCode,
    Value<String>? fxRate,
    Value<int>? amountThbSatang,
    Value<bool>? isTaxable,
    Value<String?>? taxableReason,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ForeignRemittancesCompanion(
      id: id ?? this.id,
      remittanceTransactionId:
          remittanceTransactionId ?? this.remittanceTransactionId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      taxYearEarned: taxYearEarned ?? this.taxYearEarned,
      taxYearRemitted: taxYearRemitted ?? this.taxYearRemitted,
      remittanceDate: remittanceDate ?? this.remittanceDate,
      incomeSourceType: incomeSourceType ?? this.incomeSourceType,
      isPrincipal: isPrincipal ?? this.isPrincipal,
      amountOriginalSatang: amountOriginalSatang ?? this.amountOriginalSatang,
      currencyCode: currencyCode ?? this.currencyCode,
      fxRate: fxRate ?? this.fxRate,
      amountThbSatang: amountThbSatang ?? this.amountThbSatang,
      isTaxable: isTaxable ?? this.isTaxable,
      taxableReason: taxableReason ?? this.taxableReason,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remittanceTransactionId.present) {
      map['remittance_transaction_id'] = Variable<String>(
        remittanceTransactionId.value,
      );
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (taxYearEarned.present) {
      map['tax_year_earned'] = Variable<int>(taxYearEarned.value);
    }
    if (taxYearRemitted.present) {
      map['tax_year_remitted'] = Variable<int>(taxYearRemitted.value);
    }
    if (remittanceDate.present) {
      map['remittance_date'] = Variable<DateTime>(remittanceDate.value);
    }
    if (incomeSourceType.present) {
      map['income_source_type'] = Variable<String>(incomeSourceType.value);
    }
    if (isPrincipal.present) {
      map['is_principal'] = Variable<bool>(isPrincipal.value);
    }
    if (amountOriginalSatang.present) {
      map['amount_original_satang'] = Variable<int>(amountOriginalSatang.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(fxRate.value);
    }
    if (amountThbSatang.present) {
      map['amount_thb_satang'] = Variable<int>(amountThbSatang.value);
    }
    if (isTaxable.present) {
      map['is_taxable'] = Variable<bool>(isTaxable.value);
    }
    if (taxableReason.present) {
      map['taxable_reason'] = Variable<String>(taxableReason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForeignRemittancesCompanion(')
          ..write('id: $id, ')
          ..write('remittanceTransactionId: $remittanceTransactionId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('taxYearEarned: $taxYearEarned, ')
          ..write('taxYearRemitted: $taxYearRemitted, ')
          ..write('remittanceDate: $remittanceDate, ')
          ..write('incomeSourceType: $incomeSourceType, ')
          ..write('isPrincipal: $isPrincipal, ')
          ..write('amountOriginalSatang: $amountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('amountThbSatang: $amountThbSatang, ')
          ..write('isTaxable: $isTaxable, ')
          ..write('taxableReason: $taxableReason, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialHealthSettingsTable extends FinancialHealthSettings
    with TableInfo<$FinancialHealthSettingsTable, FinancialHealthSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialHealthSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricCodeMeta = const VerificationMeta(
    'metricCode',
  );
  @override
  late final GeneratedColumn<String> metricCode = GeneratedColumn<String>(
    'metric_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _targetOperatorMeta = const VerificationMeta(
    'targetOperator',
  );
  @override
  late final GeneratedColumn<String> targetOperator = GeneratedColumn<String>(
    'target_operator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<String> targetValue = GeneratedColumn<String>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warningValueMeta = const VerificationMeta(
    'warningValue',
  );
  @override
  late final GeneratedColumn<String> warningValue = GeneratedColumn<String>(
    'warning_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userParam1SatangMeta = const VerificationMeta(
    'userParam1Satang',
  );
  @override
  late final GeneratedColumn<int> userParam1Satang = GeneratedColumn<int>(
    'user_param1_satang',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userParam2SatangMeta = const VerificationMeta(
    'userParam2Satang',
  );
  @override
  late final GeneratedColumn<int> userParam2Satang = GeneratedColumn<int>(
    'user_param2_satang',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    metricCode,
    targetOperator,
    targetValue,
    warningValue,
    userParam1Satang,
    userParam2Satang,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_health_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialHealthSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('metric_code')) {
      context.handle(
        _metricCodeMeta,
        metricCode.isAcceptableOrUnknown(data['metric_code']!, _metricCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricCodeMeta);
    }
    if (data.containsKey('target_operator')) {
      context.handle(
        _targetOperatorMeta,
        targetOperator.isAcceptableOrUnknown(
          data['target_operator']!,
          _targetOperatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetOperatorMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('warning_value')) {
      context.handle(
        _warningValueMeta,
        warningValue.isAcceptableOrUnknown(
          data['warning_value']!,
          _warningValueMeta,
        ),
      );
    }
    if (data.containsKey('user_param1_satang')) {
      context.handle(
        _userParam1SatangMeta,
        userParam1Satang.isAcceptableOrUnknown(
          data['user_param1_satang']!,
          _userParam1SatangMeta,
        ),
      );
    }
    if (data.containsKey('user_param2_satang')) {
      context.handle(
        _userParam2SatangMeta,
        userParam2Satang.isAcceptableOrUnknown(
          data['user_param2_satang']!,
          _userParam2SatangMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialHealthSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialHealthSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      metricCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_code'],
      )!,
      targetOperator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_operator'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_value'],
      )!,
      warningValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warning_value'],
      ),
      userParam1Satang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_param1_satang'],
      ),
      userParam2Satang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_param2_satang'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $FinancialHealthSettingsTable createAlias(String alias) {
    return $FinancialHealthSettingsTable(attachedDatabase, alias);
  }
}

class FinancialHealthSetting extends DataClass
    implements Insertable<FinancialHealthSetting> {
  final String id;
  final String metricCode;
  final String targetOperator;
  final String targetValue;
  final String? warningValue;
  final int? userParam1Satang;
  final int? userParam2Satang;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const FinancialHealthSetting({
    required this.id,
    required this.metricCode,
    required this.targetOperator,
    required this.targetValue,
    this.warningValue,
    this.userParam1Satang,
    this.userParam2Satang,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['metric_code'] = Variable<String>(metricCode);
    map['target_operator'] = Variable<String>(targetOperator);
    map['target_value'] = Variable<String>(targetValue);
    if (!nullToAbsent || warningValue != null) {
      map['warning_value'] = Variable<String>(warningValue);
    }
    if (!nullToAbsent || userParam1Satang != null) {
      map['user_param1_satang'] = Variable<int>(userParam1Satang);
    }
    if (!nullToAbsent || userParam2Satang != null) {
      map['user_param2_satang'] = Variable<int>(userParam2Satang);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FinancialHealthSettingsCompanion toCompanion(bool nullToAbsent) {
    return FinancialHealthSettingsCompanion(
      id: Value(id),
      metricCode: Value(metricCode),
      targetOperator: Value(targetOperator),
      targetValue: Value(targetValue),
      warningValue: warningValue == null && nullToAbsent
          ? const Value.absent()
          : Value(warningValue),
      userParam1Satang: userParam1Satang == null && nullToAbsent
          ? const Value.absent()
          : Value(userParam1Satang),
      userParam2Satang: userParam2Satang == null && nullToAbsent
          ? const Value.absent()
          : Value(userParam2Satang),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory FinancialHealthSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialHealthSetting(
      id: serializer.fromJson<String>(json['id']),
      metricCode: serializer.fromJson<String>(json['metricCode']),
      targetOperator: serializer.fromJson<String>(json['targetOperator']),
      targetValue: serializer.fromJson<String>(json['targetValue']),
      warningValue: serializer.fromJson<String?>(json['warningValue']),
      userParam1Satang: serializer.fromJson<int?>(json['userParam1Satang']),
      userParam2Satang: serializer.fromJson<int?>(json['userParam2Satang']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'metricCode': serializer.toJson<String>(metricCode),
      'targetOperator': serializer.toJson<String>(targetOperator),
      'targetValue': serializer.toJson<String>(targetValue),
      'warningValue': serializer.toJson<String?>(warningValue),
      'userParam1Satang': serializer.toJson<int?>(userParam1Satang),
      'userParam2Satang': serializer.toJson<int?>(userParam2Satang),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  FinancialHealthSetting copyWith({
    String? id,
    String? metricCode,
    String? targetOperator,
    String? targetValue,
    Value<String?> warningValue = const Value.absent(),
    Value<int?> userParam1Satang = const Value.absent(),
    Value<int?> userParam2Satang = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => FinancialHealthSetting(
    id: id ?? this.id,
    metricCode: metricCode ?? this.metricCode,
    targetOperator: targetOperator ?? this.targetOperator,
    targetValue: targetValue ?? this.targetValue,
    warningValue: warningValue.present ? warningValue.value : this.warningValue,
    userParam1Satang: userParam1Satang.present
        ? userParam1Satang.value
        : this.userParam1Satang,
    userParam2Satang: userParam2Satang.present
        ? userParam2Satang.value
        : this.userParam2Satang,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  FinancialHealthSetting copyWithCompanion(
    FinancialHealthSettingsCompanion data,
  ) {
    return FinancialHealthSetting(
      id: data.id.present ? data.id.value : this.id,
      metricCode: data.metricCode.present
          ? data.metricCode.value
          : this.metricCode,
      targetOperator: data.targetOperator.present
          ? data.targetOperator.value
          : this.targetOperator,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      warningValue: data.warningValue.present
          ? data.warningValue.value
          : this.warningValue,
      userParam1Satang: data.userParam1Satang.present
          ? data.userParam1Satang.value
          : this.userParam1Satang,
      userParam2Satang: data.userParam2Satang.present
          ? data.userParam2Satang.value
          : this.userParam2Satang,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialHealthSetting(')
          ..write('id: $id, ')
          ..write('metricCode: $metricCode, ')
          ..write('targetOperator: $targetOperator, ')
          ..write('targetValue: $targetValue, ')
          ..write('warningValue: $warningValue, ')
          ..write('userParam1Satang: $userParam1Satang, ')
          ..write('userParam2Satang: $userParam2Satang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    metricCode,
    targetOperator,
    targetValue,
    warningValue,
    userParam1Satang,
    userParam2Satang,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialHealthSetting &&
          other.id == this.id &&
          other.metricCode == this.metricCode &&
          other.targetOperator == this.targetOperator &&
          other.targetValue == this.targetValue &&
          other.warningValue == this.warningValue &&
          other.userParam1Satang == this.userParam1Satang &&
          other.userParam2Satang == this.userParam2Satang &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FinancialHealthSettingsCompanion
    extends UpdateCompanion<FinancialHealthSetting> {
  final Value<String> id;
  final Value<String> metricCode;
  final Value<String> targetOperator;
  final Value<String> targetValue;
  final Value<String?> warningValue;
  final Value<int?> userParam1Satang;
  final Value<int?> userParam2Satang;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FinancialHealthSettingsCompanion({
    this.id = const Value.absent(),
    this.metricCode = const Value.absent(),
    this.targetOperator = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.warningValue = const Value.absent(),
    this.userParam1Satang = const Value.absent(),
    this.userParam2Satang = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialHealthSettingsCompanion.insert({
    required String id,
    required String metricCode,
    required String targetOperator,
    required String targetValue,
    this.warningValue = const Value.absent(),
    this.userParam1Satang = const Value.absent(),
    this.userParam2Satang = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       metricCode = Value(metricCode),
       targetOperator = Value(targetOperator),
       targetValue = Value(targetValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FinancialHealthSetting> custom({
    Expression<String>? id,
    Expression<String>? metricCode,
    Expression<String>? targetOperator,
    Expression<String>? targetValue,
    Expression<String>? warningValue,
    Expression<int>? userParam1Satang,
    Expression<int>? userParam2Satang,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricCode != null) 'metric_code': metricCode,
      if (targetOperator != null) 'target_operator': targetOperator,
      if (targetValue != null) 'target_value': targetValue,
      if (warningValue != null) 'warning_value': warningValue,
      if (userParam1Satang != null) 'user_param1_satang': userParam1Satang,
      if (userParam2Satang != null) 'user_param2_satang': userParam2Satang,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialHealthSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? metricCode,
    Value<String>? targetOperator,
    Value<String>? targetValue,
    Value<String?>? warningValue,
    Value<int?>? userParam1Satang,
    Value<int?>? userParam2Satang,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return FinancialHealthSettingsCompanion(
      id: id ?? this.id,
      metricCode: metricCode ?? this.metricCode,
      targetOperator: targetOperator ?? this.targetOperator,
      targetValue: targetValue ?? this.targetValue,
      warningValue: warningValue ?? this.warningValue,
      userParam1Satang: userParam1Satang ?? this.userParam1Satang,
      userParam2Satang: userParam2Satang ?? this.userParam2Satang,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (metricCode.present) {
      map['metric_code'] = Variable<String>(metricCode.value);
    }
    if (targetOperator.present) {
      map['target_operator'] = Variable<String>(targetOperator.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<String>(targetValue.value);
    }
    if (warningValue.present) {
      map['warning_value'] = Variable<String>(warningValue.value);
    }
    if (userParam1Satang.present) {
      map['user_param1_satang'] = Variable<int>(userParam1Satang.value);
    }
    if (userParam2Satang.present) {
      map['user_param2_satang'] = Variable<int>(userParam2Satang.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialHealthSettingsCompanion(')
          ..write('id: $id, ')
          ..write('metricCode: $metricCode, ')
          ..write('targetOperator: $targetOperator, ')
          ..write('targetValue: $targetValue, ')
          ..write('warningValue: $warningValue, ')
          ..write('userParam1Satang: $userParam1Satang, ')
          ..write('userParam2Satang: $userParam2Satang, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceSnapshotsTable extends BalanceSnapshots
    with TableInfo<$BalanceSnapshotsTable, BalanceSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotDateMeta = const VerificationMeta(
    'snapshotDate',
  );
  @override
  late final GeneratedColumn<DateTime> snapshotDate = GeneratedColumn<DateTime>(
    'snapshot_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closingBalanceSatangMeta =
      const VerificationMeta('closingBalanceSatang');
  @override
  late final GeneratedColumn<int> closingBalanceSatang = GeneratedColumn<int>(
    'closing_balance_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    snapshotDate,
    closingBalanceSatang,
    currencyCode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('snapshot_date')) {
      context.handle(
        _snapshotDateMeta,
        snapshotDate.isAcceptableOrUnknown(
          data['snapshot_date']!,
          _snapshotDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotDateMeta);
    }
    if (data.containsKey('closing_balance_satang')) {
      context.handle(
        _closingBalanceSatangMeta,
        closingBalanceSatang.isAcceptableOrUnknown(
          data['closing_balance_satang']!,
          _closingBalanceSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_closingBalanceSatangMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BalanceSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      snapshotDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snapshot_date'],
      )!,
      closingBalanceSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_balance_satang'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
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
  $BalanceSnapshotsTable createAlias(String alias) {
    return $BalanceSnapshotsTable(attachedDatabase, alias);
  }
}

class BalanceSnapshot extends DataClass implements Insertable<BalanceSnapshot> {
  final String id;
  final String accountId;
  final DateTime snapshotDate;
  final int closingBalanceSatang;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BalanceSnapshot({
    required this.id,
    required this.accountId,
    required this.snapshotDate,
    required this.closingBalanceSatang,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['snapshot_date'] = Variable<DateTime>(snapshotDate);
    map['closing_balance_satang'] = Variable<int>(closingBalanceSatang);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BalanceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BalanceSnapshotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      snapshotDate: Value(snapshotDate),
      closingBalanceSatang: Value(closingBalanceSatang),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BalanceSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceSnapshot(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      snapshotDate: serializer.fromJson<DateTime>(json['snapshotDate']),
      closingBalanceSatang: serializer.fromJson<int>(
        json['closingBalanceSatang'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'snapshotDate': serializer.toJson<DateTime>(snapshotDate),
      'closingBalanceSatang': serializer.toJson<int>(closingBalanceSatang),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BalanceSnapshot copyWith({
    String? id,
    String? accountId,
    DateTime? snapshotDate,
    int? closingBalanceSatang,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BalanceSnapshot(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    snapshotDate: snapshotDate ?? this.snapshotDate,
    closingBalanceSatang: closingBalanceSatang ?? this.closingBalanceSatang,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BalanceSnapshot copyWithCompanion(BalanceSnapshotsCompanion data) {
    return BalanceSnapshot(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      snapshotDate: data.snapshotDate.present
          ? data.snapshotDate.value
          : this.snapshotDate,
      closingBalanceSatang: data.closingBalanceSatang.present
          ? data.closingBalanceSatang.value
          : this.closingBalanceSatang,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshot(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('closingBalanceSatang: $closingBalanceSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    snapshotDate,
    closingBalanceSatang,
    currencyCode,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceSnapshot &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.snapshotDate == this.snapshotDate &&
          other.closingBalanceSatang == this.closingBalanceSatang &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BalanceSnapshotsCompanion extends UpdateCompanion<BalanceSnapshot> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<DateTime> snapshotDate;
  final Value<int> closingBalanceSatang;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BalanceSnapshotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.snapshotDate = const Value.absent(),
    this.closingBalanceSatang = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceSnapshotsCompanion.insert({
    required String id,
    required String accountId,
    required DateTime snapshotDate,
    required int closingBalanceSatang,
    required String currencyCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       snapshotDate = Value(snapshotDate),
       closingBalanceSatang = Value(closingBalanceSatang),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BalanceSnapshot> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<DateTime>? snapshotDate,
    Expression<int>? closingBalanceSatang,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (snapshotDate != null) 'snapshot_date': snapshotDate,
      if (closingBalanceSatang != null)
        'closing_balance_satang': closingBalanceSatang,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<DateTime>? snapshotDate,
    Value<int>? closingBalanceSatang,
    Value<String>? currencyCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BalanceSnapshotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      snapshotDate: snapshotDate ?? this.snapshotDate,
      closingBalanceSatang: closingBalanceSatang ?? this.closingBalanceSatang,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (snapshotDate.present) {
      map['snapshot_date'] = Variable<DateTime>(snapshotDate.value);
    }
    if (closingBalanceSatang.present) {
      map['closing_balance_satang'] = Variable<int>(closingBalanceSatang.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('closingBalanceSatang: $closingBalanceSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentIncomesTable extends InvestmentIncomes
    with TableInfo<$InvestmentIncomesTable, InvestmentIncome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentIncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incomeTypeMeta = const VerificationMeta(
    'incomeType',
  );
  @override
  late final GeneratedColumn<String> incomeType = GeneratedColumn<String>(
    'income_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossAmountOriginalSatangMeta =
      const VerificationMeta('grossAmountOriginalSatang');
  @override
  late final GeneratedColumn<int> grossAmountOriginalSatang =
      GeneratedColumn<int>(
        'gross_amount_original_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<String> fxRate = GeneratedColumn<String>(
    'fx_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossAmountThbSatangMeta =
      const VerificationMeta('grossAmountThbSatang');
  @override
  late final GeneratedColumn<int> grossAmountThbSatang = GeneratedColumn<int>(
    'gross_amount_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withholdingTaxThbSatangMeta =
      const VerificationMeta('withholdingTaxThbSatang');
  @override
  late final GeneratedColumn<int> withholdingTaxThbSatang =
      GeneratedColumn<int>(
        'withholding_tax_thb_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _dividendTaxCreditSatangMeta =
      const VerificationMeta('dividendTaxCreditSatang');
  @override
  late final GeneratedColumn<int> dividendTaxCreditSatang =
      GeneratedColumn<int>(
        'dividend_tax_credit_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _netAmountThbSatangMeta =
      const VerificationMeta('netAmountThbSatang');
  @override
  late final GeneratedColumn<int> netAmountThbSatang = GeneratedColumn<int>(
    'net_amount_thb_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isForeignIncomeMeta = const VerificationMeta(
    'isForeignIncome',
  );
  @override
  late final GeneratedColumn<bool> isForeignIncome = GeneratedColumn<bool>(
    'is_foreign_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_foreign_income" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    assetId,
    incomeType,
    grossAmountOriginalSatang,
    currencyCode,
    fxRate,
    grossAmountThbSatang,
    withholdingTaxThbSatang,
    dividendTaxCreditSatang,
    netAmountThbSatang,
    isForeignIncome,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentIncome> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('income_type')) {
      context.handle(
        _incomeTypeMeta,
        incomeType.isAcceptableOrUnknown(data['income_type']!, _incomeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('gross_amount_original_satang')) {
      context.handle(
        _grossAmountOriginalSatangMeta,
        grossAmountOriginalSatang.isAcceptableOrUnknown(
          data['gross_amount_original_satang']!,
          _grossAmountOriginalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossAmountOriginalSatangMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    } else if (isInserting) {
      context.missing(_fxRateMeta);
    }
    if (data.containsKey('gross_amount_thb_satang')) {
      context.handle(
        _grossAmountThbSatangMeta,
        grossAmountThbSatang.isAcceptableOrUnknown(
          data['gross_amount_thb_satang']!,
          _grossAmountThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossAmountThbSatangMeta);
    }
    if (data.containsKey('withholding_tax_thb_satang')) {
      context.handle(
        _withholdingTaxThbSatangMeta,
        withholdingTaxThbSatang.isAcceptableOrUnknown(
          data['withholding_tax_thb_satang']!,
          _withholdingTaxThbSatangMeta,
        ),
      );
    }
    if (data.containsKey('dividend_tax_credit_satang')) {
      context.handle(
        _dividendTaxCreditSatangMeta,
        dividendTaxCreditSatang.isAcceptableOrUnknown(
          data['dividend_tax_credit_satang']!,
          _dividendTaxCreditSatangMeta,
        ),
      );
    }
    if (data.containsKey('net_amount_thb_satang')) {
      context.handle(
        _netAmountThbSatangMeta,
        netAmountThbSatang.isAcceptableOrUnknown(
          data['net_amount_thb_satang']!,
          _netAmountThbSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netAmountThbSatangMeta);
    }
    if (data.containsKey('is_foreign_income')) {
      context.handle(
        _isForeignIncomeMeta,
        isForeignIncome.isAcceptableOrUnknown(
          data['is_foreign_income']!,
          _isForeignIncomeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentIncome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentIncome(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      incomeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_type'],
      )!,
      grossAmountOriginalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_amount_original_satang'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fx_rate'],
      )!,
      grossAmountThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_amount_thb_satang'],
      )!,
      withholdingTaxThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}withholding_tax_thb_satang'],
      )!,
      dividendTaxCreditSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dividend_tax_credit_satang'],
      )!,
      netAmountThbSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_amount_thb_satang'],
      )!,
      isForeignIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_foreign_income'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InvestmentIncomesTable createAlias(String alias) {
    return $InvestmentIncomesTable(attachedDatabase, alias);
  }
}

class InvestmentIncome extends DataClass
    implements Insertable<InvestmentIncome> {
  final String id;
  final String transactionId;
  final String assetId;
  final String incomeType;
  final int grossAmountOriginalSatang;
  final String currencyCode;
  final String fxRate;
  final int grossAmountThbSatang;
  final int withholdingTaxThbSatang;
  final int dividendTaxCreditSatang;
  final int netAmountThbSatang;
  final bool isForeignIncome;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InvestmentIncome({
    required this.id,
    required this.transactionId,
    required this.assetId,
    required this.incomeType,
    required this.grossAmountOriginalSatang,
    required this.currencyCode,
    required this.fxRate,
    required this.grossAmountThbSatang,
    required this.withholdingTaxThbSatang,
    required this.dividendTaxCreditSatang,
    required this.netAmountThbSatang,
    required this.isForeignIncome,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['asset_id'] = Variable<String>(assetId);
    map['income_type'] = Variable<String>(incomeType);
    map['gross_amount_original_satang'] = Variable<int>(
      grossAmountOriginalSatang,
    );
    map['currency_code'] = Variable<String>(currencyCode);
    map['fx_rate'] = Variable<String>(fxRate);
    map['gross_amount_thb_satang'] = Variable<int>(grossAmountThbSatang);
    map['withholding_tax_thb_satang'] = Variable<int>(withholdingTaxThbSatang);
    map['dividend_tax_credit_satang'] = Variable<int>(dividendTaxCreditSatang);
    map['net_amount_thb_satang'] = Variable<int>(netAmountThbSatang);
    map['is_foreign_income'] = Variable<bool>(isForeignIncome);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InvestmentIncomesCompanion toCompanion(bool nullToAbsent) {
    return InvestmentIncomesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      assetId: Value(assetId),
      incomeType: Value(incomeType),
      grossAmountOriginalSatang: Value(grossAmountOriginalSatang),
      currencyCode: Value(currencyCode),
      fxRate: Value(fxRate),
      grossAmountThbSatang: Value(grossAmountThbSatang),
      withholdingTaxThbSatang: Value(withholdingTaxThbSatang),
      dividendTaxCreditSatang: Value(dividendTaxCreditSatang),
      netAmountThbSatang: Value(netAmountThbSatang),
      isForeignIncome: Value(isForeignIncome),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InvestmentIncome.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentIncome(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      grossAmountOriginalSatang: serializer.fromJson<int>(
        json['grossAmountOriginalSatang'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      fxRate: serializer.fromJson<String>(json['fxRate']),
      grossAmountThbSatang: serializer.fromJson<int>(
        json['grossAmountThbSatang'],
      ),
      withholdingTaxThbSatang: serializer.fromJson<int>(
        json['withholdingTaxThbSatang'],
      ),
      dividendTaxCreditSatang: serializer.fromJson<int>(
        json['dividendTaxCreditSatang'],
      ),
      netAmountThbSatang: serializer.fromJson<int>(json['netAmountThbSatang']),
      isForeignIncome: serializer.fromJson<bool>(json['isForeignIncome']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'assetId': serializer.toJson<String>(assetId),
      'incomeType': serializer.toJson<String>(incomeType),
      'grossAmountOriginalSatang': serializer.toJson<int>(
        grossAmountOriginalSatang,
      ),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'fxRate': serializer.toJson<String>(fxRate),
      'grossAmountThbSatang': serializer.toJson<int>(grossAmountThbSatang),
      'withholdingTaxThbSatang': serializer.toJson<int>(
        withholdingTaxThbSatang,
      ),
      'dividendTaxCreditSatang': serializer.toJson<int>(
        dividendTaxCreditSatang,
      ),
      'netAmountThbSatang': serializer.toJson<int>(netAmountThbSatang),
      'isForeignIncome': serializer.toJson<bool>(isForeignIncome),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InvestmentIncome copyWith({
    String? id,
    String? transactionId,
    String? assetId,
    String? incomeType,
    int? grossAmountOriginalSatang,
    String? currencyCode,
    String? fxRate,
    int? grossAmountThbSatang,
    int? withholdingTaxThbSatang,
    int? dividendTaxCreditSatang,
    int? netAmountThbSatang,
    bool? isForeignIncome,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InvestmentIncome(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    assetId: assetId ?? this.assetId,
    incomeType: incomeType ?? this.incomeType,
    grossAmountOriginalSatang:
        grossAmountOriginalSatang ?? this.grossAmountOriginalSatang,
    currencyCode: currencyCode ?? this.currencyCode,
    fxRate: fxRate ?? this.fxRate,
    grossAmountThbSatang: grossAmountThbSatang ?? this.grossAmountThbSatang,
    withholdingTaxThbSatang:
        withholdingTaxThbSatang ?? this.withholdingTaxThbSatang,
    dividendTaxCreditSatang:
        dividendTaxCreditSatang ?? this.dividendTaxCreditSatang,
    netAmountThbSatang: netAmountThbSatang ?? this.netAmountThbSatang,
    isForeignIncome: isForeignIncome ?? this.isForeignIncome,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InvestmentIncome copyWithCompanion(InvestmentIncomesCompanion data) {
    return InvestmentIncome(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      incomeType: data.incomeType.present
          ? data.incomeType.value
          : this.incomeType,
      grossAmountOriginalSatang: data.grossAmountOriginalSatang.present
          ? data.grossAmountOriginalSatang.value
          : this.grossAmountOriginalSatang,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      grossAmountThbSatang: data.grossAmountThbSatang.present
          ? data.grossAmountThbSatang.value
          : this.grossAmountThbSatang,
      withholdingTaxThbSatang: data.withholdingTaxThbSatang.present
          ? data.withholdingTaxThbSatang.value
          : this.withholdingTaxThbSatang,
      dividendTaxCreditSatang: data.dividendTaxCreditSatang.present
          ? data.dividendTaxCreditSatang.value
          : this.dividendTaxCreditSatang,
      netAmountThbSatang: data.netAmountThbSatang.present
          ? data.netAmountThbSatang.value
          : this.netAmountThbSatang,
      isForeignIncome: data.isForeignIncome.present
          ? data.isForeignIncome.value
          : this.isForeignIncome,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentIncome(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('assetId: $assetId, ')
          ..write('incomeType: $incomeType, ')
          ..write('grossAmountOriginalSatang: $grossAmountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('grossAmountThbSatang: $grossAmountThbSatang, ')
          ..write('withholdingTaxThbSatang: $withholdingTaxThbSatang, ')
          ..write('dividendTaxCreditSatang: $dividendTaxCreditSatang, ')
          ..write('netAmountThbSatang: $netAmountThbSatang, ')
          ..write('isForeignIncome: $isForeignIncome, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    assetId,
    incomeType,
    grossAmountOriginalSatang,
    currencyCode,
    fxRate,
    grossAmountThbSatang,
    withholdingTaxThbSatang,
    dividendTaxCreditSatang,
    netAmountThbSatang,
    isForeignIncome,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentIncome &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.assetId == this.assetId &&
          other.incomeType == this.incomeType &&
          other.grossAmountOriginalSatang == this.grossAmountOriginalSatang &&
          other.currencyCode == this.currencyCode &&
          other.fxRate == this.fxRate &&
          other.grossAmountThbSatang == this.grossAmountThbSatang &&
          other.withholdingTaxThbSatang == this.withholdingTaxThbSatang &&
          other.dividendTaxCreditSatang == this.dividendTaxCreditSatang &&
          other.netAmountThbSatang == this.netAmountThbSatang &&
          other.isForeignIncome == this.isForeignIncome &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InvestmentIncomesCompanion extends UpdateCompanion<InvestmentIncome> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> assetId;
  final Value<String> incomeType;
  final Value<int> grossAmountOriginalSatang;
  final Value<String> currencyCode;
  final Value<String> fxRate;
  final Value<int> grossAmountThbSatang;
  final Value<int> withholdingTaxThbSatang;
  final Value<int> dividendTaxCreditSatang;
  final Value<int> netAmountThbSatang;
  final Value<bool> isForeignIncome;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InvestmentIncomesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.grossAmountOriginalSatang = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.grossAmountThbSatang = const Value.absent(),
    this.withholdingTaxThbSatang = const Value.absent(),
    this.dividendTaxCreditSatang = const Value.absent(),
    this.netAmountThbSatang = const Value.absent(),
    this.isForeignIncome = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentIncomesCompanion.insert({
    required String id,
    required String transactionId,
    required String assetId,
    required String incomeType,
    required int grossAmountOriginalSatang,
    required String currencyCode,
    required String fxRate,
    required int grossAmountThbSatang,
    this.withholdingTaxThbSatang = const Value.absent(),
    this.dividendTaxCreditSatang = const Value.absent(),
    required int netAmountThbSatang,
    this.isForeignIncome = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       assetId = Value(assetId),
       incomeType = Value(incomeType),
       grossAmountOriginalSatang = Value(grossAmountOriginalSatang),
       currencyCode = Value(currencyCode),
       fxRate = Value(fxRate),
       grossAmountThbSatang = Value(grossAmountThbSatang),
       netAmountThbSatang = Value(netAmountThbSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InvestmentIncome> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? assetId,
    Expression<String>? incomeType,
    Expression<int>? grossAmountOriginalSatang,
    Expression<String>? currencyCode,
    Expression<String>? fxRate,
    Expression<int>? grossAmountThbSatang,
    Expression<int>? withholdingTaxThbSatang,
    Expression<int>? dividendTaxCreditSatang,
    Expression<int>? netAmountThbSatang,
    Expression<bool>? isForeignIncome,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (assetId != null) 'asset_id': assetId,
      if (incomeType != null) 'income_type': incomeType,
      if (grossAmountOriginalSatang != null)
        'gross_amount_original_satang': grossAmountOriginalSatang,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (fxRate != null) 'fx_rate': fxRate,
      if (grossAmountThbSatang != null)
        'gross_amount_thb_satang': grossAmountThbSatang,
      if (withholdingTaxThbSatang != null)
        'withholding_tax_thb_satang': withholdingTaxThbSatang,
      if (dividendTaxCreditSatang != null)
        'dividend_tax_credit_satang': dividendTaxCreditSatang,
      if (netAmountThbSatang != null)
        'net_amount_thb_satang': netAmountThbSatang,
      if (isForeignIncome != null) 'is_foreign_income': isForeignIncome,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentIncomesCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? assetId,
    Value<String>? incomeType,
    Value<int>? grossAmountOriginalSatang,
    Value<String>? currencyCode,
    Value<String>? fxRate,
    Value<int>? grossAmountThbSatang,
    Value<int>? withholdingTaxThbSatang,
    Value<int>? dividendTaxCreditSatang,
    Value<int>? netAmountThbSatang,
    Value<bool>? isForeignIncome,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InvestmentIncomesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      assetId: assetId ?? this.assetId,
      incomeType: incomeType ?? this.incomeType,
      grossAmountOriginalSatang:
          grossAmountOriginalSatang ?? this.grossAmountOriginalSatang,
      currencyCode: currencyCode ?? this.currencyCode,
      fxRate: fxRate ?? this.fxRate,
      grossAmountThbSatang: grossAmountThbSatang ?? this.grossAmountThbSatang,
      withholdingTaxThbSatang:
          withholdingTaxThbSatang ?? this.withholdingTaxThbSatang,
      dividendTaxCreditSatang:
          dividendTaxCreditSatang ?? this.dividendTaxCreditSatang,
      netAmountThbSatang: netAmountThbSatang ?? this.netAmountThbSatang,
      isForeignIncome: isForeignIncome ?? this.isForeignIncome,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(incomeType.value);
    }
    if (grossAmountOriginalSatang.present) {
      map['gross_amount_original_satang'] = Variable<int>(
        grossAmountOriginalSatang.value,
      );
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<String>(fxRate.value);
    }
    if (grossAmountThbSatang.present) {
      map['gross_amount_thb_satang'] = Variable<int>(
        grossAmountThbSatang.value,
      );
    }
    if (withholdingTaxThbSatang.present) {
      map['withholding_tax_thb_satang'] = Variable<int>(
        withholdingTaxThbSatang.value,
      );
    }
    if (dividendTaxCreditSatang.present) {
      map['dividend_tax_credit_satang'] = Variable<int>(
        dividendTaxCreditSatang.value,
      );
    }
    if (netAmountThbSatang.present) {
      map['net_amount_thb_satang'] = Variable<int>(netAmountThbSatang.value);
    }
    if (isForeignIncome.present) {
      map['is_foreign_income'] = Variable<bool>(isForeignIncome.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentIncomesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('assetId: $assetId, ')
          ..write('incomeType: $incomeType, ')
          ..write('grossAmountOriginalSatang: $grossAmountOriginalSatang, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('fxRate: $fxRate, ')
          ..write('grossAmountThbSatang: $grossAmountThbSatang, ')
          ..write('withholdingTaxThbSatang: $withholdingTaxThbSatang, ')
          ..write('dividendTaxCreditSatang: $dividendTaxCreditSatang, ')
          ..write('netAmountThbSatang: $netAmountThbSatang, ')
          ..write('isForeignIncome: $isForeignIncome, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiabilitiesTable extends Liabilities
    with TableInfo<$LiabilitiesTable, Liability> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiabilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _liabilityTypeMeta = const VerificationMeta(
    'liabilityType',
  );
  @override
  late final GeneratedColumn<String> liabilityType = GeneratedColumn<String>(
    'liability_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingPrincipalSatangMeta =
      const VerificationMeta('remainingPrincipalSatang');
  @override
  late final GeneratedColumn<int> remainingPrincipalSatang =
      GeneratedColumn<int>(
        'remaining_principal_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _monthlyPaymentSatangMeta =
      const VerificationMeta('monthlyPaymentSatang');
  @override
  late final GeneratedColumn<int> monthlyPaymentSatang = GeneratedColumn<int>(
    'monthly_payment_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestRatePercentMeta =
      const VerificationMeta('interestRatePercent');
  @override
  late final GeneratedColumn<String> interestRatePercent =
      GeneratedColumn<String>(
        'interest_rate_percent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isShortTermMeta = const VerificationMeta(
    'isShortTerm',
  );
  @override
  late final GeneratedColumn<bool> isShortTerm = GeneratedColumn<bool>(
    'is_short_term',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_short_term" IN (0, 1))',
    ),
  );
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    liabilityType,
    remainingPrincipalSatang,
    monthlyPaymentSatang,
    interestRatePercent,
    isShortTerm,
    linkedAccountId,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liabilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Liability> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('liability_type')) {
      context.handle(
        _liabilityTypeMeta,
        liabilityType.isAcceptableOrUnknown(
          data['liability_type']!,
          _liabilityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_liabilityTypeMeta);
    }
    if (data.containsKey('remaining_principal_satang')) {
      context.handle(
        _remainingPrincipalSatangMeta,
        remainingPrincipalSatang.isAcceptableOrUnknown(
          data['remaining_principal_satang']!,
          _remainingPrincipalSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingPrincipalSatangMeta);
    }
    if (data.containsKey('monthly_payment_satang')) {
      context.handle(
        _monthlyPaymentSatangMeta,
        monthlyPaymentSatang.isAcceptableOrUnknown(
          data['monthly_payment_satang']!,
          _monthlyPaymentSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyPaymentSatangMeta);
    }
    if (data.containsKey('interest_rate_percent')) {
      context.handle(
        _interestRatePercentMeta,
        interestRatePercent.isAcceptableOrUnknown(
          data['interest_rate_percent']!,
          _interestRatePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestRatePercentMeta);
    }
    if (data.containsKey('is_short_term')) {
      context.handle(
        _isShortTermMeta,
        isShortTerm.isAcceptableOrUnknown(
          data['is_short_term']!,
          _isShortTermMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isShortTermMeta);
    }
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Liability map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Liability(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      liabilityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liability_type'],
      )!,
      remainingPrincipalSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_principal_satang'],
      )!,
      monthlyPaymentSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_payment_satang'],
      )!,
      interestRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_rate_percent'],
      )!,
      isShortTerm: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_short_term'],
      )!,
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $LiabilitiesTable createAlias(String alias) {
    return $LiabilitiesTable(attachedDatabase, alias);
  }
}

class Liability extends DataClass implements Insertable<Liability> {
  final String id;
  final String name;
  final String liabilityType;
  final int remainingPrincipalSatang;
  final int monthlyPaymentSatang;
  final String interestRatePercent;
  final bool isShortTerm;
  final String? linkedAccountId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const Liability({
    required this.id,
    required this.name,
    required this.liabilityType,
    required this.remainingPrincipalSatang,
    required this.monthlyPaymentSatang,
    required this.interestRatePercent,
    required this.isShortTerm,
    this.linkedAccountId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['liability_type'] = Variable<String>(liabilityType);
    map['remaining_principal_satang'] = Variable<int>(remainingPrincipalSatang);
    map['monthly_payment_satang'] = Variable<int>(monthlyPaymentSatang);
    map['interest_rate_percent'] = Variable<String>(interestRatePercent);
    map['is_short_term'] = Variable<bool>(isShortTerm);
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  LiabilitiesCompanion toCompanion(bool nullToAbsent) {
    return LiabilitiesCompanion(
      id: Value(id),
      name: Value(name),
      liabilityType: Value(liabilityType),
      remainingPrincipalSatang: Value(remainingPrincipalSatang),
      monthlyPaymentSatang: Value(monthlyPaymentSatang),
      interestRatePercent: Value(interestRatePercent),
      isShortTerm: Value(isShortTerm),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory Liability.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Liability(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      liabilityType: serializer.fromJson<String>(json['liabilityType']),
      remainingPrincipalSatang: serializer.fromJson<int>(
        json['remainingPrincipalSatang'],
      ),
      monthlyPaymentSatang: serializer.fromJson<int>(
        json['monthlyPaymentSatang'],
      ),
      interestRatePercent: serializer.fromJson<String>(
        json['interestRatePercent'],
      ),
      isShortTerm: serializer.fromJson<bool>(json['isShortTerm']),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'liabilityType': serializer.toJson<String>(liabilityType),
      'remainingPrincipalSatang': serializer.toJson<int>(
        remainingPrincipalSatang,
      ),
      'monthlyPaymentSatang': serializer.toJson<int>(monthlyPaymentSatang),
      'interestRatePercent': serializer.toJson<String>(interestRatePercent),
      'isShortTerm': serializer.toJson<bool>(isShortTerm),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  Liability copyWith({
    String? id,
    String? name,
    String? liabilityType,
    int? remainingPrincipalSatang,
    int? monthlyPaymentSatang,
    String? interestRatePercent,
    bool? isShortTerm,
    Value<String?> linkedAccountId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => Liability(
    id: id ?? this.id,
    name: name ?? this.name,
    liabilityType: liabilityType ?? this.liabilityType,
    remainingPrincipalSatang:
        remainingPrincipalSatang ?? this.remainingPrincipalSatang,
    monthlyPaymentSatang: monthlyPaymentSatang ?? this.monthlyPaymentSatang,
    interestRatePercent: interestRatePercent ?? this.interestRatePercent,
    isShortTerm: isShortTerm ?? this.isShortTerm,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  Liability copyWithCompanion(LiabilitiesCompanion data) {
    return Liability(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      liabilityType: data.liabilityType.present
          ? data.liabilityType.value
          : this.liabilityType,
      remainingPrincipalSatang: data.remainingPrincipalSatang.present
          ? data.remainingPrincipalSatang.value
          : this.remainingPrincipalSatang,
      monthlyPaymentSatang: data.monthlyPaymentSatang.present
          ? data.monthlyPaymentSatang.value
          : this.monthlyPaymentSatang,
      interestRatePercent: data.interestRatePercent.present
          ? data.interestRatePercent.value
          : this.interestRatePercent,
      isShortTerm: data.isShortTerm.present
          ? data.isShortTerm.value
          : this.isShortTerm,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Liability(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('liabilityType: $liabilityType, ')
          ..write('remainingPrincipalSatang: $remainingPrincipalSatang, ')
          ..write('monthlyPaymentSatang: $monthlyPaymentSatang, ')
          ..write('interestRatePercent: $interestRatePercent, ')
          ..write('isShortTerm: $isShortTerm, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    liabilityType,
    remainingPrincipalSatang,
    monthlyPaymentSatang,
    interestRatePercent,
    isShortTerm,
    linkedAccountId,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Liability &&
          other.id == this.id &&
          other.name == this.name &&
          other.liabilityType == this.liabilityType &&
          other.remainingPrincipalSatang == this.remainingPrincipalSatang &&
          other.monthlyPaymentSatang == this.monthlyPaymentSatang &&
          other.interestRatePercent == this.interestRatePercent &&
          other.isShortTerm == this.isShortTerm &&
          other.linkedAccountId == this.linkedAccountId &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class LiabilitiesCompanion extends UpdateCompanion<Liability> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> liabilityType;
  final Value<int> remainingPrincipalSatang;
  final Value<int> monthlyPaymentSatang;
  final Value<String> interestRatePercent;
  final Value<bool> isShortTerm;
  final Value<String?> linkedAccountId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const LiabilitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.liabilityType = const Value.absent(),
    this.remainingPrincipalSatang = const Value.absent(),
    this.monthlyPaymentSatang = const Value.absent(),
    this.interestRatePercent = const Value.absent(),
    this.isShortTerm = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiabilitiesCompanion.insert({
    required String id,
    required String name,
    required String liabilityType,
    required int remainingPrincipalSatang,
    required int monthlyPaymentSatang,
    required String interestRatePercent,
    required bool isShortTerm,
    this.linkedAccountId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       liabilityType = Value(liabilityType),
       remainingPrincipalSatang = Value(remainingPrincipalSatang),
       monthlyPaymentSatang = Value(monthlyPaymentSatang),
       interestRatePercent = Value(interestRatePercent),
       isShortTerm = Value(isShortTerm),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Liability> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? liabilityType,
    Expression<int>? remainingPrincipalSatang,
    Expression<int>? monthlyPaymentSatang,
    Expression<String>? interestRatePercent,
    Expression<bool>? isShortTerm,
    Expression<String>? linkedAccountId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (liabilityType != null) 'liability_type': liabilityType,
      if (remainingPrincipalSatang != null)
        'remaining_principal_satang': remainingPrincipalSatang,
      if (monthlyPaymentSatang != null)
        'monthly_payment_satang': monthlyPaymentSatang,
      if (interestRatePercent != null)
        'interest_rate_percent': interestRatePercent,
      if (isShortTerm != null) 'is_short_term': isShortTerm,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiabilitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? liabilityType,
    Value<int>? remainingPrincipalSatang,
    Value<int>? monthlyPaymentSatang,
    Value<String>? interestRatePercent,
    Value<bool>? isShortTerm,
    Value<String?>? linkedAccountId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return LiabilitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      liabilityType: liabilityType ?? this.liabilityType,
      remainingPrincipalSatang:
          remainingPrincipalSatang ?? this.remainingPrincipalSatang,
      monthlyPaymentSatang: monthlyPaymentSatang ?? this.monthlyPaymentSatang,
      interestRatePercent: interestRatePercent ?? this.interestRatePercent,
      isShortTerm: isShortTerm ?? this.isShortTerm,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (liabilityType.present) {
      map['liability_type'] = Variable<String>(liabilityType.value);
    }
    if (remainingPrincipalSatang.present) {
      map['remaining_principal_satang'] = Variable<int>(
        remainingPrincipalSatang.value,
      );
    }
    if (monthlyPaymentSatang.present) {
      map['monthly_payment_satang'] = Variable<int>(monthlyPaymentSatang.value);
    }
    if (interestRatePercent.present) {
      map['interest_rate_percent'] = Variable<String>(
        interestRatePercent.value,
      );
    }
    if (isShortTerm.present) {
      map['is_short_term'] = Variable<bool>(isShortTerm.value);
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiabilitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('liabilityType: $liabilityType, ')
          ..write('remainingPrincipalSatang: $remainingPrincipalSatang, ')
          ..write('monthlyPaymentSatang: $monthlyPaymentSatang, ')
          ..write('interestRatePercent: $interestRatePercent, ')
          ..write('isShortTerm: $isShortTerm, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsurancePoliciesTable extends InsurancePolicies
    with TableInfo<$InsurancePoliciesTable, InsurancePolicy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsurancePoliciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyNameMeta = const VerificationMeta(
    'policyName',
  );
  @override
  late final GeneratedColumn<String> policyName = GeneratedColumn<String>(
    'policy_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insuranceTypeMeta = const VerificationMeta(
    'insuranceType',
  );
  @override
  late final GeneratedColumn<String> insuranceType = GeneratedColumn<String>(
    'insurance_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sumInsuredSatangMeta = const VerificationMeta(
    'sumInsuredSatang',
  );
  @override
  late final GeneratedColumn<int> sumInsuredSatang = GeneratedColumn<int>(
    'sum_insured_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicalCoverageSatangMeta =
      const VerificationMeta('medicalCoverageSatang');
  @override
  late final GeneratedColumn<int> medicalCoverageSatang = GeneratedColumn<int>(
    'medical_coverage_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualPremiumSatangMeta =
      const VerificationMeta('annualPremiumSatang');
  @override
  late final GeneratedColumn<int> annualPremiumSatang = GeneratedColumn<int>(
    'annual_premium_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    policyName,
    insuranceType,
    sumInsuredSatang,
    medicalCoverageSatang,
    annualPremiumSatang,
    dueDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_policies';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsurancePolicy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('policy_name')) {
      context.handle(
        _policyNameMeta,
        policyName.isAcceptableOrUnknown(data['policy_name']!, _policyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_policyNameMeta);
    }
    if (data.containsKey('insurance_type')) {
      context.handle(
        _insuranceTypeMeta,
        insuranceType.isAcceptableOrUnknown(
          data['insurance_type']!,
          _insuranceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insuranceTypeMeta);
    }
    if (data.containsKey('sum_insured_satang')) {
      context.handle(
        _sumInsuredSatangMeta,
        sumInsuredSatang.isAcceptableOrUnknown(
          data['sum_insured_satang']!,
          _sumInsuredSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sumInsuredSatangMeta);
    }
    if (data.containsKey('medical_coverage_satang')) {
      context.handle(
        _medicalCoverageSatangMeta,
        medicalCoverageSatang.isAcceptableOrUnknown(
          data['medical_coverage_satang']!,
          _medicalCoverageSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicalCoverageSatangMeta);
    }
    if (data.containsKey('annual_premium_satang')) {
      context.handle(
        _annualPremiumSatangMeta,
        annualPremiumSatang.isAcceptableOrUnknown(
          data['annual_premium_satang']!,
          _annualPremiumSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annualPremiumSatangMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsurancePolicy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsurancePolicy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      policyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_name'],
      )!,
      insuranceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_type'],
      )!,
      sumInsuredSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sum_insured_satang'],
      )!,
      medicalCoverageSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medical_coverage_satang'],
      )!,
      annualPremiumSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_premium_satang'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $InsurancePoliciesTable createAlias(String alias) {
    return $InsurancePoliciesTable(attachedDatabase, alias);
  }
}

class InsurancePolicy extends DataClass implements Insertable<InsurancePolicy> {
  final String id;
  final String policyName;
  final String insuranceType;
  final int sumInsuredSatang;
  final int medicalCoverageSatang;
  final int annualPremiumSatang;
  final DateTime? dueDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const InsurancePolicy({
    required this.id,
    required this.policyName,
    required this.insuranceType,
    required this.sumInsuredSatang,
    required this.medicalCoverageSatang,
    required this.annualPremiumSatang,
    this.dueDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['policy_name'] = Variable<String>(policyName);
    map['insurance_type'] = Variable<String>(insuranceType);
    map['sum_insured_satang'] = Variable<int>(sumInsuredSatang);
    map['medical_coverage_satang'] = Variable<int>(medicalCoverageSatang);
    map['annual_premium_satang'] = Variable<int>(annualPremiumSatang);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  InsurancePoliciesCompanion toCompanion(bool nullToAbsent) {
    return InsurancePoliciesCompanion(
      id: Value(id),
      policyName: Value(policyName),
      insuranceType: Value(insuranceType),
      sumInsuredSatang: Value(sumInsuredSatang),
      medicalCoverageSatang: Value(medicalCoverageSatang),
      annualPremiumSatang: Value(annualPremiumSatang),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory InsurancePolicy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsurancePolicy(
      id: serializer.fromJson<String>(json['id']),
      policyName: serializer.fromJson<String>(json['policyName']),
      insuranceType: serializer.fromJson<String>(json['insuranceType']),
      sumInsuredSatang: serializer.fromJson<int>(json['sumInsuredSatang']),
      medicalCoverageSatang: serializer.fromJson<int>(
        json['medicalCoverageSatang'],
      ),
      annualPremiumSatang: serializer.fromJson<int>(
        json['annualPremiumSatang'],
      ),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'policyName': serializer.toJson<String>(policyName),
      'insuranceType': serializer.toJson<String>(insuranceType),
      'sumInsuredSatang': serializer.toJson<int>(sumInsuredSatang),
      'medicalCoverageSatang': serializer.toJson<int>(medicalCoverageSatang),
      'annualPremiumSatang': serializer.toJson<int>(annualPremiumSatang),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  InsurancePolicy copyWith({
    String? id,
    String? policyName,
    String? insuranceType,
    int? sumInsuredSatang,
    int? medicalCoverageSatang,
    int? annualPremiumSatang,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => InsurancePolicy(
    id: id ?? this.id,
    policyName: policyName ?? this.policyName,
    insuranceType: insuranceType ?? this.insuranceType,
    sumInsuredSatang: sumInsuredSatang ?? this.sumInsuredSatang,
    medicalCoverageSatang: medicalCoverageSatang ?? this.medicalCoverageSatang,
    annualPremiumSatang: annualPremiumSatang ?? this.annualPremiumSatang,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  InsurancePolicy copyWithCompanion(InsurancePoliciesCompanion data) {
    return InsurancePolicy(
      id: data.id.present ? data.id.value : this.id,
      policyName: data.policyName.present
          ? data.policyName.value
          : this.policyName,
      insuranceType: data.insuranceType.present
          ? data.insuranceType.value
          : this.insuranceType,
      sumInsuredSatang: data.sumInsuredSatang.present
          ? data.sumInsuredSatang.value
          : this.sumInsuredSatang,
      medicalCoverageSatang: data.medicalCoverageSatang.present
          ? data.medicalCoverageSatang.value
          : this.medicalCoverageSatang,
      annualPremiumSatang: data.annualPremiumSatang.present
          ? data.annualPremiumSatang.value
          : this.annualPremiumSatang,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePolicy(')
          ..write('id: $id, ')
          ..write('policyName: $policyName, ')
          ..write('insuranceType: $insuranceType, ')
          ..write('sumInsuredSatang: $sumInsuredSatang, ')
          ..write('medicalCoverageSatang: $medicalCoverageSatang, ')
          ..write('annualPremiumSatang: $annualPremiumSatang, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    policyName,
    insuranceType,
    sumInsuredSatang,
    medicalCoverageSatang,
    annualPremiumSatang,
    dueDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsurancePolicy &&
          other.id == this.id &&
          other.policyName == this.policyName &&
          other.insuranceType == this.insuranceType &&
          other.sumInsuredSatang == this.sumInsuredSatang &&
          other.medicalCoverageSatang == this.medicalCoverageSatang &&
          other.annualPremiumSatang == this.annualPremiumSatang &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class InsurancePoliciesCompanion extends UpdateCompanion<InsurancePolicy> {
  final Value<String> id;
  final Value<String> policyName;
  final Value<String> insuranceType;
  final Value<int> sumInsuredSatang;
  final Value<int> medicalCoverageSatang;
  final Value<int> annualPremiumSatang;
  final Value<DateTime?> dueDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const InsurancePoliciesCompanion({
    this.id = const Value.absent(),
    this.policyName = const Value.absent(),
    this.insuranceType = const Value.absent(),
    this.sumInsuredSatang = const Value.absent(),
    this.medicalCoverageSatang = const Value.absent(),
    this.annualPremiumSatang = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsurancePoliciesCompanion.insert({
    required String id,
    required String policyName,
    required String insuranceType,
    required int sumInsuredSatang,
    required int medicalCoverageSatang,
    required int annualPremiumSatang,
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       policyName = Value(policyName),
       insuranceType = Value(insuranceType),
       sumInsuredSatang = Value(sumInsuredSatang),
       medicalCoverageSatang = Value(medicalCoverageSatang),
       annualPremiumSatang = Value(annualPremiumSatang),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InsurancePolicy> custom({
    Expression<String>? id,
    Expression<String>? policyName,
    Expression<String>? insuranceType,
    Expression<int>? sumInsuredSatang,
    Expression<int>? medicalCoverageSatang,
    Expression<int>? annualPremiumSatang,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (policyName != null) 'policy_name': policyName,
      if (insuranceType != null) 'insurance_type': insuranceType,
      if (sumInsuredSatang != null) 'sum_insured_satang': sumInsuredSatang,
      if (medicalCoverageSatang != null)
        'medical_coverage_satang': medicalCoverageSatang,
      if (annualPremiumSatang != null)
        'annual_premium_satang': annualPremiumSatang,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsurancePoliciesCompanion copyWith({
    Value<String>? id,
    Value<String>? policyName,
    Value<String>? insuranceType,
    Value<int>? sumInsuredSatang,
    Value<int>? medicalCoverageSatang,
    Value<int>? annualPremiumSatang,
    Value<DateTime?>? dueDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return InsurancePoliciesCompanion(
      id: id ?? this.id,
      policyName: policyName ?? this.policyName,
      insuranceType: insuranceType ?? this.insuranceType,
      sumInsuredSatang: sumInsuredSatang ?? this.sumInsuredSatang,
      medicalCoverageSatang:
          medicalCoverageSatang ?? this.medicalCoverageSatang,
      annualPremiumSatang: annualPremiumSatang ?? this.annualPremiumSatang,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (policyName.present) {
      map['policy_name'] = Variable<String>(policyName.value);
    }
    if (insuranceType.present) {
      map['insurance_type'] = Variable<String>(insuranceType.value);
    }
    if (sumInsuredSatang.present) {
      map['sum_insured_satang'] = Variable<int>(sumInsuredSatang.value);
    }
    if (medicalCoverageSatang.present) {
      map['medical_coverage_satang'] = Variable<int>(
        medicalCoverageSatang.value,
      );
    }
    if (annualPremiumSatang.present) {
      map['annual_premium_satang'] = Variable<int>(annualPremiumSatang.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsurancePoliciesCompanion(')
          ..write('id: $id, ')
          ..write('policyName: $policyName, ')
          ..write('insuranceType: $insuranceType, ')
          ..write('sumInsuredSatang: $sumInsuredSatang, ')
          ..write('medicalCoverageSatang: $medicalCoverageSatang, ')
          ..write('annualPremiumSatang: $annualPremiumSatang, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _targetBudgetSatangMeta =
      const VerificationMeta('targetBudgetSatang');
  @override
  late final GeneratedColumn<int> targetBudgetSatang = GeneratedColumn<int>(
    'target_budget_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    targetBudgetSatang,
    startDate,
    endDate,
    icon,
    color,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('target_budget_satang')) {
      context.handle(
        _targetBudgetSatangMeta,
        targetBudgetSatang.isAcceptableOrUnknown(
          data['target_budget_satang']!,
          _targetBudgetSatangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetBudgetSatangMeta);
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
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      targetBudgetSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_budget_satang'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? description;
  final int targetBudgetSatang;
  final DateTime startDate;
  final DateTime endDate;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.targetBudgetSatang,
    required this.startDate,
    required this.endDate,
    this.icon,
    this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['target_budget_satang'] = Variable<int>(targetBudgetSatang);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      targetBudgetSatang: Value(targetBudgetSatang),
      startDate: Value(startDate),
      endDate: Value(endDate),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      targetBudgetSatang: serializer.fromJson<int>(json['targetBudgetSatang']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'targetBudgetSatang': serializer.toJson<int>(targetBudgetSatang),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? targetBudgetSatang,
    DateTime? startDate,
    DateTime? endDate,
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    targetBudgetSatang: targetBudgetSatang ?? this.targetBudgetSatang,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      targetBudgetSatang: data.targetBudgetSatang.present
          ? data.targetBudgetSatang.value
          : this.targetBudgetSatang,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('targetBudgetSatang: $targetBudgetSatang, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    targetBudgetSatang,
    startDate,
    endDate,
    icon,
    color,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.targetBudgetSatang == this.targetBudgetSatang &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> targetBudgetSatang;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.targetBudgetSatang = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required int targetBudgetSatang,
    required DateTime startDate,
    required DateTime endDate,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetBudgetSatang = Value(targetBudgetSatang),
       startDate = Value(startDate),
       endDate = Value(endDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? targetBudgetSatang,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (targetBudgetSatang != null)
        'target_budget_satang': targetBudgetSatang,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? targetBudgetSatang,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetBudgetSatang: targetBudgetSatang ?? this.targetBudgetSatang,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetBudgetSatang.present) {
      map['target_budget_satang'] = Variable<int>(targetBudgetSatang.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('targetBudgetSatang: $targetBudgetSatang, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxRulesTable extends TaxRules with TableInfo<$TaxRulesTable, TaxRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxYearMeta = const VerificationMeta(
    'taxYear',
  );
  @override
  late final GeneratedColumn<int> taxYear = GeneratedColumn<int>(
    'tax_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bracketsJsonMeta = const VerificationMeta(
    'bracketsJson',
  );
  @override
  late final GeneratedColumn<String> bracketsJson = GeneratedColumn<String>(
    'brackets_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personalAllowanceSatangMeta =
      const VerificationMeta('personalAllowanceSatang');
  @override
  late final GeneratedColumn<int> personalAllowanceSatang =
      GeneratedColumn<int>(
        'personal_allowance_satang',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(6000000),
      );
  static const VerificationMeta _spouseAllowanceSatangMeta =
      const VerificationMeta('spouseAllowanceSatang');
  @override
  late final GeneratedColumn<int> spouseAllowanceSatang = GeneratedColumn<int>(
    'spouse_allowance_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6000000),
  );
  static const VerificationMeta _childAllowanceSatangMeta =
      const VerificationMeta('childAllowanceSatang');
  @override
  late final GeneratedColumn<int> childAllowanceSatang = GeneratedColumn<int>(
    'child_allowance_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3000000),
  );
  static const VerificationMeta _expenseRatePercentMeta =
      const VerificationMeta('expenseRatePercent');
  @override
  late final GeneratedColumn<String> expenseRatePercent =
      GeneratedColumn<String>(
        'expense_rate_percent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('50.0'),
      );
  static const VerificationMeta _expenseMaxSatangMeta = const VerificationMeta(
    'expenseMaxSatang',
  );
  @override
  late final GeneratedColumn<int> expenseMaxSatang = GeneratedColumn<int>(
    'expense_max_satang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000000),
  );
  static const VerificationMeta _flatExpense406MedicalPercentMeta =
      const VerificationMeta('flatExpense406MedicalPercent');
  @override
  late final GeneratedColumn<String> flatExpense406MedicalPercent =
      GeneratedColumn<String>(
        'flat_expense406_medical_percent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('60.0'),
      );
  static const VerificationMeta _flatExpense408PercentMeta =
      const VerificationMeta('flatExpense408Percent');
  @override
  late final GeneratedColumn<String> flatExpense408Percent =
      GeneratedColumn<String>(
        'flat_expense408_percent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('60.0'),
      );
  static const VerificationMeta _deductionLimitsJsonMeta =
      const VerificationMeta('deductionLimitsJson');
  @override
  late final GeneratedColumn<String> deductionLimitsJson =
      GeneratedColumn<String>(
        'deduction_limits_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _foreignRemittanceRuleJsonMeta =
      const VerificationMeta('foreignRemittanceRuleJson');
  @override
  late final GeneratedColumn<String> foreignRemittanceRuleJson =
      GeneratedColumn<String>(
        'foreign_remittance_rule_json',
        aliasedName,
        false,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taxYear,
    bracketsJson,
    personalAllowanceSatang,
    spouseAllowanceSatang,
    childAllowanceSatang,
    expenseRatePercent,
    expenseMaxSatang,
    flatExpense406MedicalPercent,
    flatExpense408Percent,
    deductionLimitsJson,
    foreignRemittanceRuleJson,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tax_year')) {
      context.handle(
        _taxYearMeta,
        taxYear.isAcceptableOrUnknown(data['tax_year']!, _taxYearMeta),
      );
    } else if (isInserting) {
      context.missing(_taxYearMeta);
    }
    if (data.containsKey('brackets_json')) {
      context.handle(
        _bracketsJsonMeta,
        bracketsJson.isAcceptableOrUnknown(
          data['brackets_json']!,
          _bracketsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bracketsJsonMeta);
    }
    if (data.containsKey('personal_allowance_satang')) {
      context.handle(
        _personalAllowanceSatangMeta,
        personalAllowanceSatang.isAcceptableOrUnknown(
          data['personal_allowance_satang']!,
          _personalAllowanceSatangMeta,
        ),
      );
    }
    if (data.containsKey('spouse_allowance_satang')) {
      context.handle(
        _spouseAllowanceSatangMeta,
        spouseAllowanceSatang.isAcceptableOrUnknown(
          data['spouse_allowance_satang']!,
          _spouseAllowanceSatangMeta,
        ),
      );
    }
    if (data.containsKey('child_allowance_satang')) {
      context.handle(
        _childAllowanceSatangMeta,
        childAllowanceSatang.isAcceptableOrUnknown(
          data['child_allowance_satang']!,
          _childAllowanceSatangMeta,
        ),
      );
    }
    if (data.containsKey('expense_rate_percent')) {
      context.handle(
        _expenseRatePercentMeta,
        expenseRatePercent.isAcceptableOrUnknown(
          data['expense_rate_percent']!,
          _expenseRatePercentMeta,
        ),
      );
    }
    if (data.containsKey('expense_max_satang')) {
      context.handle(
        _expenseMaxSatangMeta,
        expenseMaxSatang.isAcceptableOrUnknown(
          data['expense_max_satang']!,
          _expenseMaxSatangMeta,
        ),
      );
    }
    if (data.containsKey('flat_expense406_medical_percent')) {
      context.handle(
        _flatExpense406MedicalPercentMeta,
        flatExpense406MedicalPercent.isAcceptableOrUnknown(
          data['flat_expense406_medical_percent']!,
          _flatExpense406MedicalPercentMeta,
        ),
      );
    }
    if (data.containsKey('flat_expense408_percent')) {
      context.handle(
        _flatExpense408PercentMeta,
        flatExpense408Percent.isAcceptableOrUnknown(
          data['flat_expense408_percent']!,
          _flatExpense408PercentMeta,
        ),
      );
    }
    if (data.containsKey('deduction_limits_json')) {
      context.handle(
        _deductionLimitsJsonMeta,
        deductionLimitsJson.isAcceptableOrUnknown(
          data['deduction_limits_json']!,
          _deductionLimitsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deductionLimitsJsonMeta);
    }
    if (data.containsKey('foreign_remittance_rule_json')) {
      context.handle(
        _foreignRemittanceRuleJsonMeta,
        foreignRemittanceRuleJson.isAcceptableOrUnknown(
          data['foreign_remittance_rule_json']!,
          _foreignRemittanceRuleJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foreignRemittanceRuleJsonMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taxYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_year'],
      )!,
      bracketsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brackets_json'],
      )!,
      personalAllowanceSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}personal_allowance_satang'],
      )!,
      spouseAllowanceSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spouse_allowance_satang'],
      )!,
      childAllowanceSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_allowance_satang'],
      )!,
      expenseRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_rate_percent'],
      )!,
      expenseMaxSatang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expense_max_satang'],
      )!,
      flatExpense406MedicalPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flat_expense406_medical_percent'],
      )!,
      flatExpense408Percent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flat_expense408_percent'],
      )!,
      deductionLimitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deduction_limits_json'],
      )!,
      foreignRemittanceRuleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foreign_remittance_rule_json'],
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $TaxRulesTable createAlias(String alias) {
    return $TaxRulesTable(attachedDatabase, alias);
  }
}

class TaxRule extends DataClass implements Insertable<TaxRule> {
  final String id;
  final int taxYear;
  final String bracketsJson;
  final int personalAllowanceSatang;
  final int spouseAllowanceSatang;
  final int childAllowanceSatang;
  final String expenseRatePercent;
  final int expenseMaxSatang;
  final String flatExpense406MedicalPercent;
  final String flatExpense408Percent;
  final String deductionLimitsJson;
  final String foreignRemittanceRuleJson;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const TaxRule({
    required this.id,
    required this.taxYear,
    required this.bracketsJson,
    required this.personalAllowanceSatang,
    required this.spouseAllowanceSatang,
    required this.childAllowanceSatang,
    required this.expenseRatePercent,
    required this.expenseMaxSatang,
    required this.flatExpense406MedicalPercent,
    required this.flatExpense408Percent,
    required this.deductionLimitsJson,
    required this.foreignRemittanceRuleJson,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tax_year'] = Variable<int>(taxYear);
    map['brackets_json'] = Variable<String>(bracketsJson);
    map['personal_allowance_satang'] = Variable<int>(personalAllowanceSatang);
    map['spouse_allowance_satang'] = Variable<int>(spouseAllowanceSatang);
    map['child_allowance_satang'] = Variable<int>(childAllowanceSatang);
    map['expense_rate_percent'] = Variable<String>(expenseRatePercent);
    map['expense_max_satang'] = Variable<int>(expenseMaxSatang);
    map['flat_expense406_medical_percent'] = Variable<String>(
      flatExpense406MedicalPercent,
    );
    map['flat_expense408_percent'] = Variable<String>(flatExpense408Percent);
    map['deduction_limits_json'] = Variable<String>(deductionLimitsJson);
    map['foreign_remittance_rule_json'] = Variable<String>(
      foreignRemittanceRuleJson,
    );
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  TaxRulesCompanion toCompanion(bool nullToAbsent) {
    return TaxRulesCompanion(
      id: Value(id),
      taxYear: Value(taxYear),
      bracketsJson: Value(bracketsJson),
      personalAllowanceSatang: Value(personalAllowanceSatang),
      spouseAllowanceSatang: Value(spouseAllowanceSatang),
      childAllowanceSatang: Value(childAllowanceSatang),
      expenseRatePercent: Value(expenseRatePercent),
      expenseMaxSatang: Value(expenseMaxSatang),
      flatExpense406MedicalPercent: Value(flatExpense406MedicalPercent),
      flatExpense408Percent: Value(flatExpense408Percent),
      deductionLimitsJson: Value(deductionLimitsJson),
      foreignRemittanceRuleJson: Value(foreignRemittanceRuleJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory TaxRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxRule(
      id: serializer.fromJson<String>(json['id']),
      taxYear: serializer.fromJson<int>(json['taxYear']),
      bracketsJson: serializer.fromJson<String>(json['bracketsJson']),
      personalAllowanceSatang: serializer.fromJson<int>(
        json['personalAllowanceSatang'],
      ),
      spouseAllowanceSatang: serializer.fromJson<int>(
        json['spouseAllowanceSatang'],
      ),
      childAllowanceSatang: serializer.fromJson<int>(
        json['childAllowanceSatang'],
      ),
      expenseRatePercent: serializer.fromJson<String>(
        json['expenseRatePercent'],
      ),
      expenseMaxSatang: serializer.fromJson<int>(json['expenseMaxSatang']),
      flatExpense406MedicalPercent: serializer.fromJson<String>(
        json['flatExpense406MedicalPercent'],
      ),
      flatExpense408Percent: serializer.fromJson<String>(
        json['flatExpense408Percent'],
      ),
      deductionLimitsJson: serializer.fromJson<String>(
        json['deductionLimitsJson'],
      ),
      foreignRemittanceRuleJson: serializer.fromJson<String>(
        json['foreignRemittanceRuleJson'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taxYear': serializer.toJson<int>(taxYear),
      'bracketsJson': serializer.toJson<String>(bracketsJson),
      'personalAllowanceSatang': serializer.toJson<int>(
        personalAllowanceSatang,
      ),
      'spouseAllowanceSatang': serializer.toJson<int>(spouseAllowanceSatang),
      'childAllowanceSatang': serializer.toJson<int>(childAllowanceSatang),
      'expenseRatePercent': serializer.toJson<String>(expenseRatePercent),
      'expenseMaxSatang': serializer.toJson<int>(expenseMaxSatang),
      'flatExpense406MedicalPercent': serializer.toJson<String>(
        flatExpense406MedicalPercent,
      ),
      'flatExpense408Percent': serializer.toJson<String>(flatExpense408Percent),
      'deductionLimitsJson': serializer.toJson<String>(deductionLimitsJson),
      'foreignRemittanceRuleJson': serializer.toJson<String>(
        foreignRemittanceRuleJson,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  TaxRule copyWith({
    String? id,
    int? taxYear,
    String? bracketsJson,
    int? personalAllowanceSatang,
    int? spouseAllowanceSatang,
    int? childAllowanceSatang,
    String? expenseRatePercent,
    int? expenseMaxSatang,
    String? flatExpense406MedicalPercent,
    String? flatExpense408Percent,
    String? deductionLimitsJson,
    String? foreignRemittanceRuleJson,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => TaxRule(
    id: id ?? this.id,
    taxYear: taxYear ?? this.taxYear,
    bracketsJson: bracketsJson ?? this.bracketsJson,
    personalAllowanceSatang:
        personalAllowanceSatang ?? this.personalAllowanceSatang,
    spouseAllowanceSatang: spouseAllowanceSatang ?? this.spouseAllowanceSatang,
    childAllowanceSatang: childAllowanceSatang ?? this.childAllowanceSatang,
    expenseRatePercent: expenseRatePercent ?? this.expenseRatePercent,
    expenseMaxSatang: expenseMaxSatang ?? this.expenseMaxSatang,
    flatExpense406MedicalPercent:
        flatExpense406MedicalPercent ?? this.flatExpense406MedicalPercent,
    flatExpense408Percent: flatExpense408Percent ?? this.flatExpense408Percent,
    deductionLimitsJson: deductionLimitsJson ?? this.deductionLimitsJson,
    foreignRemittanceRuleJson:
        foreignRemittanceRuleJson ?? this.foreignRemittanceRuleJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  TaxRule copyWithCompanion(TaxRulesCompanion data) {
    return TaxRule(
      id: data.id.present ? data.id.value : this.id,
      taxYear: data.taxYear.present ? data.taxYear.value : this.taxYear,
      bracketsJson: data.bracketsJson.present
          ? data.bracketsJson.value
          : this.bracketsJson,
      personalAllowanceSatang: data.personalAllowanceSatang.present
          ? data.personalAllowanceSatang.value
          : this.personalAllowanceSatang,
      spouseAllowanceSatang: data.spouseAllowanceSatang.present
          ? data.spouseAllowanceSatang.value
          : this.spouseAllowanceSatang,
      childAllowanceSatang: data.childAllowanceSatang.present
          ? data.childAllowanceSatang.value
          : this.childAllowanceSatang,
      expenseRatePercent: data.expenseRatePercent.present
          ? data.expenseRatePercent.value
          : this.expenseRatePercent,
      expenseMaxSatang: data.expenseMaxSatang.present
          ? data.expenseMaxSatang.value
          : this.expenseMaxSatang,
      flatExpense406MedicalPercent: data.flatExpense406MedicalPercent.present
          ? data.flatExpense406MedicalPercent.value
          : this.flatExpense406MedicalPercent,
      flatExpense408Percent: data.flatExpense408Percent.present
          ? data.flatExpense408Percent.value
          : this.flatExpense408Percent,
      deductionLimitsJson: data.deductionLimitsJson.present
          ? data.deductionLimitsJson.value
          : this.deductionLimitsJson,
      foreignRemittanceRuleJson: data.foreignRemittanceRuleJson.present
          ? data.foreignRemittanceRuleJson.value
          : this.foreignRemittanceRuleJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxRule(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('bracketsJson: $bracketsJson, ')
          ..write('personalAllowanceSatang: $personalAllowanceSatang, ')
          ..write('spouseAllowanceSatang: $spouseAllowanceSatang, ')
          ..write('childAllowanceSatang: $childAllowanceSatang, ')
          ..write('expenseRatePercent: $expenseRatePercent, ')
          ..write('expenseMaxSatang: $expenseMaxSatang, ')
          ..write(
            'flatExpense406MedicalPercent: $flatExpense406MedicalPercent, ',
          )
          ..write('flatExpense408Percent: $flatExpense408Percent, ')
          ..write('deductionLimitsJson: $deductionLimitsJson, ')
          ..write('foreignRemittanceRuleJson: $foreignRemittanceRuleJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taxYear,
    bracketsJson,
    personalAllowanceSatang,
    spouseAllowanceSatang,
    childAllowanceSatang,
    expenseRatePercent,
    expenseMaxSatang,
    flatExpense406MedicalPercent,
    flatExpense408Percent,
    deductionLimitsJson,
    foreignRemittanceRuleJson,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxRule &&
          other.id == this.id &&
          other.taxYear == this.taxYear &&
          other.bracketsJson == this.bracketsJson &&
          other.personalAllowanceSatang == this.personalAllowanceSatang &&
          other.spouseAllowanceSatang == this.spouseAllowanceSatang &&
          other.childAllowanceSatang == this.childAllowanceSatang &&
          other.expenseRatePercent == this.expenseRatePercent &&
          other.expenseMaxSatang == this.expenseMaxSatang &&
          other.flatExpense406MedicalPercent ==
              this.flatExpense406MedicalPercent &&
          other.flatExpense408Percent == this.flatExpense408Percent &&
          other.deductionLimitsJson == this.deductionLimitsJson &&
          other.foreignRemittanceRuleJson == this.foreignRemittanceRuleJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class TaxRulesCompanion extends UpdateCompanion<TaxRule> {
  final Value<String> id;
  final Value<int> taxYear;
  final Value<String> bracketsJson;
  final Value<int> personalAllowanceSatang;
  final Value<int> spouseAllowanceSatang;
  final Value<int> childAllowanceSatang;
  final Value<String> expenseRatePercent;
  final Value<int> expenseMaxSatang;
  final Value<String> flatExpense406MedicalPercent;
  final Value<String> flatExpense408Percent;
  final Value<String> deductionLimitsJson;
  final Value<String> foreignRemittanceRuleJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const TaxRulesCompanion({
    this.id = const Value.absent(),
    this.taxYear = const Value.absent(),
    this.bracketsJson = const Value.absent(),
    this.personalAllowanceSatang = const Value.absent(),
    this.spouseAllowanceSatang = const Value.absent(),
    this.childAllowanceSatang = const Value.absent(),
    this.expenseRatePercent = const Value.absent(),
    this.expenseMaxSatang = const Value.absent(),
    this.flatExpense406MedicalPercent = const Value.absent(),
    this.flatExpense408Percent = const Value.absent(),
    this.deductionLimitsJson = const Value.absent(),
    this.foreignRemittanceRuleJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxRulesCompanion.insert({
    required String id,
    required int taxYear,
    required String bracketsJson,
    this.personalAllowanceSatang = const Value.absent(),
    this.spouseAllowanceSatang = const Value.absent(),
    this.childAllowanceSatang = const Value.absent(),
    this.expenseRatePercent = const Value.absent(),
    this.expenseMaxSatang = const Value.absent(),
    this.flatExpense406MedicalPercent = const Value.absent(),
    this.flatExpense408Percent = const Value.absent(),
    required String deductionLimitsJson,
    required String foreignRemittanceRuleJson,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taxYear = Value(taxYear),
       bracketsJson = Value(bracketsJson),
       deductionLimitsJson = Value(deductionLimitsJson),
       foreignRemittanceRuleJson = Value(foreignRemittanceRuleJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaxRule> custom({
    Expression<String>? id,
    Expression<int>? taxYear,
    Expression<String>? bracketsJson,
    Expression<int>? personalAllowanceSatang,
    Expression<int>? spouseAllowanceSatang,
    Expression<int>? childAllowanceSatang,
    Expression<String>? expenseRatePercent,
    Expression<int>? expenseMaxSatang,
    Expression<String>? flatExpense406MedicalPercent,
    Expression<String>? flatExpense408Percent,
    Expression<String>? deductionLimitsJson,
    Expression<String>? foreignRemittanceRuleJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxYear != null) 'tax_year': taxYear,
      if (bracketsJson != null) 'brackets_json': bracketsJson,
      if (personalAllowanceSatang != null)
        'personal_allowance_satang': personalAllowanceSatang,
      if (spouseAllowanceSatang != null)
        'spouse_allowance_satang': spouseAllowanceSatang,
      if (childAllowanceSatang != null)
        'child_allowance_satang': childAllowanceSatang,
      if (expenseRatePercent != null)
        'expense_rate_percent': expenseRatePercent,
      if (expenseMaxSatang != null) 'expense_max_satang': expenseMaxSatang,
      if (flatExpense406MedicalPercent != null)
        'flat_expense406_medical_percent': flatExpense406MedicalPercent,
      if (flatExpense408Percent != null)
        'flat_expense408_percent': flatExpense408Percent,
      if (deductionLimitsJson != null)
        'deduction_limits_json': deductionLimitsJson,
      if (foreignRemittanceRuleJson != null)
        'foreign_remittance_rule_json': foreignRemittanceRuleJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxRulesCompanion copyWith({
    Value<String>? id,
    Value<int>? taxYear,
    Value<String>? bracketsJson,
    Value<int>? personalAllowanceSatang,
    Value<int>? spouseAllowanceSatang,
    Value<int>? childAllowanceSatang,
    Value<String>? expenseRatePercent,
    Value<int>? expenseMaxSatang,
    Value<String>? flatExpense406MedicalPercent,
    Value<String>? flatExpense408Percent,
    Value<String>? deductionLimitsJson,
    Value<String>? foreignRemittanceRuleJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return TaxRulesCompanion(
      id: id ?? this.id,
      taxYear: taxYear ?? this.taxYear,
      bracketsJson: bracketsJson ?? this.bracketsJson,
      personalAllowanceSatang:
          personalAllowanceSatang ?? this.personalAllowanceSatang,
      spouseAllowanceSatang:
          spouseAllowanceSatang ?? this.spouseAllowanceSatang,
      childAllowanceSatang: childAllowanceSatang ?? this.childAllowanceSatang,
      expenseRatePercent: expenseRatePercent ?? this.expenseRatePercent,
      expenseMaxSatang: expenseMaxSatang ?? this.expenseMaxSatang,
      flatExpense406MedicalPercent:
          flatExpense406MedicalPercent ?? this.flatExpense406MedicalPercent,
      flatExpense408Percent:
          flatExpense408Percent ?? this.flatExpense408Percent,
      deductionLimitsJson: deductionLimitsJson ?? this.deductionLimitsJson,
      foreignRemittanceRuleJson:
          foreignRemittanceRuleJson ?? this.foreignRemittanceRuleJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taxYear.present) {
      map['tax_year'] = Variable<int>(taxYear.value);
    }
    if (bracketsJson.present) {
      map['brackets_json'] = Variable<String>(bracketsJson.value);
    }
    if (personalAllowanceSatang.present) {
      map['personal_allowance_satang'] = Variable<int>(
        personalAllowanceSatang.value,
      );
    }
    if (spouseAllowanceSatang.present) {
      map['spouse_allowance_satang'] = Variable<int>(
        spouseAllowanceSatang.value,
      );
    }
    if (childAllowanceSatang.present) {
      map['child_allowance_satang'] = Variable<int>(childAllowanceSatang.value);
    }
    if (expenseRatePercent.present) {
      map['expense_rate_percent'] = Variable<String>(expenseRatePercent.value);
    }
    if (expenseMaxSatang.present) {
      map['expense_max_satang'] = Variable<int>(expenseMaxSatang.value);
    }
    if (flatExpense406MedicalPercent.present) {
      map['flat_expense406_medical_percent'] = Variable<String>(
        flatExpense406MedicalPercent.value,
      );
    }
    if (flatExpense408Percent.present) {
      map['flat_expense408_percent'] = Variable<String>(
        flatExpense408Percent.value,
      );
    }
    if (deductionLimitsJson.present) {
      map['deduction_limits_json'] = Variable<String>(
        deductionLimitsJson.value,
      );
    }
    if (foreignRemittanceRuleJson.present) {
      map['foreign_remittance_rule_json'] = Variable<String>(
        foreignRemittanceRuleJson.value,
      );
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxRulesCompanion(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('bracketsJson: $bracketsJson, ')
          ..write('personalAllowanceSatang: $personalAllowanceSatang, ')
          ..write('spouseAllowanceSatang: $spouseAllowanceSatang, ')
          ..write('childAllowanceSatang: $childAllowanceSatang, ')
          ..write('expenseRatePercent: $expenseRatePercent, ')
          ..write('expenseMaxSatang: $expenseMaxSatang, ')
          ..write(
            'flatExpense406MedicalPercent: $flatExpense406MedicalPercent, ',
          )
          ..write('flatExpense408Percent: $flatExpense408Percent, ')
          ..write('deductionLimitsJson: $deductionLimitsJson, ')
          ..write('foreignRemittanceRuleJson: $foreignRemittanceRuleJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxResidencyRecordsTable extends TaxResidencyRecords
    with TableInfo<$TaxResidencyRecordsTable, TaxResidencyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxResidencyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxYearMeta = const VerificationMeta(
    'taxYear',
  );
  @override
  late final GeneratedColumn<int> taxYear = GeneratedColumn<int>(
    'tax_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysInThailandMeta = const VerificationMeta(
    'daysInThailand',
  );
  @override
  late final GeneratedColumn<int> daysInThailand = GeneratedColumn<int>(
    'days_in_thailand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taxYear,
    daysInThailand,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_residency_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxResidencyRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tax_year')) {
      context.handle(
        _taxYearMeta,
        taxYear.isAcceptableOrUnknown(data['tax_year']!, _taxYearMeta),
      );
    } else if (isInserting) {
      context.missing(_taxYearMeta);
    }
    if (data.containsKey('days_in_thailand')) {
      context.handle(
        _daysInThailandMeta,
        daysInThailand.isAcceptableOrUnknown(
          data['days_in_thailand']!,
          _daysInThailandMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxResidencyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxResidencyRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taxYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_year'],
      )!,
      daysInThailand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_in_thailand'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $TaxResidencyRecordsTable createAlias(String alias) {
    return $TaxResidencyRecordsTable(attachedDatabase, alias);
  }
}

class TaxResidencyRecord extends DataClass
    implements Insertable<TaxResidencyRecord> {
  final String id;
  final int taxYear;
  final int daysInThailand;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const TaxResidencyRecord({
    required this.id,
    required this.taxYear,
    required this.daysInThailand,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tax_year'] = Variable<int>(taxYear);
    map['days_in_thailand'] = Variable<int>(daysInThailand);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  TaxResidencyRecordsCompanion toCompanion(bool nullToAbsent) {
    return TaxResidencyRecordsCompanion(
      id: Value(id),
      taxYear: Value(taxYear),
      daysInThailand: Value(daysInThailand),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory TaxResidencyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxResidencyRecord(
      id: serializer.fromJson<String>(json['id']),
      taxYear: serializer.fromJson<int>(json['taxYear']),
      daysInThailand: serializer.fromJson<int>(json['daysInThailand']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taxYear': serializer.toJson<int>(taxYear),
      'daysInThailand': serializer.toJson<int>(daysInThailand),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  TaxResidencyRecord copyWith({
    String? id,
    int? taxYear,
    int? daysInThailand,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => TaxResidencyRecord(
    id: id ?? this.id,
    taxYear: taxYear ?? this.taxYear,
    daysInThailand: daysInThailand ?? this.daysInThailand,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  TaxResidencyRecord copyWithCompanion(TaxResidencyRecordsCompanion data) {
    return TaxResidencyRecord(
      id: data.id.present ? data.id.value : this.id,
      taxYear: data.taxYear.present ? data.taxYear.value : this.taxYear,
      daysInThailand: data.daysInThailand.present
          ? data.daysInThailand.value
          : this.daysInThailand,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxResidencyRecord(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('daysInThailand: $daysInThailand, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taxYear,
    daysInThailand,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxResidencyRecord &&
          other.id == this.id &&
          other.taxYear == this.taxYear &&
          other.daysInThailand == this.daysInThailand &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class TaxResidencyRecordsCompanion extends UpdateCompanion<TaxResidencyRecord> {
  final Value<String> id;
  final Value<int> taxYear;
  final Value<int> daysInThailand;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const TaxResidencyRecordsCompanion({
    this.id = const Value.absent(),
    this.taxYear = const Value.absent(),
    this.daysInThailand = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxResidencyRecordsCompanion.insert({
    required String id,
    required int taxYear,
    this.daysInThailand = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taxYear = Value(taxYear),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaxResidencyRecord> custom({
    Expression<String>? id,
    Expression<int>? taxYear,
    Expression<int>? daysInThailand,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxYear != null) 'tax_year': taxYear,
      if (daysInThailand != null) 'days_in_thailand': daysInThailand,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxResidencyRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? taxYear,
    Value<int>? daysInThailand,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return TaxResidencyRecordsCompanion(
      id: id ?? this.id,
      taxYear: taxYear ?? this.taxYear,
      daysInThailand: daysInThailand ?? this.daysInThailand,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taxYear.present) {
      map['tax_year'] = Variable<int>(taxYear.value);
    }
    if (daysInThailand.present) {
      map['days_in_thailand'] = Variable<int>(daysInThailand.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxResidencyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('taxYear: $taxYear, ')
          ..write('daysInThailand: $daysInThailand, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateTypeMeta = const VerificationMeta(
    'templateType',
  );
  @override
  late final GeneratedColumn<String> templateType = GeneratedColumn<String>(
    'template_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _totalImportedMeta = const VerificationMeta(
    'totalImported',
  );
  @override
  late final GeneratedColumn<int> totalImported = GeneratedColumn<int>(
    'total_imported',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRolledBackMeta = const VerificationMeta(
    'isRolledBack',
  );
  @override
  late final GeneratedColumn<bool> isRolledBack = GeneratedColumn<bool>(
    'is_rolled_back',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rolled_back" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rolledBackAtMeta = const VerificationMeta(
    'rolledBackAt',
  );
  @override
  late final GeneratedColumn<DateTime> rolledBackAt = GeneratedColumn<DateTime>(
    'rolled_back_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    templateType,
    totalImported,
    importedAt,
    isRolledBack,
    rolledBackAt,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('template_type')) {
      context.handle(
        _templateTypeMeta,
        templateType.isAcceptableOrUnknown(
          data['template_type']!,
          _templateTypeMeta,
        ),
      );
    }
    if (data.containsKey('total_imported')) {
      context.handle(
        _totalImportedMeta,
        totalImported.isAcceptableOrUnknown(
          data['total_imported']!,
          _totalImportedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalImportedMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('is_rolled_back')) {
      context.handle(
        _isRolledBackMeta,
        isRolledBack.isAcceptableOrUnknown(
          data['is_rolled_back']!,
          _isRolledBackMeta,
        ),
      );
    }
    if (data.containsKey('rolled_back_at')) {
      context.handle(
        _rolledBackAtMeta,
        rolledBackAt.isAcceptableOrUnknown(
          data['rolled_back_at']!,
          _rolledBackAtMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      templateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_type'],
      )!,
      totalImported: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_imported'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      isRolledBack: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rolled_back'],
      )!,
      rolledBackAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rolled_back_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatch extends DataClass implements Insertable<ImportBatch> {
  final String id;
  final String fileName;
  final String templateType;
  final int totalImported;
  final DateTime importedAt;
  final bool isRolledBack;
  final DateTime? rolledBackAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const ImportBatch({
    required this.id,
    required this.fileName,
    required this.templateType,
    required this.totalImported,
    required this.importedAt,
    required this.isRolledBack,
    this.rolledBackAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_name'] = Variable<String>(fileName);
    map['template_type'] = Variable<String>(templateType);
    map['total_imported'] = Variable<int>(totalImported);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['is_rolled_back'] = Variable<bool>(isRolledBack);
    if (!nullToAbsent || rolledBackAt != null) {
      map['rolled_back_at'] = Variable<DateTime>(rolledBackAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      fileName: Value(fileName),
      templateType: Value(templateType),
      totalImported: Value(totalImported),
      importedAt: Value(importedAt),
      isRolledBack: Value(isRolledBack),
      rolledBackAt: rolledBackAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rolledBackAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory ImportBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatch(
      id: serializer.fromJson<String>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      templateType: serializer.fromJson<String>(json['templateType']),
      totalImported: serializer.fromJson<int>(json['totalImported']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      isRolledBack: serializer.fromJson<bool>(json['isRolledBack']),
      rolledBackAt: serializer.fromJson<DateTime?>(json['rolledBackAt']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fileName': serializer.toJson<String>(fileName),
      'templateType': serializer.toJson<String>(templateType),
      'totalImported': serializer.toJson<int>(totalImported),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'isRolledBack': serializer.toJson<bool>(isRolledBack),
      'rolledBackAt': serializer.toJson<DateTime?>(rolledBackAt),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  ImportBatch copyWith({
    String? id,
    String? fileName,
    String? templateType,
    int? totalImported,
    DateTime? importedAt,
    bool? isRolledBack,
    Value<DateTime?> rolledBackAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => ImportBatch(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    templateType: templateType ?? this.templateType,
    totalImported: totalImported ?? this.totalImported,
    importedAt: importedAt ?? this.importedAt,
    isRolledBack: isRolledBack ?? this.isRolledBack,
    rolledBackAt: rolledBackAt.present ? rolledBackAt.value : this.rolledBackAt,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  ImportBatch copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatch(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      templateType: data.templateType.present
          ? data.templateType.value
          : this.templateType,
      totalImported: data.totalImported.present
          ? data.totalImported.value
          : this.totalImported,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      isRolledBack: data.isRolledBack.present
          ? data.isRolledBack.value
          : this.isRolledBack,
      rolledBackAt: data.rolledBackAt.present
          ? data.rolledBackAt.value
          : this.rolledBackAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatch(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('templateType: $templateType, ')
          ..write('totalImported: $totalImported, ')
          ..write('importedAt: $importedAt, ')
          ..write('isRolledBack: $isRolledBack, ')
          ..write('rolledBackAt: $rolledBackAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fileName,
    templateType,
    totalImported,
    importedAt,
    isRolledBack,
    rolledBackAt,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatch &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.templateType == this.templateType &&
          other.totalImported == this.totalImported &&
          other.importedAt == this.importedAt &&
          other.isRolledBack == this.isRolledBack &&
          other.rolledBackAt == this.rolledBackAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatch> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<String> templateType;
  final Value<int> totalImported;
  final Value<DateTime> importedAt;
  final Value<bool> isRolledBack;
  final Value<DateTime?> rolledBackAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.templateType = const Value.absent(),
    this.totalImported = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.isRolledBack = const Value.absent(),
    this.rolledBackAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    required String id,
    required String fileName,
    this.templateType = const Value.absent(),
    required int totalImported,
    required DateTime importedAt,
    this.isRolledBack = const Value.absent(),
    this.rolledBackAt = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fileName = Value(fileName),
       totalImported = Value(totalImported),
       importedAt = Value(importedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ImportBatch> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<String>? templateType,
    Expression<int>? totalImported,
    Expression<DateTime>? importedAt,
    Expression<bool>? isRolledBack,
    Expression<DateTime>? rolledBackAt,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (templateType != null) 'template_type': templateType,
      if (totalImported != null) 'total_imported': totalImported,
      if (importedAt != null) 'imported_at': importedAt,
      if (isRolledBack != null) 'is_rolled_back': isRolledBack,
      if (rolledBackAt != null) 'rolled_back_at': rolledBackAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? fileName,
    Value<String>? templateType,
    Value<int>? totalImported,
    Value<DateTime>? importedAt,
    Value<bool>? isRolledBack,
    Value<DateTime?>? rolledBackAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      templateType: templateType ?? this.templateType,
      totalImported: totalImported ?? this.totalImported,
      importedAt: importedAt ?? this.importedAt,
      isRolledBack: isRolledBack ?? this.isRolledBack,
      rolledBackAt: rolledBackAt ?? this.rolledBackAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (templateType.present) {
      map['template_type'] = Variable<String>(templateType.value);
    }
    if (totalImported.present) {
      map['total_imported'] = Variable<int>(totalImported.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (isRolledBack.present) {
      map['is_rolled_back'] = Variable<bool>(isRolledBack.value);
    }
    if (rolledBackAt.present) {
      map['rolled_back_at'] = Variable<DateTime>(rolledBackAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('templateType: $templateType, ')
          ..write('totalImported: $totalImported, ')
          ..write('importedAt: $importedAt, ')
          ..write('isRolledBack: $isRolledBack, ')
          ..write('rolledBackAt: $rolledBackAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictLogsTable extends ConflictLogs
    with TableInfo<$ConflictLogsTable, ConflictLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictTypeMeta = const VerificationMeta(
    'conflictType',
  );
  @override
  late final GeneratedColumn<String> conflictType = GeneratedColumn<String>(
    'conflict_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDataJsonMeta = const VerificationMeta(
    'localDataJson',
  );
  @override
  late final GeneratedColumn<String> localDataJson = GeneratedColumn<String>(
    'local_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteDataJsonMeta = const VerificationMeta(
    'remoteDataJson',
  );
  @override
  late final GeneratedColumn<String> remoteDataJson = GeneratedColumn<String>(
    'remote_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedActionMeta = const VerificationMeta(
    'resolvedAction',
  );
  @override
  late final GeneratedColumn<String> resolvedAction = GeneratedColumn<String>(
    'resolved_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    conflictType,
    localDataJson,
    remoteDataJson,
    resolvedAction,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('conflict_type')) {
      context.handle(
        _conflictTypeMeta,
        conflictType.isAcceptableOrUnknown(
          data['conflict_type']!,
          _conflictTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictTypeMeta);
    }
    if (data.containsKey('local_data_json')) {
      context.handle(
        _localDataJsonMeta,
        localDataJson.isAcceptableOrUnknown(
          data['local_data_json']!,
          _localDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localDataJsonMeta);
    }
    if (data.containsKey('remote_data_json')) {
      context.handle(
        _remoteDataJsonMeta,
        remoteDataJson.isAcceptableOrUnknown(
          data['remote_data_json']!,
          _remoteDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteDataJsonMeta);
    }
    if (data.containsKey('resolved_action')) {
      context.handle(
        _resolvedActionMeta,
        resolvedAction.isAcceptableOrUnknown(
          data['resolved_action']!,
          _resolvedActionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolvedActionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      conflictType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_type'],
      )!,
      localDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_data_json'],
      )!,
      remoteDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_data_json'],
      )!,
      resolvedAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_action'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
    );
  }

  @override
  $ConflictLogsTable createAlias(String alias) {
    return $ConflictLogsTable(attachedDatabase, alias);
  }
}

class ConflictLog extends DataClass implements Insertable<ConflictLog> {
  final String id;
  final String targetTable;
  final String recordId;
  final String conflictType;
  final String localDataJson;
  final String remoteDataJson;
  final String resolvedAction;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncVersion;
  const ConflictLog({
    required this.id,
    required this.targetTable,
    required this.recordId,
    required this.conflictType,
    required this.localDataJson,
    required this.remoteDataJson,
    required this.resolvedAction,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['conflict_type'] = Variable<String>(conflictType);
    map['local_data_json'] = Variable<String>(localDataJson);
    map['remote_data_json'] = Variable<String>(remoteDataJson);
    map['resolved_action'] = Variable<String>(resolvedAction);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  ConflictLogsCompanion toCompanion(bool nullToAbsent) {
    return ConflictLogsCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      conflictType: Value(conflictType),
      localDataJson: Value(localDataJson),
      remoteDataJson: Value(remoteDataJson),
      resolvedAction: Value(resolvedAction),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory ConflictLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictLog(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      conflictType: serializer.fromJson<String>(json['conflictType']),
      localDataJson: serializer.fromJson<String>(json['localDataJson']),
      remoteDataJson: serializer.fromJson<String>(json['remoteDataJson']),
      resolvedAction: serializer.fromJson<String>(json['resolvedAction']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'conflictType': serializer.toJson<String>(conflictType),
      'localDataJson': serializer.toJson<String>(localDataJson),
      'remoteDataJson': serializer.toJson<String>(remoteDataJson),
      'resolvedAction': serializer.toJson<String>(resolvedAction),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  ConflictLog copyWith({
    String? id,
    String? targetTable,
    String? recordId,
    String? conflictType,
    String? localDataJson,
    String? remoteDataJson,
    String? resolvedAction,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncVersion,
  }) => ConflictLog(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    conflictType: conflictType ?? this.conflictType,
    localDataJson: localDataJson ?? this.localDataJson,
    remoteDataJson: remoteDataJson ?? this.remoteDataJson,
    resolvedAction: resolvedAction ?? this.resolvedAction,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncVersion: syncVersion ?? this.syncVersion,
  );
  ConflictLog copyWithCompanion(ConflictLogsCompanion data) {
    return ConflictLog(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      conflictType: data.conflictType.present
          ? data.conflictType.value
          : this.conflictType,
      localDataJson: data.localDataJson.present
          ? data.localDataJson.value
          : this.localDataJson,
      remoteDataJson: data.remoteDataJson.present
          ? data.remoteDataJson.value
          : this.remoteDataJson,
      resolvedAction: data.resolvedAction.present
          ? data.resolvedAction.value
          : this.resolvedAction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLog(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('conflictType: $conflictType, ')
          ..write('localDataJson: $localDataJson, ')
          ..write('remoteDataJson: $remoteDataJson, ')
          ..write('resolvedAction: $resolvedAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    recordId,
    conflictType,
    localDataJson,
    remoteDataJson,
    resolvedAction,
    createdAt,
    updatedAt,
    deletedAt,
    syncVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictLog &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.conflictType == this.conflictType &&
          other.localDataJson == this.localDataJson &&
          other.remoteDataJson == this.remoteDataJson &&
          other.resolvedAction == this.resolvedAction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncVersion == this.syncVersion);
}

class ConflictLogsCompanion extends UpdateCompanion<ConflictLog> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> conflictType;
  final Value<String> localDataJson;
  final Value<String> remoteDataJson;
  final Value<String> resolvedAction;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const ConflictLogsCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.conflictType = const Value.absent(),
    this.localDataJson = const Value.absent(),
    this.remoteDataJson = const Value.absent(),
    this.resolvedAction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictLogsCompanion.insert({
    required String id,
    required String targetTable,
    required String recordId,
    required String conflictType,
    required String localDataJson,
    required String remoteDataJson,
    required String resolvedAction,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       conflictType = Value(conflictType),
       localDataJson = Value(localDataJson),
       remoteDataJson = Value(remoteDataJson),
       resolvedAction = Value(resolvedAction),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ConflictLog> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? conflictType,
    Expression<String>? localDataJson,
    Expression<String>? remoteDataJson,
    Expression<String>? resolvedAction,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (conflictType != null) 'conflict_type': conflictType,
      if (localDataJson != null) 'local_data_json': localDataJson,
      if (remoteDataJson != null) 'remote_data_json': remoteDataJson,
      if (resolvedAction != null) 'resolved_action': resolvedAction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? conflictType,
    Value<String>? localDataJson,
    Value<String>? remoteDataJson,
    Value<String>? resolvedAction,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncVersion,
    Value<int>? rowid,
  }) {
    return ConflictLogsCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      conflictType: conflictType ?? this.conflictType,
      localDataJson: localDataJson ?? this.localDataJson,
      remoteDataJson: remoteDataJson ?? this.remoteDataJson,
      resolvedAction: resolvedAction ?? this.resolvedAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (conflictType.present) {
      map['conflict_type'] = Variable<String>(conflictType.value);
    }
    if (localDataJson.present) {
      map['local_data_json'] = Variable<String>(localDataJson.value);
    }
    if (remoteDataJson.present) {
      map['remote_data_json'] = Variable<String>(remoteDataJson.value);
    }
    if (resolvedAction.present) {
      map['resolved_action'] = Variable<String>(resolvedAction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLogsCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('conflictType: $conflictType, ')
          ..write('localDataJson: $localDataJson, ')
          ..write('remoteDataJson: $remoteDataJson, ')
          ..write('resolvedAction: $resolvedAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $FxRatesTable fxRates = $FxRatesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $CreditCardInstallmentsTable creditCardInstallments =
      $CreditCardInstallmentsTable(this);
  late final $InvestmentLotsTable investmentLots = $InvestmentLotsTable(this);
  late final $InvestmentSalesTable investmentSales = $InvestmentSalesTable(
    this,
  );
  late final $AssetPricesTable assetPrices = $AssetPricesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $TaxDeductionsTable taxDeductions = $TaxDeductionsTable(this);
  late final $ForeignRemittancesTable foreignRemittances =
      $ForeignRemittancesTable(this);
  late final $FinancialHealthSettingsTable financialHealthSettings =
      $FinancialHealthSettingsTable(this);
  late final $BalanceSnapshotsTable balanceSnapshots = $BalanceSnapshotsTable(
    this,
  );
  late final $InvestmentIncomesTable investmentIncomes =
      $InvestmentIncomesTable(this);
  late final $LiabilitiesTable liabilities = $LiabilitiesTable(this);
  late final $InsurancePoliciesTable insurancePolicies =
      $InsurancePoliciesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TaxRulesTable taxRules = $TaxRulesTable(this);
  late final $TaxResidencyRecordsTable taxResidencyRecords =
      $TaxResidencyRecordsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $ConflictLogsTable conflictLogs = $ConflictLogsTable(this);
  late final Index idxTransDate = Index(
    'idx_trans_date',
    'CREATE INDEX idx_trans_date ON transactions (transaction_date)',
  );
  late final Index idxTransSourceAcc = Index(
    'idx_trans_source_acc',
    'CREATE INDEX idx_trans_source_acc ON transactions (source_account_id)',
  );
  late final Index idxTransCategory = Index(
    'idx_trans_category',
    'CREATE INDEX idx_trans_category ON transactions (category_id)',
  );
  late final Index idxTransAsset = Index(
    'idx_trans_asset',
    'CREATE INDEX idx_trans_asset ON transactions (asset_id)',
  );
  late final Index idxTransDeletedAt = Index(
    'idx_trans_deleted_at',
    'CREATE INDEX idx_trans_deleted_at ON transactions (deleted_at)',
  );
  late final Index idxTransImportBatch = Index(
    'idx_trans_import_batch',
    'CREATE INDEX idx_trans_import_batch ON transactions (import_batch_id)',
  );
  late final Index idxLotsAsset = Index(
    'idx_lots_asset',
    'CREATE INDEX idx_lots_asset ON investment_lots (asset_id)',
  );
  late final Index idxSalesLot = Index(
    'idx_sales_lot',
    'CREATE INDEX idx_sales_lot ON investment_sales (lot_id)',
  );
  late final Index idxSnapshotsAccDate = Index(
    'idx_snapshots_acc_date',
    'CREATE INDEX idx_snapshots_acc_date ON balance_snapshots (account_id, snapshot_date)',
  );
  late final Index idxIncomesAsset = Index(
    'idx_incomes_asset',
    'CREATE INDEX idx_incomes_asset ON investment_incomes (asset_id)',
  );
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final CreditCardDao creditCardDao = CreditCardDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final BudgetsDao budgetsDao = BudgetsDao(this as AppDatabase);
  late final InvestmentsDao investmentsDao = InvestmentsDao(
    this as AppDatabase,
  );
  late final LiabilitiesDao liabilitiesDao = LiabilitiesDao(
    this as AppDatabase,
  );
  late final InsuranceDao insuranceDao = InsuranceDao(this as AppDatabase);
  late final RecurringTransactionsDao recurringTransactionsDao =
      RecurringTransactionsDao(this as AppDatabase);
  late final FinancialHealthDao financialHealthDao = FinancialHealthDao(
    this as AppDatabase,
  );
  late final ProjectsDao projectsDao = ProjectsDao(this as AppDatabase);
  late final TaxDao taxDao = TaxDao(this as AppDatabase);
  late final RemittancesDao remittancesDao = RemittancesDao(
    this as AppDatabase,
  );
  late final ImportBatchesDao importBatchesDao = ImportBatchesDao(
    this as AppDatabase,
  );
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    currencies,
    fxRates,
    accounts,
    categories,
    assets,
    transactions,
    auditLogs,
    creditCardInstallments,
    investmentLots,
    investmentSales,
    assetPrices,
    budgets,
    recurringRules,
    taxDeductions,
    foreignRemittances,
    financialHealthSettings,
    balanceSnapshots,
    investmentIncomes,
    liabilities,
    insurancePolicies,
    projects,
    taxRules,
    taxResidencyRecords,
    importBatches,
    conflictLogs,
    idxTransDate,
    idxTransSourceAcc,
    idxTransCategory,
    idxTransAsset,
    idxTransDeletedAt,
    idxTransImportBatch,
    idxLotsAsset,
    idxSalesLot,
    idxSnapshotsAccDate,
    idxIncomesAsset,
  ];
}

typedef $$CurrenciesTableCreateCompanionBuilder =
    CurrenciesCompanion Function({
      required String code,
      required String name,
      required String symbol,
      Value<bool> isBase,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CurrenciesTableUpdateCompanionBuilder =
    CurrenciesCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> symbol,
      Value<bool> isBase,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$CurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBase => $composableBuilder(
    column: $table.isBase,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBase => $composableBuilder(
    column: $table.isBase,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<bool> get isBase =>
      $composableBuilder(column: $table.isBase, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CurrenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrenciesTable,
          Currency,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
          Currency,
          PrefetchHooks Function()
        > {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<bool> isBase = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion(
                code: code,
                name: name,
                symbol: symbol,
                isBase: isBase,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String symbol,
                Value<bool> isBase = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion.insert(
                code: code,
                name: name,
                symbol: symbol,
                isBase: isBase,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrenciesTable,
      Currency,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
      Currency,
      PrefetchHooks Function()
    >;
typedef $$FxRatesTableCreateCompanionBuilder =
    FxRatesCompanion Function({
      required String id,
      required String baseCurrency,
      required String targetCurrency,
      required String rate,
      required DateTime effectiveDate,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$FxRatesTableUpdateCompanionBuilder =
    FxRatesCompanion Function({
      Value<String> id,
      Value<String> baseCurrency,
      Value<String> targetCurrency,
      Value<String> rate,
      Value<DateTime> effectiveDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$FxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTable,
          FxRate,
          $$FxRatesTableFilterComposer,
          $$FxRatesTableOrderingComposer,
          $$FxRatesTableAnnotationComposer,
          $$FxRatesTableCreateCompanionBuilder,
          $$FxRatesTableUpdateCompanionBuilder,
          (FxRate, BaseReferences<_$AppDatabase, $FxRatesTable, FxRate>),
          FxRate,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableManager(_$AppDatabase db, $FxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> targetCurrency = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion(
                id: id,
                baseCurrency: baseCurrency,
                targetCurrency: targetCurrency,
                rate: rate,
                effectiveDate: effectiveDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baseCurrency,
                required String targetCurrency,
                required String rate,
                required DateTime effectiveDate,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion.insert(
                id: id,
                baseCurrency: baseCurrency,
                targetCurrency: targetCurrency,
                rate: rate,
                effectiveDate: effectiveDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTable,
      FxRate,
      $$FxRatesTableFilterComposer,
      $$FxRatesTableOrderingComposer,
      $$FxRatesTableAnnotationComposer,
      $$FxRatesTableCreateCompanionBuilder,
      $$FxRatesTableUpdateCompanionBuilder,
      (FxRate, BaseReferences<_$AppDatabase, $FxRatesTable, FxRate>),
      FxRate,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String name,
      required String accountType,
      required String currencyCode,
      required bool isDomestic,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<int?> creditLimitSatang,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> accountType,
      Value<String> currencyCode,
      Value<bool> isDomestic,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<int?> creditLimitSatang,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDomestic => $composableBuilder(
    column: $table.isDomestic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitSatang => $composableBuilder(
    column: $table.creditLimitSatang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDomestic => $composableBuilder(
    column: $table.isDomestic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitSatang => $composableBuilder(
    column: $table.creditLimitSatang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDomestic => $composableBuilder(
    column: $table.isDomestic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<int> get creditLimitSatang => $composableBuilder(
    column: $table.creditLimitSatang,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> accountType = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<bool> isDomestic = const Value.absent(),
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int?> creditLimitSatang = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                accountType: accountType,
                currencyCode: currencyCode,
                isDomestic: isDomestic,
                closingDay: closingDay,
                dueDay: dueDay,
                creditLimitSatang: creditLimitSatang,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String accountType,
                required String currencyCode,
                required bool isDomestic,
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int?> creditLimitSatang = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                accountType: accountType,
                currencyCode: currencyCode,
                isDomestic: isDomestic,
                closingDay: closingDay,
                dueDay: dueDay,
                creditLimitSatang: creditLimitSatang,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String nameTh,
      required String nameEn,
      required String categoryType,
      Value<String?> parentId,
      Value<String?> taxIncomeType,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isSystem,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> nameTh,
      Value<String> nameEn,
      Value<String> categoryType,
      Value<String?> parentId,
      Value<String?> taxIncomeType,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameTh => $composableBuilder(
    column: $table.nameTh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxIncomeType => $composableBuilder(
    column: $table.taxIncomeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameTh => $composableBuilder(
    column: $table.nameTh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxIncomeType => $composableBuilder(
    column: $table.taxIncomeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameTh =>
      $composableBuilder(column: $table.nameTh, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get taxIncomeType => $composableBuilder(
    column: $table.taxIncomeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
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
                Value<String> id = const Value.absent(),
                Value<String> nameTh = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> taxIncomeType = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                nameTh: nameTh,
                nameEn: nameEn,
                categoryType: categoryType,
                parentId: parentId,
                taxIncomeType: taxIncomeType,
                icon: icon,
                color: color,
                isSystem: isSystem,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameTh,
                required String nameEn,
                required String categoryType,
                Value<String?> parentId = const Value.absent(),
                Value<String?> taxIncomeType = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                nameTh: nameTh,
                nameEn: nameEn,
                categoryType: categoryType,
                parentId: parentId,
                taxIncomeType: taxIncomeType,
                icon: icon,
                color: color,
                isSystem: isSystem,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
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
typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      required String id,
      required String symbol,
      required String name,
      required String assetType,
      required String currencyCode,
      required String defaultAccountId,
      Value<String?> market,
      Value<String?> note,
      Value<String?> extraDetailsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<String> id,
      Value<String> symbol,
      Value<String> name,
      Value<String> assetType,
      Value<String> currencyCode,
      Value<String> defaultAccountId,
      Value<String?> market,
      Value<String?> note,
      Value<String?> extraDetailsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraDetailsJson => $composableBuilder(
    column: $table.extraDetailsJson,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraDetailsJson => $composableBuilder(
    column: $table.extraDetailsJson,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get extraDetailsJson => $composableBuilder(
    column: $table.extraDetailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
          Asset,
          PrefetchHooks Function()
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> assetType = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> defaultAccountId = const Value.absent(),
                Value<String?> market = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> extraDetailsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                symbol: symbol,
                name: name,
                assetType: assetType,
                currencyCode: currencyCode,
                defaultAccountId: defaultAccountId,
                market: market,
                note: note,
                extraDetailsJson: extraDetailsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String symbol,
                required String name,
                required String assetType,
                required String currencyCode,
                required String defaultAccountId,
                Value<String?> market = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> extraDetailsJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                symbol: symbol,
                name: name,
                assetType: assetType,
                currencyCode: currencyCode,
                defaultAccountId: defaultAccountId,
                market: market,
                note: note,
                extraDetailsJson: extraDetailsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
      Asset,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String transactionType,
      Value<String?> sourceAccountId,
      Value<String?> destinationAccountId,
      Value<String?> categoryId,
      Value<String?> assetId,
      Value<String?> importBatchId,
      required int amountOriginalSatang,
      required String currencyCode,
      Value<String> fxRate,
      required int amountThbSatang,
      Value<int> feeThbSatang,
      Value<String?> tag,
      Value<String?> taxCategory,
      Value<int> withholdingTaxSatang,
      required DateTime transactionDate,
      Value<String?> workPeriod,
      Value<int?> expectedAmountSatang,
      Value<String?> note,
      Value<bool> isCleared,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> transactionType,
      Value<String?> sourceAccountId,
      Value<String?> destinationAccountId,
      Value<String?> categoryId,
      Value<String?> assetId,
      Value<String?> importBatchId,
      Value<int> amountOriginalSatang,
      Value<String> currencyCode,
      Value<String> fxRate,
      Value<int> amountThbSatang,
      Value<int> feeThbSatang,
      Value<String?> tag,
      Value<String?> taxCategory,
      Value<int> withholdingTaxSatang,
      Value<DateTime> transactionDate,
      Value<String?> workPeriod,
      Value<int?> expectedAmountSatang,
      Value<String?> note,
      Value<bool> isCleared,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get withholdingTaxSatang => $composableBuilder(
    column: $table.withholdingTaxSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workPeriod => $composableBuilder(
    column: $table.workPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmountSatang => $composableBuilder(
    column: $table.expectedAmountSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCleared => $composableBuilder(
    column: $table.isCleared,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get withholdingTaxSatang => $composableBuilder(
    column: $table.withholdingTaxSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workPeriod => $composableBuilder(
    column: $table.workPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmountSatang => $composableBuilder(
    column: $table.expectedAmountSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCleared => $composableBuilder(
    column: $table.isCleared,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get taxCategory => $composableBuilder(
    column: $table.taxCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get withholdingTaxSatang => $composableBuilder(
    column: $table.withholdingTaxSatang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workPeriod => $composableBuilder(
    column: $table.workPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAmountSatang => $composableBuilder(
    column: $table.expectedAmountSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isCleared =>
      $composableBuilder(column: $table.isCleared, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String?> sourceAccountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                Value<int> amountOriginalSatang = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> fxRate = const Value.absent(),
                Value<int> amountThbSatang = const Value.absent(),
                Value<int> feeThbSatang = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<String?> taxCategory = const Value.absent(),
                Value<int> withholdingTaxSatang = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> workPeriod = const Value.absent(),
                Value<int?> expectedAmountSatang = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isCleared = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                transactionType: transactionType,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                categoryId: categoryId,
                assetId: assetId,
                importBatchId: importBatchId,
                amountOriginalSatang: amountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                amountThbSatang: amountThbSatang,
                feeThbSatang: feeThbSatang,
                tag: tag,
                taxCategory: taxCategory,
                withholdingTaxSatang: withholdingTaxSatang,
                transactionDate: transactionDate,
                workPeriod: workPeriod,
                expectedAmountSatang: expectedAmountSatang,
                note: note,
                isCleared: isCleared,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionType,
                Value<String?> sourceAccountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String?> importBatchId = const Value.absent(),
                required int amountOriginalSatang,
                required String currencyCode,
                Value<String> fxRate = const Value.absent(),
                required int amountThbSatang,
                Value<int> feeThbSatang = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<String?> taxCategory = const Value.absent(),
                Value<int> withholdingTaxSatang = const Value.absent(),
                required DateTime transactionDate,
                Value<String?> workPeriod = const Value.absent(),
                Value<int?> expectedAmountSatang = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isCleared = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                transactionType: transactionType,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                categoryId: categoryId,
                assetId: assetId,
                importBatchId: importBatchId,
                amountOriginalSatang: amountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                amountThbSatang: amountThbSatang,
                feeThbSatang: feeThbSatang,
                tag: tag,
                taxCategory: taxCategory,
                withholdingTaxSatang: withholdingTaxSatang,
                transactionDate: transactionDate,
                workPeriod: workPeriod,
                expectedAmountSatang: expectedAmountSatang,
                note: note,
                isCleared: isCleared,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String entityTable,
      required String entityId,
      required String action,
      Value<String?> beforeDataJson,
      Value<String?> afterDataJson,
      required DateTime changeTimestamp,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> action,
      Value<String?> beforeDataJson,
      Value<String?> afterDataJson,
      Value<DateTime> changeTimestamp,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changeTimestamp => $composableBuilder(
    column: $table.changeTimestamp,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changeTimestamp => $composableBuilder(
    column: $table.changeTimestamp,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changeTimestamp => $composableBuilder(
    column: $table.changeTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> beforeDataJson = const Value.absent(),
                Value<String?> afterDataJson = const Value.absent(),
                Value<DateTime> changeTimestamp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                action: action,
                beforeDataJson: beforeDataJson,
                afterDataJson: afterDataJson,
                changeTimestamp: changeTimestamp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityTable,
                required String entityId,
                required String action,
                Value<String?> beforeDataJson = const Value.absent(),
                Value<String?> afterDataJson = const Value.absent(),
                required DateTime changeTimestamp,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                action: action,
                beforeDataJson: beforeDataJson,
                afterDataJson: afterDataJson,
                changeTimestamp: changeTimestamp,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$CreditCardInstallmentsTableCreateCompanionBuilder =
    CreditCardInstallmentsCompanion Function({
      required String id,
      required String transactionId,
      required String accountId,
      required int totalAmountSatang,
      required int monthlyAmountSatang,
      required int totalTenorMonths,
      required int remainingTenorMonths,
      required DateTime startDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CreditCardInstallmentsTableUpdateCompanionBuilder =
    CreditCardInstallmentsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> accountId,
      Value<int> totalAmountSatang,
      Value<int> monthlyAmountSatang,
      Value<int> totalTenorMonths,
      Value<int> remainingTenorMonths,
      Value<DateTime> startDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$CreditCardInstallmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditCardInstallmentsTable> {
  $$CreditCardInstallmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountSatang => $composableBuilder(
    column: $table.totalAmountSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyAmountSatang => $composableBuilder(
    column: $table.monthlyAmountSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTenorMonths => $composableBuilder(
    column: $table.totalTenorMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingTenorMonths => $composableBuilder(
    column: $table.remainingTenorMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CreditCardInstallmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditCardInstallmentsTable> {
  $$CreditCardInstallmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountSatang => $composableBuilder(
    column: $table.totalAmountSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyAmountSatang => $composableBuilder(
    column: $table.monthlyAmountSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTenorMonths => $composableBuilder(
    column: $table.totalTenorMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingTenorMonths => $composableBuilder(
    column: $table.remainingTenorMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreditCardInstallmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditCardInstallmentsTable> {
  $$CreditCardInstallmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get totalAmountSatang => $composableBuilder(
    column: $table.totalAmountSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyAmountSatang => $composableBuilder(
    column: $table.monthlyAmountSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTenorMonths => $composableBuilder(
    column: $table.totalTenorMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingTenorMonths => $composableBuilder(
    column: $table.remainingTenorMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CreditCardInstallmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreditCardInstallmentsTable,
          CreditCardInstallment,
          $$CreditCardInstallmentsTableFilterComposer,
          $$CreditCardInstallmentsTableOrderingComposer,
          $$CreditCardInstallmentsTableAnnotationComposer,
          $$CreditCardInstallmentsTableCreateCompanionBuilder,
          $$CreditCardInstallmentsTableUpdateCompanionBuilder,
          (
            CreditCardInstallment,
            BaseReferences<
              _$AppDatabase,
              $CreditCardInstallmentsTable,
              CreditCardInstallment
            >,
          ),
          CreditCardInstallment,
          PrefetchHooks Function()
        > {
  $$CreditCardInstallmentsTableTableManager(
    _$AppDatabase db,
    $CreditCardInstallmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardInstallmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CreditCardInstallmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CreditCardInstallmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> totalAmountSatang = const Value.absent(),
                Value<int> monthlyAmountSatang = const Value.absent(),
                Value<int> totalTenorMonths = const Value.absent(),
                Value<int> remainingTenorMonths = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditCardInstallmentsCompanion(
                id: id,
                transactionId: transactionId,
                accountId: accountId,
                totalAmountSatang: totalAmountSatang,
                monthlyAmountSatang: monthlyAmountSatang,
                totalTenorMonths: totalTenorMonths,
                remainingTenorMonths: remainingTenorMonths,
                startDate: startDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String accountId,
                required int totalAmountSatang,
                required int monthlyAmountSatang,
                required int totalTenorMonths,
                required int remainingTenorMonths,
                required DateTime startDate,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreditCardInstallmentsCompanion.insert(
                id: id,
                transactionId: transactionId,
                accountId: accountId,
                totalAmountSatang: totalAmountSatang,
                monthlyAmountSatang: monthlyAmountSatang,
                totalTenorMonths: totalTenorMonths,
                remainingTenorMonths: remainingTenorMonths,
                startDate: startDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CreditCardInstallmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreditCardInstallmentsTable,
      CreditCardInstallment,
      $$CreditCardInstallmentsTableFilterComposer,
      $$CreditCardInstallmentsTableOrderingComposer,
      $$CreditCardInstallmentsTableAnnotationComposer,
      $$CreditCardInstallmentsTableCreateCompanionBuilder,
      $$CreditCardInstallmentsTableUpdateCompanionBuilder,
      (
        CreditCardInstallment,
        BaseReferences<
          _$AppDatabase,
          $CreditCardInstallmentsTable,
          CreditCardInstallment
        >,
      ),
      CreditCardInstallment,
      PrefetchHooks Function()
    >;
typedef $$InvestmentLotsTableCreateCompanionBuilder =
    InvestmentLotsCompanion Function({
      required String id,
      required String assetId,
      required String buyTransactionId,
      required DateTime buyDate,
      required String quantity,
      required String remainingQuantity,
      required int costPerUnitOriginalSatang,
      required String fxRate,
      required int costPerUnitThbSatang,
      required int feeThbSatang,
      Value<int> totalCostThbSatang,
      Value<int> remainingCostThbSatang,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InvestmentLotsTableUpdateCompanionBuilder =
    InvestmentLotsCompanion Function({
      Value<String> id,
      Value<String> assetId,
      Value<String> buyTransactionId,
      Value<DateTime> buyDate,
      Value<String> quantity,
      Value<String> remainingQuantity,
      Value<int> costPerUnitOriginalSatang,
      Value<String> fxRate,
      Value<int> costPerUnitThbSatang,
      Value<int> feeThbSatang,
      Value<int> totalCostThbSatang,
      Value<int> remainingCostThbSatang,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$InvestmentLotsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyTransactionId => $composableBuilder(
    column: $table.buyTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get buyDate => $composableBuilder(
    column: $table.buyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPerUnitOriginalSatang => $composableBuilder(
    column: $table.costPerUnitOriginalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPerUnitThbSatang => $composableBuilder(
    column: $table.costPerUnitThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostThbSatang => $composableBuilder(
    column: $table.totalCostThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingCostThbSatang => $composableBuilder(
    column: $table.remainingCostThbSatang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentLotsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyTransactionId => $composableBuilder(
    column: $table.buyTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get buyDate => $composableBuilder(
    column: $table.buyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPerUnitOriginalSatang => $composableBuilder(
    column: $table.costPerUnitOriginalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPerUnitThbSatang => $composableBuilder(
    column: $table.costPerUnitThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostThbSatang => $composableBuilder(
    column: $table.totalCostThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingCostThbSatang => $composableBuilder(
    column: $table.remainingCostThbSatang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentLotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get buyTransactionId => $composableBuilder(
    column: $table.buyTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get buyDate =>
      $composableBuilder(column: $table.buyDate, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costPerUnitOriginalSatang => $composableBuilder(
    column: $table.costPerUnitOriginalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<int> get costPerUnitThbSatang => $composableBuilder(
    column: $table.costPerUnitThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostThbSatang => $composableBuilder(
    column: $table.totalCostThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingCostThbSatang => $composableBuilder(
    column: $table.remainingCostThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$InvestmentLotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentLotsTable,
          InvestmentLot,
          $$InvestmentLotsTableFilterComposer,
          $$InvestmentLotsTableOrderingComposer,
          $$InvestmentLotsTableAnnotationComposer,
          $$InvestmentLotsTableCreateCompanionBuilder,
          $$InvestmentLotsTableUpdateCompanionBuilder,
          (
            InvestmentLot,
            BaseReferences<_$AppDatabase, $InvestmentLotsTable, InvestmentLot>,
          ),
          InvestmentLot,
          PrefetchHooks Function()
        > {
  $$InvestmentLotsTableTableManager(
    _$AppDatabase db,
    $InvestmentLotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentLotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentLotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentLotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> buyTransactionId = const Value.absent(),
                Value<DateTime> buyDate = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> remainingQuantity = const Value.absent(),
                Value<int> costPerUnitOriginalSatang = const Value.absent(),
                Value<String> fxRate = const Value.absent(),
                Value<int> costPerUnitThbSatang = const Value.absent(),
                Value<int> feeThbSatang = const Value.absent(),
                Value<int> totalCostThbSatang = const Value.absent(),
                Value<int> remainingCostThbSatang = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentLotsCompanion(
                id: id,
                assetId: assetId,
                buyTransactionId: buyTransactionId,
                buyDate: buyDate,
                quantity: quantity,
                remainingQuantity: remainingQuantity,
                costPerUnitOriginalSatang: costPerUnitOriginalSatang,
                fxRate: fxRate,
                costPerUnitThbSatang: costPerUnitThbSatang,
                feeThbSatang: feeThbSatang,
                totalCostThbSatang: totalCostThbSatang,
                remainingCostThbSatang: remainingCostThbSatang,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assetId,
                required String buyTransactionId,
                required DateTime buyDate,
                required String quantity,
                required String remainingQuantity,
                required int costPerUnitOriginalSatang,
                required String fxRate,
                required int costPerUnitThbSatang,
                required int feeThbSatang,
                Value<int> totalCostThbSatang = const Value.absent(),
                Value<int> remainingCostThbSatang = const Value.absent(),
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentLotsCompanion.insert(
                id: id,
                assetId: assetId,
                buyTransactionId: buyTransactionId,
                buyDate: buyDate,
                quantity: quantity,
                remainingQuantity: remainingQuantity,
                costPerUnitOriginalSatang: costPerUnitOriginalSatang,
                fxRate: fxRate,
                costPerUnitThbSatang: costPerUnitThbSatang,
                feeThbSatang: feeThbSatang,
                totalCostThbSatang: totalCostThbSatang,
                remainingCostThbSatang: remainingCostThbSatang,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentLotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentLotsTable,
      InvestmentLot,
      $$InvestmentLotsTableFilterComposer,
      $$InvestmentLotsTableOrderingComposer,
      $$InvestmentLotsTableAnnotationComposer,
      $$InvestmentLotsTableCreateCompanionBuilder,
      $$InvestmentLotsTableUpdateCompanionBuilder,
      (
        InvestmentLot,
        BaseReferences<_$AppDatabase, $InvestmentLotsTable, InvestmentLot>,
      ),
      InvestmentLot,
      PrefetchHooks Function()
    >;
typedef $$InvestmentSalesTableCreateCompanionBuilder =
    InvestmentSalesCompanion Function({
      required String id,
      required String sellTransactionId,
      required String lotId,
      required DateTime sellDate,
      required String quantitySold,
      required int sellPriceThbSatang,
      required int costThbSatang,
      required int realizedGainLossThbSatang,
      Value<int> priceGainLossThbSatang,
      Value<int> fxGainLossThbSatang,
      Value<String> sellFxRate,
      Value<String> buyFxRate,
      required int feeThbSatang,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InvestmentSalesTableUpdateCompanionBuilder =
    InvestmentSalesCompanion Function({
      Value<String> id,
      Value<String> sellTransactionId,
      Value<String> lotId,
      Value<DateTime> sellDate,
      Value<String> quantitySold,
      Value<int> sellPriceThbSatang,
      Value<int> costThbSatang,
      Value<int> realizedGainLossThbSatang,
      Value<int> priceGainLossThbSatang,
      Value<int> fxGainLossThbSatang,
      Value<String> sellFxRate,
      Value<String> buyFxRate,
      Value<int> feeThbSatang,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$InvestmentSalesTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentSalesTable> {
  $$InvestmentSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellTransactionId => $composableBuilder(
    column: $table.sellTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sellDate => $composableBuilder(
    column: $table.sellDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellPriceThbSatang => $composableBuilder(
    column: $table.sellPriceThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costThbSatang => $composableBuilder(
    column: $table.costThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realizedGainLossThbSatang => $composableBuilder(
    column: $table.realizedGainLossThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceGainLossThbSatang => $composableBuilder(
    column: $table.priceGainLossThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fxGainLossThbSatang => $composableBuilder(
    column: $table.fxGainLossThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellFxRate => $composableBuilder(
    column: $table.sellFxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyFxRate => $composableBuilder(
    column: $table.buyFxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentSalesTable> {
  $$InvestmentSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellTransactionId => $composableBuilder(
    column: $table.sellTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sellDate => $composableBuilder(
    column: $table.sellDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellPriceThbSatang => $composableBuilder(
    column: $table.sellPriceThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costThbSatang => $composableBuilder(
    column: $table.costThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realizedGainLossThbSatang => $composableBuilder(
    column: $table.realizedGainLossThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceGainLossThbSatang => $composableBuilder(
    column: $table.priceGainLossThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fxGainLossThbSatang => $composableBuilder(
    column: $table.fxGainLossThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellFxRate => $composableBuilder(
    column: $table.sellFxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyFxRate => $composableBuilder(
    column: $table.buyFxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentSalesTable> {
  $$InvestmentSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sellTransactionId => $composableBuilder(
    column: $table.sellTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<DateTime> get sellDate =>
      $composableBuilder(column: $table.sellDate, builder: (column) => column);

  GeneratedColumn<String> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellPriceThbSatang => $composableBuilder(
    column: $table.sellPriceThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costThbSatang => $composableBuilder(
    column: $table.costThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realizedGainLossThbSatang => $composableBuilder(
    column: $table.realizedGainLossThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceGainLossThbSatang => $composableBuilder(
    column: $table.priceGainLossThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fxGainLossThbSatang => $composableBuilder(
    column: $table.fxGainLossThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sellFxRate => $composableBuilder(
    column: $table.sellFxRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buyFxRate =>
      $composableBuilder(column: $table.buyFxRate, builder: (column) => column);

  GeneratedColumn<int> get feeThbSatang => $composableBuilder(
    column: $table.feeThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$InvestmentSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentSalesTable,
          InvestmentSale,
          $$InvestmentSalesTableFilterComposer,
          $$InvestmentSalesTableOrderingComposer,
          $$InvestmentSalesTableAnnotationComposer,
          $$InvestmentSalesTableCreateCompanionBuilder,
          $$InvestmentSalesTableUpdateCompanionBuilder,
          (
            InvestmentSale,
            BaseReferences<
              _$AppDatabase,
              $InvestmentSalesTable,
              InvestmentSale
            >,
          ),
          InvestmentSale,
          PrefetchHooks Function()
        > {
  $$InvestmentSalesTableTableManager(
    _$AppDatabase db,
    $InvestmentSalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sellTransactionId = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<DateTime> sellDate = const Value.absent(),
                Value<String> quantitySold = const Value.absent(),
                Value<int> sellPriceThbSatang = const Value.absent(),
                Value<int> costThbSatang = const Value.absent(),
                Value<int> realizedGainLossThbSatang = const Value.absent(),
                Value<int> priceGainLossThbSatang = const Value.absent(),
                Value<int> fxGainLossThbSatang = const Value.absent(),
                Value<String> sellFxRate = const Value.absent(),
                Value<String> buyFxRate = const Value.absent(),
                Value<int> feeThbSatang = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentSalesCompanion(
                id: id,
                sellTransactionId: sellTransactionId,
                lotId: lotId,
                sellDate: sellDate,
                quantitySold: quantitySold,
                sellPriceThbSatang: sellPriceThbSatang,
                costThbSatang: costThbSatang,
                realizedGainLossThbSatang: realizedGainLossThbSatang,
                priceGainLossThbSatang: priceGainLossThbSatang,
                fxGainLossThbSatang: fxGainLossThbSatang,
                sellFxRate: sellFxRate,
                buyFxRate: buyFxRate,
                feeThbSatang: feeThbSatang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sellTransactionId,
                required String lotId,
                required DateTime sellDate,
                required String quantitySold,
                required int sellPriceThbSatang,
                required int costThbSatang,
                required int realizedGainLossThbSatang,
                Value<int> priceGainLossThbSatang = const Value.absent(),
                Value<int> fxGainLossThbSatang = const Value.absent(),
                Value<String> sellFxRate = const Value.absent(),
                Value<String> buyFxRate = const Value.absent(),
                required int feeThbSatang,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentSalesCompanion.insert(
                id: id,
                sellTransactionId: sellTransactionId,
                lotId: lotId,
                sellDate: sellDate,
                quantitySold: quantitySold,
                sellPriceThbSatang: sellPriceThbSatang,
                costThbSatang: costThbSatang,
                realizedGainLossThbSatang: realizedGainLossThbSatang,
                priceGainLossThbSatang: priceGainLossThbSatang,
                fxGainLossThbSatang: fxGainLossThbSatang,
                sellFxRate: sellFxRate,
                buyFxRate: buyFxRate,
                feeThbSatang: feeThbSatang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentSalesTable,
      InvestmentSale,
      $$InvestmentSalesTableFilterComposer,
      $$InvestmentSalesTableOrderingComposer,
      $$InvestmentSalesTableAnnotationComposer,
      $$InvestmentSalesTableCreateCompanionBuilder,
      $$InvestmentSalesTableUpdateCompanionBuilder,
      (
        InvestmentSale,
        BaseReferences<_$AppDatabase, $InvestmentSalesTable, InvestmentSale>,
      ),
      InvestmentSale,
      PrefetchHooks Function()
    >;
typedef $$AssetPricesTableCreateCompanionBuilder =
    AssetPricesCompanion Function({
      required String id,
      required String assetId,
      required DateTime priceDate,
      required int marketPriceOriginalSatang,
      required String fxRate,
      required int marketPriceThbSatang,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AssetPricesTableUpdateCompanionBuilder =
    AssetPricesCompanion Function({
      Value<String> id,
      Value<String> assetId,
      Value<DateTime> priceDate,
      Value<int> marketPriceOriginalSatang,
      Value<String> fxRate,
      Value<int> marketPriceThbSatang,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AssetPricesTableFilterComposer
    extends Composer<_$AppDatabase, $AssetPricesTable> {
  $$AssetPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get priceDate => $composableBuilder(
    column: $table.priceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marketPriceOriginalSatang => $composableBuilder(
    column: $table.marketPriceOriginalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marketPriceThbSatang => $composableBuilder(
    column: $table.marketPriceThbSatang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetPricesTable> {
  $$AssetPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get priceDate => $composableBuilder(
    column: $table.priceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marketPriceOriginalSatang => $composableBuilder(
    column: $table.marketPriceOriginalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marketPriceThbSatang => $composableBuilder(
    column: $table.marketPriceThbSatang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetPricesTable> {
  $$AssetPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<DateTime> get priceDate =>
      $composableBuilder(column: $table.priceDate, builder: (column) => column);

  GeneratedColumn<int> get marketPriceOriginalSatang => $composableBuilder(
    column: $table.marketPriceOriginalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<int> get marketPriceThbSatang => $composableBuilder(
    column: $table.marketPriceThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AssetPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetPricesTable,
          AssetPrice,
          $$AssetPricesTableFilterComposer,
          $$AssetPricesTableOrderingComposer,
          $$AssetPricesTableAnnotationComposer,
          $$AssetPricesTableCreateCompanionBuilder,
          $$AssetPricesTableUpdateCompanionBuilder,
          (
            AssetPrice,
            BaseReferences<_$AppDatabase, $AssetPricesTable, AssetPrice>,
          ),
          AssetPrice,
          PrefetchHooks Function()
        > {
  $$AssetPricesTableTableManager(_$AppDatabase db, $AssetPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<DateTime> priceDate = const Value.absent(),
                Value<int> marketPriceOriginalSatang = const Value.absent(),
                Value<String> fxRate = const Value.absent(),
                Value<int> marketPriceThbSatang = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetPricesCompanion(
                id: id,
                assetId: assetId,
                priceDate: priceDate,
                marketPriceOriginalSatang: marketPriceOriginalSatang,
                fxRate: fxRate,
                marketPriceThbSatang: marketPriceThbSatang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assetId,
                required DateTime priceDate,
                required int marketPriceOriginalSatang,
                required String fxRate,
                required int marketPriceThbSatang,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetPricesCompanion.insert(
                id: id,
                assetId: assetId,
                priceDate: priceDate,
                marketPriceOriginalSatang: marketPriceOriginalSatang,
                fxRate: fxRate,
                marketPriceThbSatang: marketPriceThbSatang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetPricesTable,
      AssetPrice,
      $$AssetPricesTableFilterComposer,
      $$AssetPricesTableOrderingComposer,
      $$AssetPricesTableAnnotationComposer,
      $$AssetPricesTableCreateCompanionBuilder,
      $$AssetPricesTableUpdateCompanionBuilder,
      (
        AssetPrice,
        BaseReferences<_$AppDatabase, $AssetPricesTable, AssetPrice>,
      ),
      AssetPrice,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String categoryId,
      required int limitSatang,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<int> limitSatang,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitSatang => $composableBuilder(
    column: $table.limitSatang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitSatang => $composableBuilder(
    column: $table.limitSatang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitSatang => $composableBuilder(
    column: $table.limitSatang,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> limitSatang = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                limitSatang: limitSatang,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required int limitSatang,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                limitSatang: limitSatang,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required String title,
      required String transactionType,
      required String sourceAccountId,
      Value<String?> destinationAccountId,
      Value<String?> categoryId,
      required int amountSatang,
      required String currencyCode,
      required String frequency,
      Value<int?> dayOfMonth,
      required DateTime nextRunDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> intervalUnits,
      Value<bool> autoPost,
      Value<DateTime?> lastPostedDate,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> transactionType,
      Value<String> sourceAccountId,
      Value<String?> destinationAccountId,
      Value<String?> categoryId,
      Value<int> amountSatang,
      Value<String> currencyCode,
      Value<String> frequency,
      Value<int?> dayOfMonth,
      Value<DateTime> nextRunDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> intervalUnits,
      Value<bool> autoPost,
      Value<DateTime?> lastPostedDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalUnits => $composableBuilder(
    column: $table.intervalUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoPost => $composableBuilder(
    column: $table.autoPost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPostedDate => $composableBuilder(
    column: $table.lastPostedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalUnits => $composableBuilder(
    column: $table.intervalUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoPost => $composableBuilder(
    column: $table.autoPost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPostedDate => $composableBuilder(
    column: $table.lastPostedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get intervalUnits => $composableBuilder(
    column: $table.intervalUnits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoPost =>
      $composableBuilder(column: $table.autoPost, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPostedDate => $composableBuilder(
    column: $table.lastPostedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRule,
            BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
          ),
          RecurringRule,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> sourceAccountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> amountSatang = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<DateTime> nextRunDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> intervalUnits = const Value.absent(),
                Value<bool> autoPost = const Value.absent(),
                Value<DateTime?> lastPostedDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                title: title,
                transactionType: transactionType,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                categoryId: categoryId,
                amountSatang: amountSatang,
                currencyCode: currencyCode,
                frequency: frequency,
                dayOfMonth: dayOfMonth,
                nextRunDate: nextRunDate,
                endDate: endDate,
                isActive: isActive,
                intervalUnits: intervalUnits,
                autoPost: autoPost,
                lastPostedDate: lastPostedDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String transactionType,
                required String sourceAccountId,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required int amountSatang,
                required String currencyCode,
                required String frequency,
                Value<int?> dayOfMonth = const Value.absent(),
                required DateTime nextRunDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> intervalUnits = const Value.absent(),
                Value<bool> autoPost = const Value.absent(),
                Value<DateTime?> lastPostedDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                title: title,
                transactionType: transactionType,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                categoryId: categoryId,
                amountSatang: amountSatang,
                currencyCode: currencyCode,
                frequency: frequency,
                dayOfMonth: dayOfMonth,
                nextRunDate: nextRunDate,
                endDate: endDate,
                isActive: isActive,
                intervalUnits: intervalUnits,
                autoPost: autoPost,
                lastPostedDate: lastPostedDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRule,
        BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
      ),
      RecurringRule,
      PrefetchHooks Function()
    >;
typedef $$TaxDeductionsTableCreateCompanionBuilder =
    TaxDeductionsCompanion Function({
      required String id,
      required int taxYear,
      required String deductionGroup,
      required String deductionType,
      required int amountSatang,
      Value<String?> transactionId,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TaxDeductionsTableUpdateCompanionBuilder =
    TaxDeductionsCompanion Function({
      Value<String> id,
      Value<int> taxYear,
      Value<String> deductionGroup,
      Value<String> deductionType,
      Value<int> amountSatang,
      Value<String?> transactionId,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TaxDeductionsTableFilterComposer
    extends Composer<_$AppDatabase, $TaxDeductionsTable> {
  $$TaxDeductionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductionGroup => $composableBuilder(
    column: $table.deductionGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductionType => $composableBuilder(
    column: $table.deductionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxDeductionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxDeductionsTable> {
  $$TaxDeductionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductionGroup => $composableBuilder(
    column: $table.deductionGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductionType => $composableBuilder(
    column: $table.deductionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxDeductionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxDeductionsTable> {
  $$TaxDeductionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taxYear =>
      $composableBuilder(column: $table.taxYear, builder: (column) => column);

  GeneratedColumn<String> get deductionGroup => $composableBuilder(
    column: $table.deductionGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deductionType => $composableBuilder(
    column: $table.deductionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountSatang => $composableBuilder(
    column: $table.amountSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TaxDeductionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxDeductionsTable,
          TaxDeduction,
          $$TaxDeductionsTableFilterComposer,
          $$TaxDeductionsTableOrderingComposer,
          $$TaxDeductionsTableAnnotationComposer,
          $$TaxDeductionsTableCreateCompanionBuilder,
          $$TaxDeductionsTableUpdateCompanionBuilder,
          (
            TaxDeduction,
            BaseReferences<_$AppDatabase, $TaxDeductionsTable, TaxDeduction>,
          ),
          TaxDeduction,
          PrefetchHooks Function()
        > {
  $$TaxDeductionsTableTableManager(_$AppDatabase db, $TaxDeductionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxDeductionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxDeductionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxDeductionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> taxYear = const Value.absent(),
                Value<String> deductionGroup = const Value.absent(),
                Value<String> deductionType = const Value.absent(),
                Value<int> amountSatang = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxDeductionsCompanion(
                id: id,
                taxYear: taxYear,
                deductionGroup: deductionGroup,
                deductionType: deductionType,
                amountSatang: amountSatang,
                transactionId: transactionId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int taxYear,
                required String deductionGroup,
                required String deductionType,
                required int amountSatang,
                Value<String?> transactionId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxDeductionsCompanion.insert(
                id: id,
                taxYear: taxYear,
                deductionGroup: deductionGroup,
                deductionType: deductionType,
                amountSatang: amountSatang,
                transactionId: transactionId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxDeductionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxDeductionsTable,
      TaxDeduction,
      $$TaxDeductionsTableFilterComposer,
      $$TaxDeductionsTableOrderingComposer,
      $$TaxDeductionsTableAnnotationComposer,
      $$TaxDeductionsTableCreateCompanionBuilder,
      $$TaxDeductionsTableUpdateCompanionBuilder,
      (
        TaxDeduction,
        BaseReferences<_$AppDatabase, $TaxDeductionsTable, TaxDeduction>,
      ),
      TaxDeduction,
      PrefetchHooks Function()
    >;
typedef $$ForeignRemittancesTableCreateCompanionBuilder =
    ForeignRemittancesCompanion Function({
      required String id,
      required String remittanceTransactionId,
      required String sourceAccountId,
      Value<String?> destinationAccountId,
      Value<int?> taxYearEarned,
      Value<int?> taxYearRemitted,
      required DateTime remittanceDate,
      Value<String> incomeSourceType,
      Value<bool> isPrincipal,
      required int amountOriginalSatang,
      required String currencyCode,
      required String fxRate,
      required int amountThbSatang,
      Value<bool> isTaxable,
      Value<String?> taxableReason,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ForeignRemittancesTableUpdateCompanionBuilder =
    ForeignRemittancesCompanion Function({
      Value<String> id,
      Value<String> remittanceTransactionId,
      Value<String> sourceAccountId,
      Value<String?> destinationAccountId,
      Value<int?> taxYearEarned,
      Value<int?> taxYearRemitted,
      Value<DateTime> remittanceDate,
      Value<String> incomeSourceType,
      Value<bool> isPrincipal,
      Value<int> amountOriginalSatang,
      Value<String> currencyCode,
      Value<String> fxRate,
      Value<int> amountThbSatang,
      Value<bool> isTaxable,
      Value<String?> taxableReason,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$ForeignRemittancesTableFilterComposer
    extends Composer<_$AppDatabase, $ForeignRemittancesTable> {
  $$ForeignRemittancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remittanceTransactionId => $composableBuilder(
    column: $table.remittanceTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxYearEarned => $composableBuilder(
    column: $table.taxYearEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxYearRemitted => $composableBuilder(
    column: $table.taxYearRemitted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remittanceDate => $composableBuilder(
    column: $table.remittanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeSourceType => $composableBuilder(
    column: $table.incomeSourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrincipal => $composableBuilder(
    column: $table.isPrincipal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTaxable => $composableBuilder(
    column: $table.isTaxable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxableReason => $composableBuilder(
    column: $table.taxableReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ForeignRemittancesTableOrderingComposer
    extends Composer<_$AppDatabase, $ForeignRemittancesTable> {
  $$ForeignRemittancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remittanceTransactionId => $composableBuilder(
    column: $table.remittanceTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxYearEarned => $composableBuilder(
    column: $table.taxYearEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxYearRemitted => $composableBuilder(
    column: $table.taxYearRemitted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remittanceDate => $composableBuilder(
    column: $table.remittanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeSourceType => $composableBuilder(
    column: $table.incomeSourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrincipal => $composableBuilder(
    column: $table.isPrincipal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTaxable => $composableBuilder(
    column: $table.isTaxable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxableReason => $composableBuilder(
    column: $table.taxableReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ForeignRemittancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ForeignRemittancesTable> {
  $$ForeignRemittancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remittanceTransactionId => $composableBuilder(
    column: $table.remittanceTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAccountId => $composableBuilder(
    column: $table.sourceAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxYearEarned => $composableBuilder(
    column: $table.taxYearEarned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxYearRemitted => $composableBuilder(
    column: $table.taxYearRemitted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remittanceDate => $composableBuilder(
    column: $table.remittanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incomeSourceType => $composableBuilder(
    column: $table.incomeSourceType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrincipal => $composableBuilder(
    column: $table.isPrincipal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountOriginalSatang => $composableBuilder(
    column: $table.amountOriginalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<int> get amountThbSatang => $composableBuilder(
    column: $table.amountThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTaxable =>
      $composableBuilder(column: $table.isTaxable, builder: (column) => column);

  GeneratedColumn<String> get taxableReason => $composableBuilder(
    column: $table.taxableReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ForeignRemittancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ForeignRemittancesTable,
          ForeignRemittance,
          $$ForeignRemittancesTableFilterComposer,
          $$ForeignRemittancesTableOrderingComposer,
          $$ForeignRemittancesTableAnnotationComposer,
          $$ForeignRemittancesTableCreateCompanionBuilder,
          $$ForeignRemittancesTableUpdateCompanionBuilder,
          (
            ForeignRemittance,
            BaseReferences<
              _$AppDatabase,
              $ForeignRemittancesTable,
              ForeignRemittance
            >,
          ),
          ForeignRemittance,
          PrefetchHooks Function()
        > {
  $$ForeignRemittancesTableTableManager(
    _$AppDatabase db,
    $ForeignRemittancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForeignRemittancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForeignRemittancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForeignRemittancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> remittanceTransactionId = const Value.absent(),
                Value<String> sourceAccountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<int?> taxYearEarned = const Value.absent(),
                Value<int?> taxYearRemitted = const Value.absent(),
                Value<DateTime> remittanceDate = const Value.absent(),
                Value<String> incomeSourceType = const Value.absent(),
                Value<bool> isPrincipal = const Value.absent(),
                Value<int> amountOriginalSatang = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> fxRate = const Value.absent(),
                Value<int> amountThbSatang = const Value.absent(),
                Value<bool> isTaxable = const Value.absent(),
                Value<String?> taxableReason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForeignRemittancesCompanion(
                id: id,
                remittanceTransactionId: remittanceTransactionId,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                taxYearEarned: taxYearEarned,
                taxYearRemitted: taxYearRemitted,
                remittanceDate: remittanceDate,
                incomeSourceType: incomeSourceType,
                isPrincipal: isPrincipal,
                amountOriginalSatang: amountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                amountThbSatang: amountThbSatang,
                isTaxable: isTaxable,
                taxableReason: taxableReason,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String remittanceTransactionId,
                required String sourceAccountId,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<int?> taxYearEarned = const Value.absent(),
                Value<int?> taxYearRemitted = const Value.absent(),
                required DateTime remittanceDate,
                Value<String> incomeSourceType = const Value.absent(),
                Value<bool> isPrincipal = const Value.absent(),
                required int amountOriginalSatang,
                required String currencyCode,
                required String fxRate,
                required int amountThbSatang,
                Value<bool> isTaxable = const Value.absent(),
                Value<String?> taxableReason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForeignRemittancesCompanion.insert(
                id: id,
                remittanceTransactionId: remittanceTransactionId,
                sourceAccountId: sourceAccountId,
                destinationAccountId: destinationAccountId,
                taxYearEarned: taxYearEarned,
                taxYearRemitted: taxYearRemitted,
                remittanceDate: remittanceDate,
                incomeSourceType: incomeSourceType,
                isPrincipal: isPrincipal,
                amountOriginalSatang: amountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                amountThbSatang: amountThbSatang,
                isTaxable: isTaxable,
                taxableReason: taxableReason,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ForeignRemittancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ForeignRemittancesTable,
      ForeignRemittance,
      $$ForeignRemittancesTableFilterComposer,
      $$ForeignRemittancesTableOrderingComposer,
      $$ForeignRemittancesTableAnnotationComposer,
      $$ForeignRemittancesTableCreateCompanionBuilder,
      $$ForeignRemittancesTableUpdateCompanionBuilder,
      (
        ForeignRemittance,
        BaseReferences<
          _$AppDatabase,
          $ForeignRemittancesTable,
          ForeignRemittance
        >,
      ),
      ForeignRemittance,
      PrefetchHooks Function()
    >;
typedef $$FinancialHealthSettingsTableCreateCompanionBuilder =
    FinancialHealthSettingsCompanion Function({
      required String id,
      required String metricCode,
      required String targetOperator,
      required String targetValue,
      Value<String?> warningValue,
      Value<int?> userParam1Satang,
      Value<int?> userParam2Satang,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$FinancialHealthSettingsTableUpdateCompanionBuilder =
    FinancialHealthSettingsCompanion Function({
      Value<String> id,
      Value<String> metricCode,
      Value<String> targetOperator,
      Value<String> targetValue,
      Value<String?> warningValue,
      Value<int?> userParam1Satang,
      Value<int?> userParam2Satang,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$FinancialHealthSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialHealthSettingsTable> {
  $$FinancialHealthSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetOperator => $composableBuilder(
    column: $table.targetOperator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warningValue => $composableBuilder(
    column: $table.warningValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userParam1Satang => $composableBuilder(
    column: $table.userParam1Satang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userParam2Satang => $composableBuilder(
    column: $table.userParam2Satang,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialHealthSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialHealthSettingsTable> {
  $$FinancialHealthSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetOperator => $composableBuilder(
    column: $table.targetOperator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warningValue => $composableBuilder(
    column: $table.warningValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userParam1Satang => $composableBuilder(
    column: $table.userParam1Satang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userParam2Satang => $composableBuilder(
    column: $table.userParam2Satang,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialHealthSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialHealthSettingsTable> {
  $$FinancialHealthSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetOperator => $composableBuilder(
    column: $table.targetOperator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warningValue => $composableBuilder(
    column: $table.warningValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userParam1Satang => $composableBuilder(
    column: $table.userParam1Satang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userParam2Satang => $composableBuilder(
    column: $table.userParam2Satang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FinancialHealthSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialHealthSettingsTable,
          FinancialHealthSetting,
          $$FinancialHealthSettingsTableFilterComposer,
          $$FinancialHealthSettingsTableOrderingComposer,
          $$FinancialHealthSettingsTableAnnotationComposer,
          $$FinancialHealthSettingsTableCreateCompanionBuilder,
          $$FinancialHealthSettingsTableUpdateCompanionBuilder,
          (
            FinancialHealthSetting,
            BaseReferences<
              _$AppDatabase,
              $FinancialHealthSettingsTable,
              FinancialHealthSetting
            >,
          ),
          FinancialHealthSetting,
          PrefetchHooks Function()
        > {
  $$FinancialHealthSettingsTableTableManager(
    _$AppDatabase db,
    $FinancialHealthSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialHealthSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FinancialHealthSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FinancialHealthSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> metricCode = const Value.absent(),
                Value<String> targetOperator = const Value.absent(),
                Value<String> targetValue = const Value.absent(),
                Value<String?> warningValue = const Value.absent(),
                Value<int?> userParam1Satang = const Value.absent(),
                Value<int?> userParam2Satang = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialHealthSettingsCompanion(
                id: id,
                metricCode: metricCode,
                targetOperator: targetOperator,
                targetValue: targetValue,
                warningValue: warningValue,
                userParam1Satang: userParam1Satang,
                userParam2Satang: userParam2Satang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String metricCode,
                required String targetOperator,
                required String targetValue,
                Value<String?> warningValue = const Value.absent(),
                Value<int?> userParam1Satang = const Value.absent(),
                Value<int?> userParam2Satang = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialHealthSettingsCompanion.insert(
                id: id,
                metricCode: metricCode,
                targetOperator: targetOperator,
                targetValue: targetValue,
                warningValue: warningValue,
                userParam1Satang: userParam1Satang,
                userParam2Satang: userParam2Satang,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialHealthSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialHealthSettingsTable,
      FinancialHealthSetting,
      $$FinancialHealthSettingsTableFilterComposer,
      $$FinancialHealthSettingsTableOrderingComposer,
      $$FinancialHealthSettingsTableAnnotationComposer,
      $$FinancialHealthSettingsTableCreateCompanionBuilder,
      $$FinancialHealthSettingsTableUpdateCompanionBuilder,
      (
        FinancialHealthSetting,
        BaseReferences<
          _$AppDatabase,
          $FinancialHealthSettingsTable,
          FinancialHealthSetting
        >,
      ),
      FinancialHealthSetting,
      PrefetchHooks Function()
    >;
typedef $$BalanceSnapshotsTableCreateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      required String id,
      required String accountId,
      required DateTime snapshotDate,
      required int closingBalanceSatang,
      required String currencyCode,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BalanceSnapshotsTableUpdateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<DateTime> snapshotDate,
      Value<int> closingBalanceSatang,
      Value<String> currencyCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BalanceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingBalanceSatang => $composableBuilder(
    column: $table.closingBalanceSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
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

class $$BalanceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingBalanceSatang => $composableBuilder(
    column: $table.closingBalanceSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
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

class $$BalanceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingBalanceSatang => $composableBuilder(
    column: $table.closingBalanceSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BalanceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshot,
          $$BalanceSnapshotsTableFilterComposer,
          $$BalanceSnapshotsTableOrderingComposer,
          $$BalanceSnapshotsTableAnnotationComposer,
          $$BalanceSnapshotsTableCreateCompanionBuilder,
          $$BalanceSnapshotsTableUpdateCompanionBuilder,
          (
            BalanceSnapshot,
            BaseReferences<
              _$AppDatabase,
              $BalanceSnapshotsTable,
              BalanceSnapshot
            >,
          ),
          BalanceSnapshot,
          PrefetchHooks Function()
        > {
  $$BalanceSnapshotsTableTableManager(
    _$AppDatabase db,
    $BalanceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime> snapshotDate = const Value.absent(),
                Value<int> closingBalanceSatang = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion(
                id: id,
                accountId: accountId,
                snapshotDate: snapshotDate,
                closingBalanceSatang: closingBalanceSatang,
                currencyCode: currencyCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required DateTime snapshotDate,
                required int closingBalanceSatang,
                required String currencyCode,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion.insert(
                id: id,
                accountId: accountId,
                snapshotDate: snapshotDate,
                closingBalanceSatang: closingBalanceSatang,
                currencyCode: currencyCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BalanceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceSnapshotsTable,
      BalanceSnapshot,
      $$BalanceSnapshotsTableFilterComposer,
      $$BalanceSnapshotsTableOrderingComposer,
      $$BalanceSnapshotsTableAnnotationComposer,
      $$BalanceSnapshotsTableCreateCompanionBuilder,
      $$BalanceSnapshotsTableUpdateCompanionBuilder,
      (
        BalanceSnapshot,
        BaseReferences<_$AppDatabase, $BalanceSnapshotsTable, BalanceSnapshot>,
      ),
      BalanceSnapshot,
      PrefetchHooks Function()
    >;
typedef $$InvestmentIncomesTableCreateCompanionBuilder =
    InvestmentIncomesCompanion Function({
      required String id,
      required String transactionId,
      required String assetId,
      required String incomeType,
      required int grossAmountOriginalSatang,
      required String currencyCode,
      required String fxRate,
      required int grossAmountThbSatang,
      Value<int> withholdingTaxThbSatang,
      Value<int> dividendTaxCreditSatang,
      required int netAmountThbSatang,
      Value<bool> isForeignIncome,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InvestmentIncomesTableUpdateCompanionBuilder =
    InvestmentIncomesCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> assetId,
      Value<String> incomeType,
      Value<int> grossAmountOriginalSatang,
      Value<String> currencyCode,
      Value<String> fxRate,
      Value<int> grossAmountThbSatang,
      Value<int> withholdingTaxThbSatang,
      Value<int> dividendTaxCreditSatang,
      Value<int> netAmountThbSatang,
      Value<bool> isForeignIncome,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$InvestmentIncomesTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentIncomesTable> {
  $$InvestmentIncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossAmountOriginalSatang => $composableBuilder(
    column: $table.grossAmountOriginalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossAmountThbSatang => $composableBuilder(
    column: $table.grossAmountThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get withholdingTaxThbSatang => $composableBuilder(
    column: $table.withholdingTaxThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dividendTaxCreditSatang => $composableBuilder(
    column: $table.dividendTaxCreditSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netAmountThbSatang => $composableBuilder(
    column: $table.netAmountThbSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isForeignIncome => $composableBuilder(
    column: $table.isForeignIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentIncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentIncomesTable> {
  $$InvestmentIncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossAmountOriginalSatang => $composableBuilder(
    column: $table.grossAmountOriginalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossAmountThbSatang => $composableBuilder(
    column: $table.grossAmountThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get withholdingTaxThbSatang => $composableBuilder(
    column: $table.withholdingTaxThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dividendTaxCreditSatang => $composableBuilder(
    column: $table.dividendTaxCreditSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netAmountThbSatang => $composableBuilder(
    column: $table.netAmountThbSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isForeignIncome => $composableBuilder(
    column: $table.isForeignIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentIncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentIncomesTable> {
  $$InvestmentIncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get incomeType => $composableBuilder(
    column: $table.incomeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossAmountOriginalSatang => $composableBuilder(
    column: $table.grossAmountOriginalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<int> get grossAmountThbSatang => $composableBuilder(
    column: $table.grossAmountThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get withholdingTaxThbSatang => $composableBuilder(
    column: $table.withholdingTaxThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dividendTaxCreditSatang => $composableBuilder(
    column: $table.dividendTaxCreditSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netAmountThbSatang => $composableBuilder(
    column: $table.netAmountThbSatang,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isForeignIncome => $composableBuilder(
    column: $table.isForeignIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$InvestmentIncomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentIncomesTable,
          InvestmentIncome,
          $$InvestmentIncomesTableFilterComposer,
          $$InvestmentIncomesTableOrderingComposer,
          $$InvestmentIncomesTableAnnotationComposer,
          $$InvestmentIncomesTableCreateCompanionBuilder,
          $$InvestmentIncomesTableUpdateCompanionBuilder,
          (
            InvestmentIncome,
            BaseReferences<
              _$AppDatabase,
              $InvestmentIncomesTable,
              InvestmentIncome
            >,
          ),
          InvestmentIncome,
          PrefetchHooks Function()
        > {
  $$InvestmentIncomesTableTableManager(
    _$AppDatabase db,
    $InvestmentIncomesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentIncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentIncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentIncomesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> incomeType = const Value.absent(),
                Value<int> grossAmountOriginalSatang = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> fxRate = const Value.absent(),
                Value<int> grossAmountThbSatang = const Value.absent(),
                Value<int> withholdingTaxThbSatang = const Value.absent(),
                Value<int> dividendTaxCreditSatang = const Value.absent(),
                Value<int> netAmountThbSatang = const Value.absent(),
                Value<bool> isForeignIncome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentIncomesCompanion(
                id: id,
                transactionId: transactionId,
                assetId: assetId,
                incomeType: incomeType,
                grossAmountOriginalSatang: grossAmountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                grossAmountThbSatang: grossAmountThbSatang,
                withholdingTaxThbSatang: withholdingTaxThbSatang,
                dividendTaxCreditSatang: dividendTaxCreditSatang,
                netAmountThbSatang: netAmountThbSatang,
                isForeignIncome: isForeignIncome,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String assetId,
                required String incomeType,
                required int grossAmountOriginalSatang,
                required String currencyCode,
                required String fxRate,
                required int grossAmountThbSatang,
                Value<int> withholdingTaxThbSatang = const Value.absent(),
                Value<int> dividendTaxCreditSatang = const Value.absent(),
                required int netAmountThbSatang,
                Value<bool> isForeignIncome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentIncomesCompanion.insert(
                id: id,
                transactionId: transactionId,
                assetId: assetId,
                incomeType: incomeType,
                grossAmountOriginalSatang: grossAmountOriginalSatang,
                currencyCode: currencyCode,
                fxRate: fxRate,
                grossAmountThbSatang: grossAmountThbSatang,
                withholdingTaxThbSatang: withholdingTaxThbSatang,
                dividendTaxCreditSatang: dividendTaxCreditSatang,
                netAmountThbSatang: netAmountThbSatang,
                isForeignIncome: isForeignIncome,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentIncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentIncomesTable,
      InvestmentIncome,
      $$InvestmentIncomesTableFilterComposer,
      $$InvestmentIncomesTableOrderingComposer,
      $$InvestmentIncomesTableAnnotationComposer,
      $$InvestmentIncomesTableCreateCompanionBuilder,
      $$InvestmentIncomesTableUpdateCompanionBuilder,
      (
        InvestmentIncome,
        BaseReferences<
          _$AppDatabase,
          $InvestmentIncomesTable,
          InvestmentIncome
        >,
      ),
      InvestmentIncome,
      PrefetchHooks Function()
    >;
typedef $$LiabilitiesTableCreateCompanionBuilder =
    LiabilitiesCompanion Function({
      required String id,
      required String name,
      required String liabilityType,
      required int remainingPrincipalSatang,
      required int monthlyPaymentSatang,
      required String interestRatePercent,
      required bool isShortTerm,
      Value<String?> linkedAccountId,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$LiabilitiesTableUpdateCompanionBuilder =
    LiabilitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> liabilityType,
      Value<int> remainingPrincipalSatang,
      Value<int> monthlyPaymentSatang,
      Value<String> interestRatePercent,
      Value<bool> isShortTerm,
      Value<String?> linkedAccountId,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$LiabilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LiabilitiesTable> {
  $$LiabilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liabilityType => $composableBuilder(
    column: $table.liabilityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingPrincipalSatang => $composableBuilder(
    column: $table.remainingPrincipalSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyPaymentSatang => $composableBuilder(
    column: $table.monthlyPaymentSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShortTerm => $composableBuilder(
    column: $table.isShortTerm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiabilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LiabilitiesTable> {
  $$LiabilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liabilityType => $composableBuilder(
    column: $table.liabilityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingPrincipalSatang => $composableBuilder(
    column: $table.remainingPrincipalSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyPaymentSatang => $composableBuilder(
    column: $table.monthlyPaymentSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShortTerm => $composableBuilder(
    column: $table.isShortTerm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiabilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiabilitiesTable> {
  $$LiabilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get liabilityType => $composableBuilder(
    column: $table.liabilityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingPrincipalSatang => $composableBuilder(
    column: $table.remainingPrincipalSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyPaymentSatang => $composableBuilder(
    column: $table.monthlyPaymentSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestRatePercent => $composableBuilder(
    column: $table.interestRatePercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShortTerm => $composableBuilder(
    column: $table.isShortTerm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$LiabilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiabilitiesTable,
          Liability,
          $$LiabilitiesTableFilterComposer,
          $$LiabilitiesTableOrderingComposer,
          $$LiabilitiesTableAnnotationComposer,
          $$LiabilitiesTableCreateCompanionBuilder,
          $$LiabilitiesTableUpdateCompanionBuilder,
          (
            Liability,
            BaseReferences<_$AppDatabase, $LiabilitiesTable, Liability>,
          ),
          Liability,
          PrefetchHooks Function()
        > {
  $$LiabilitiesTableTableManager(_$AppDatabase db, $LiabilitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiabilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiabilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiabilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> liabilityType = const Value.absent(),
                Value<int> remainingPrincipalSatang = const Value.absent(),
                Value<int> monthlyPaymentSatang = const Value.absent(),
                Value<String> interestRatePercent = const Value.absent(),
                Value<bool> isShortTerm = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiabilitiesCompanion(
                id: id,
                name: name,
                liabilityType: liabilityType,
                remainingPrincipalSatang: remainingPrincipalSatang,
                monthlyPaymentSatang: monthlyPaymentSatang,
                interestRatePercent: interestRatePercent,
                isShortTerm: isShortTerm,
                linkedAccountId: linkedAccountId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String liabilityType,
                required int remainingPrincipalSatang,
                required int monthlyPaymentSatang,
                required String interestRatePercent,
                required bool isShortTerm,
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LiabilitiesCompanion.insert(
                id: id,
                name: name,
                liabilityType: liabilityType,
                remainingPrincipalSatang: remainingPrincipalSatang,
                monthlyPaymentSatang: monthlyPaymentSatang,
                interestRatePercent: interestRatePercent,
                isShortTerm: isShortTerm,
                linkedAccountId: linkedAccountId,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiabilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiabilitiesTable,
      Liability,
      $$LiabilitiesTableFilterComposer,
      $$LiabilitiesTableOrderingComposer,
      $$LiabilitiesTableAnnotationComposer,
      $$LiabilitiesTableCreateCompanionBuilder,
      $$LiabilitiesTableUpdateCompanionBuilder,
      (Liability, BaseReferences<_$AppDatabase, $LiabilitiesTable, Liability>),
      Liability,
      PrefetchHooks Function()
    >;
typedef $$InsurancePoliciesTableCreateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      required String id,
      required String policyName,
      required String insuranceType,
      required int sumInsuredSatang,
      required int medicalCoverageSatang,
      required int annualPremiumSatang,
      Value<DateTime?> dueDate,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$InsurancePoliciesTableUpdateCompanionBuilder =
    InsurancePoliciesCompanion Function({
      Value<String> id,
      Value<String> policyName,
      Value<String> insuranceType,
      Value<int> sumInsuredSatang,
      Value<int> medicalCoverageSatang,
      Value<int> annualPremiumSatang,
      Value<DateTime?> dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$InsurancePoliciesTableFilterComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyName => $composableBuilder(
    column: $table.policyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceType => $composableBuilder(
    column: $table.insuranceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sumInsuredSatang => $composableBuilder(
    column: $table.sumInsuredSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get medicalCoverageSatang => $composableBuilder(
    column: $table.medicalCoverageSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualPremiumSatang => $composableBuilder(
    column: $table.annualPremiumSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsurancePoliciesTableOrderingComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyName => $composableBuilder(
    column: $table.policyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceType => $composableBuilder(
    column: $table.insuranceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sumInsuredSatang => $composableBuilder(
    column: $table.sumInsuredSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get medicalCoverageSatang => $composableBuilder(
    column: $table.medicalCoverageSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualPremiumSatang => $composableBuilder(
    column: $table.annualPremiumSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsurancePoliciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsurancePoliciesTable> {
  $$InsurancePoliciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get policyName => $composableBuilder(
    column: $table.policyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceType => $composableBuilder(
    column: $table.insuranceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sumInsuredSatang => $composableBuilder(
    column: $table.sumInsuredSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get medicalCoverageSatang => $composableBuilder(
    column: $table.medicalCoverageSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annualPremiumSatang => $composableBuilder(
    column: $table.annualPremiumSatang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$InsurancePoliciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsurancePoliciesTable,
          InsurancePolicy,
          $$InsurancePoliciesTableFilterComposer,
          $$InsurancePoliciesTableOrderingComposer,
          $$InsurancePoliciesTableAnnotationComposer,
          $$InsurancePoliciesTableCreateCompanionBuilder,
          $$InsurancePoliciesTableUpdateCompanionBuilder,
          (
            InsurancePolicy,
            BaseReferences<
              _$AppDatabase,
              $InsurancePoliciesTable,
              InsurancePolicy
            >,
          ),
          InsurancePolicy,
          PrefetchHooks Function()
        > {
  $$InsurancePoliciesTableTableManager(
    _$AppDatabase db,
    $InsurancePoliciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsurancePoliciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsurancePoliciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsurancePoliciesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> policyName = const Value.absent(),
                Value<String> insuranceType = const Value.absent(),
                Value<int> sumInsuredSatang = const Value.absent(),
                Value<int> medicalCoverageSatang = const Value.absent(),
                Value<int> annualPremiumSatang = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion(
                id: id,
                policyName: policyName,
                insuranceType: insuranceType,
                sumInsuredSatang: sumInsuredSatang,
                medicalCoverageSatang: medicalCoverageSatang,
                annualPremiumSatang: annualPremiumSatang,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String policyName,
                required String insuranceType,
                required int sumInsuredSatang,
                required int medicalCoverageSatang,
                required int annualPremiumSatang,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancePoliciesCompanion.insert(
                id: id,
                policyName: policyName,
                insuranceType: insuranceType,
                sumInsuredSatang: sumInsuredSatang,
                medicalCoverageSatang: medicalCoverageSatang,
                annualPremiumSatang: annualPremiumSatang,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsurancePoliciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsurancePoliciesTable,
      InsurancePolicy,
      $$InsurancePoliciesTableFilterComposer,
      $$InsurancePoliciesTableOrderingComposer,
      $$InsurancePoliciesTableAnnotationComposer,
      $$InsurancePoliciesTableCreateCompanionBuilder,
      $$InsurancePoliciesTableUpdateCompanionBuilder,
      (
        InsurancePolicy,
        BaseReferences<_$AppDatabase, $InsurancePoliciesTable, InsurancePolicy>,
      ),
      InsurancePolicy,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required int targetBudgetSatang,
      required DateTime startDate,
      required DateTime endDate,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> targetBudgetSatang,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<int> get targetBudgetSatang => $composableBuilder(
    column: $table.targetBudgetSatang,
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<int> get targetBudgetSatang => $composableBuilder(
    column: $table.targetBudgetSatang,
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetBudgetSatang => $composableBuilder(
    column: $table.targetBudgetSatang,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> targetBudgetSatang = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                description: description,
                targetBudgetSatang: targetBudgetSatang,
                startDate: startDate,
                endDate: endDate,
                icon: icon,
                color: color,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required int targetBudgetSatang,
                required DateTime startDate,
                required DateTime endDate,
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                description: description,
                targetBudgetSatang: targetBudgetSatang,
                startDate: startDate,
                endDate: endDate,
                icon: icon,
                color: color,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$TaxRulesTableCreateCompanionBuilder =
    TaxRulesCompanion Function({
      required String id,
      required int taxYear,
      required String bracketsJson,
      Value<int> personalAllowanceSatang,
      Value<int> spouseAllowanceSatang,
      Value<int> childAllowanceSatang,
      Value<String> expenseRatePercent,
      Value<int> expenseMaxSatang,
      Value<String> flatExpense406MedicalPercent,
      Value<String> flatExpense408Percent,
      required String deductionLimitsJson,
      required String foreignRemittanceRuleJson,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$TaxRulesTableUpdateCompanionBuilder =
    TaxRulesCompanion Function({
      Value<String> id,
      Value<int> taxYear,
      Value<String> bracketsJson,
      Value<int> personalAllowanceSatang,
      Value<int> spouseAllowanceSatang,
      Value<int> childAllowanceSatang,
      Value<String> expenseRatePercent,
      Value<int> expenseMaxSatang,
      Value<String> flatExpense406MedicalPercent,
      Value<String> flatExpense408Percent,
      Value<String> deductionLimitsJson,
      Value<String> foreignRemittanceRuleJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$TaxRulesTableFilterComposer
    extends Composer<_$AppDatabase, $TaxRulesTable> {
  $$TaxRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracketsJson => $composableBuilder(
    column: $table.bracketsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personalAllowanceSatang => $composableBuilder(
    column: $table.personalAllowanceSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spouseAllowanceSatang => $composableBuilder(
    column: $table.spouseAllowanceSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childAllowanceSatang => $composableBuilder(
    column: $table.childAllowanceSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseRatePercent => $composableBuilder(
    column: $table.expenseRatePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expenseMaxSatang => $composableBuilder(
    column: $table.expenseMaxSatang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flatExpense406MedicalPercent => $composableBuilder(
    column: $table.flatExpense406MedicalPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flatExpense408Percent => $composableBuilder(
    column: $table.flatExpense408Percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deductionLimitsJson => $composableBuilder(
    column: $table.deductionLimitsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foreignRemittanceRuleJson => $composableBuilder(
    column: $table.foreignRemittanceRuleJson,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxRulesTable> {
  $$TaxRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracketsJson => $composableBuilder(
    column: $table.bracketsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personalAllowanceSatang => $composableBuilder(
    column: $table.personalAllowanceSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spouseAllowanceSatang => $composableBuilder(
    column: $table.spouseAllowanceSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childAllowanceSatang => $composableBuilder(
    column: $table.childAllowanceSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseRatePercent => $composableBuilder(
    column: $table.expenseRatePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expenseMaxSatang => $composableBuilder(
    column: $table.expenseMaxSatang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flatExpense406MedicalPercent =>
      $composableBuilder(
        column: $table.flatExpense406MedicalPercent,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get flatExpense408Percent => $composableBuilder(
    column: $table.flatExpense408Percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deductionLimitsJson => $composableBuilder(
    column: $table.deductionLimitsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foreignRemittanceRuleJson => $composableBuilder(
    column: $table.foreignRemittanceRuleJson,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxRulesTable> {
  $$TaxRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taxYear =>
      $composableBuilder(column: $table.taxYear, builder: (column) => column);

  GeneratedColumn<String> get bracketsJson => $composableBuilder(
    column: $table.bracketsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get personalAllowanceSatang => $composableBuilder(
    column: $table.personalAllowanceSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spouseAllowanceSatang => $composableBuilder(
    column: $table.spouseAllowanceSatang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get childAllowanceSatang => $composableBuilder(
    column: $table.childAllowanceSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseRatePercent => $composableBuilder(
    column: $table.expenseRatePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expenseMaxSatang => $composableBuilder(
    column: $table.expenseMaxSatang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flatExpense406MedicalPercent =>
      $composableBuilder(
        column: $table.flatExpense406MedicalPercent,
        builder: (column) => column,
      );

  GeneratedColumn<String> get flatExpense408Percent => $composableBuilder(
    column: $table.flatExpense408Percent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deductionLimitsJson => $composableBuilder(
    column: $table.deductionLimitsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foreignRemittanceRuleJson => $composableBuilder(
    column: $table.foreignRemittanceRuleJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$TaxRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxRulesTable,
          TaxRule,
          $$TaxRulesTableFilterComposer,
          $$TaxRulesTableOrderingComposer,
          $$TaxRulesTableAnnotationComposer,
          $$TaxRulesTableCreateCompanionBuilder,
          $$TaxRulesTableUpdateCompanionBuilder,
          (TaxRule, BaseReferences<_$AppDatabase, $TaxRulesTable, TaxRule>),
          TaxRule,
          PrefetchHooks Function()
        > {
  $$TaxRulesTableTableManager(_$AppDatabase db, $TaxRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> taxYear = const Value.absent(),
                Value<String> bracketsJson = const Value.absent(),
                Value<int> personalAllowanceSatang = const Value.absent(),
                Value<int> spouseAllowanceSatang = const Value.absent(),
                Value<int> childAllowanceSatang = const Value.absent(),
                Value<String> expenseRatePercent = const Value.absent(),
                Value<int> expenseMaxSatang = const Value.absent(),
                Value<String> flatExpense406MedicalPercent =
                    const Value.absent(),
                Value<String> flatExpense408Percent = const Value.absent(),
                Value<String> deductionLimitsJson = const Value.absent(),
                Value<String> foreignRemittanceRuleJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRulesCompanion(
                id: id,
                taxYear: taxYear,
                bracketsJson: bracketsJson,
                personalAllowanceSatang: personalAllowanceSatang,
                spouseAllowanceSatang: spouseAllowanceSatang,
                childAllowanceSatang: childAllowanceSatang,
                expenseRatePercent: expenseRatePercent,
                expenseMaxSatang: expenseMaxSatang,
                flatExpense406MedicalPercent: flatExpense406MedicalPercent,
                flatExpense408Percent: flatExpense408Percent,
                deductionLimitsJson: deductionLimitsJson,
                foreignRemittanceRuleJson: foreignRemittanceRuleJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int taxYear,
                required String bracketsJson,
                Value<int> personalAllowanceSatang = const Value.absent(),
                Value<int> spouseAllowanceSatang = const Value.absent(),
                Value<int> childAllowanceSatang = const Value.absent(),
                Value<String> expenseRatePercent = const Value.absent(),
                Value<int> expenseMaxSatang = const Value.absent(),
                Value<String> flatExpense406MedicalPercent =
                    const Value.absent(),
                Value<String> flatExpense408Percent = const Value.absent(),
                required String deductionLimitsJson,
                required String foreignRemittanceRuleJson,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRulesCompanion.insert(
                id: id,
                taxYear: taxYear,
                bracketsJson: bracketsJson,
                personalAllowanceSatang: personalAllowanceSatang,
                spouseAllowanceSatang: spouseAllowanceSatang,
                childAllowanceSatang: childAllowanceSatang,
                expenseRatePercent: expenseRatePercent,
                expenseMaxSatang: expenseMaxSatang,
                flatExpense406MedicalPercent: flatExpense406MedicalPercent,
                flatExpense408Percent: flatExpense408Percent,
                deductionLimitsJson: deductionLimitsJson,
                foreignRemittanceRuleJson: foreignRemittanceRuleJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxRulesTable,
      TaxRule,
      $$TaxRulesTableFilterComposer,
      $$TaxRulesTableOrderingComposer,
      $$TaxRulesTableAnnotationComposer,
      $$TaxRulesTableCreateCompanionBuilder,
      $$TaxRulesTableUpdateCompanionBuilder,
      (TaxRule, BaseReferences<_$AppDatabase, $TaxRulesTable, TaxRule>),
      TaxRule,
      PrefetchHooks Function()
    >;
typedef $$TaxResidencyRecordsTableCreateCompanionBuilder =
    TaxResidencyRecordsCompanion Function({
      required String id,
      required int taxYear,
      Value<int> daysInThailand,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$TaxResidencyRecordsTableUpdateCompanionBuilder =
    TaxResidencyRecordsCompanion Function({
      Value<String> id,
      Value<int> taxYear,
      Value<int> daysInThailand,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$TaxResidencyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TaxResidencyRecordsTable> {
  $$TaxResidencyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysInThailand => $composableBuilder(
    column: $table.daysInThailand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxResidencyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxResidencyRecordsTable> {
  $$TaxResidencyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxYear => $composableBuilder(
    column: $table.taxYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysInThailand => $composableBuilder(
    column: $table.daysInThailand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxResidencyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxResidencyRecordsTable> {
  $$TaxResidencyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taxYear =>
      $composableBuilder(column: $table.taxYear, builder: (column) => column);

  GeneratedColumn<int> get daysInThailand => $composableBuilder(
    column: $table.daysInThailand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$TaxResidencyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxResidencyRecordsTable,
          TaxResidencyRecord,
          $$TaxResidencyRecordsTableFilterComposer,
          $$TaxResidencyRecordsTableOrderingComposer,
          $$TaxResidencyRecordsTableAnnotationComposer,
          $$TaxResidencyRecordsTableCreateCompanionBuilder,
          $$TaxResidencyRecordsTableUpdateCompanionBuilder,
          (
            TaxResidencyRecord,
            BaseReferences<
              _$AppDatabase,
              $TaxResidencyRecordsTable,
              TaxResidencyRecord
            >,
          ),
          TaxResidencyRecord,
          PrefetchHooks Function()
        > {
  $$TaxResidencyRecordsTableTableManager(
    _$AppDatabase db,
    $TaxResidencyRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxResidencyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxResidencyRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaxResidencyRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> taxYear = const Value.absent(),
                Value<int> daysInThailand = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxResidencyRecordsCompanion(
                id: id,
                taxYear: taxYear,
                daysInThailand: daysInThailand,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int taxYear,
                Value<int> daysInThailand = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxResidencyRecordsCompanion.insert(
                id: id,
                taxYear: taxYear,
                daysInThailand: daysInThailand,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxResidencyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxResidencyRecordsTable,
      TaxResidencyRecord,
      $$TaxResidencyRecordsTableFilterComposer,
      $$TaxResidencyRecordsTableOrderingComposer,
      $$TaxResidencyRecordsTableAnnotationComposer,
      $$TaxResidencyRecordsTableCreateCompanionBuilder,
      $$TaxResidencyRecordsTableUpdateCompanionBuilder,
      (
        TaxResidencyRecord,
        BaseReferences<
          _$AppDatabase,
          $TaxResidencyRecordsTable,
          TaxResidencyRecord
        >,
      ),
      TaxResidencyRecord,
      PrefetchHooks Function()
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      required String id,
      required String fileName,
      Value<String> templateType,
      required int totalImported,
      required DateTime importedAt,
      Value<bool> isRolledBack,
      Value<DateTime?> rolledBackAt,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<String> fileName,
      Value<String> templateType,
      Value<int> totalImported,
      Value<DateTime> importedAt,
      Value<bool> isRolledBack,
      Value<DateTime?> rolledBackAt,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalImported => $composableBuilder(
    column: $table.totalImported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRolledBack => $composableBuilder(
    column: $table.isRolledBack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rolledBackAt => $composableBuilder(
    column: $table.rolledBackAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalImported => $composableBuilder(
    column: $table.totalImported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRolledBack => $composableBuilder(
    column: $table.isRolledBack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rolledBackAt => $composableBuilder(
    column: $table.rolledBackAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get templateType => $composableBuilder(
    column: $table.templateType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalImported => $composableBuilder(
    column: $table.totalImported,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRolledBack => $composableBuilder(
    column: $table.isRolledBack,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rolledBackAt => $composableBuilder(
    column: $table.rolledBackAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatch,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (
            ImportBatch,
            BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatch>,
          ),
          ImportBatch,
          PrefetchHooks Function()
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> templateType = const Value.absent(),
                Value<int> totalImported = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<bool> isRolledBack = const Value.absent(),
                Value<DateTime?> rolledBackAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                fileName: fileName,
                templateType: templateType,
                totalImported: totalImported,
                importedAt: importedAt,
                isRolledBack: isRolledBack,
                rolledBackAt: rolledBackAt,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fileName,
                Value<String> templateType = const Value.absent(),
                required int totalImported,
                required DateTime importedAt,
                Value<bool> isRolledBack = const Value.absent(),
                Value<DateTime?> rolledBackAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                fileName: fileName,
                templateType: templateType,
                totalImported: totalImported,
                importedAt: importedAt,
                isRolledBack: isRolledBack,
                rolledBackAt: rolledBackAt,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatch,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (
        ImportBatch,
        BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatch>,
      ),
      ImportBatch,
      PrefetchHooks Function()
    >;
typedef $$ConflictLogsTableCreateCompanionBuilder =
    ConflictLogsCompanion Function({
      required String id,
      required String targetTable,
      required String recordId,
      required String conflictType,
      required String localDataJson,
      required String remoteDataJson,
      required String resolvedAction,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });
typedef $$ConflictLogsTableUpdateCompanionBuilder =
    ConflictLogsCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> conflictType,
      Value<String> localDataJson,
      Value<String> remoteDataJson,
      Value<String> resolvedAction,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncVersion,
      Value<int> rowid,
    });

class $$ConflictLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictLogsTable> {
  $$ConflictLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedAction => $composableBuilder(
    column: $table.resolvedAction,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictLogsTable> {
  $$ConflictLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedAction => $composableBuilder(
    column: $table.resolvedAction,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictLogsTable> {
  $$ConflictLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDataJson => $composableBuilder(
    column: $table.localDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteDataJson => $composableBuilder(
    column: $table.remoteDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedAction => $composableBuilder(
    column: $table.resolvedAction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );
}

class $$ConflictLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictLogsTable,
          ConflictLog,
          $$ConflictLogsTableFilterComposer,
          $$ConflictLogsTableOrderingComposer,
          $$ConflictLogsTableAnnotationComposer,
          $$ConflictLogsTableCreateCompanionBuilder,
          $$ConflictLogsTableUpdateCompanionBuilder,
          (
            ConflictLog,
            BaseReferences<_$AppDatabase, $ConflictLogsTable, ConflictLog>,
          ),
          ConflictLog,
          PrefetchHooks Function()
        > {
  $$ConflictLogsTableTableManager(_$AppDatabase db, $ConflictLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> conflictType = const Value.absent(),
                Value<String> localDataJson = const Value.absent(),
                Value<String> remoteDataJson = const Value.absent(),
                Value<String> resolvedAction = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictLogsCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                conflictType: conflictType,
                localDataJson: localDataJson,
                remoteDataJson: remoteDataJson,
                resolvedAction: resolvedAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String recordId,
                required String conflictType,
                required String localDataJson,
                required String remoteDataJson,
                required String resolvedAction,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictLogsCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                conflictType: conflictType,
                localDataJson: localDataJson,
                remoteDataJson: remoteDataJson,
                resolvedAction: resolvedAction,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncVersion: syncVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictLogsTable,
      ConflictLog,
      $$ConflictLogsTableFilterComposer,
      $$ConflictLogsTableOrderingComposer,
      $$ConflictLogsTableAnnotationComposer,
      $$ConflictLogsTableCreateCompanionBuilder,
      $$ConflictLogsTableUpdateCompanionBuilder,
      (
        ConflictLog,
        BaseReferences<_$AppDatabase, $ConflictLogsTable, ConflictLog>,
      ),
      ConflictLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db, _db.fxRates);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$CreditCardInstallmentsTableTableManager get creditCardInstallments =>
      $$CreditCardInstallmentsTableTableManager(
        _db,
        _db.creditCardInstallments,
      );
  $$InvestmentLotsTableTableManager get investmentLots =>
      $$InvestmentLotsTableTableManager(_db, _db.investmentLots);
  $$InvestmentSalesTableTableManager get investmentSales =>
      $$InvestmentSalesTableTableManager(_db, _db.investmentSales);
  $$AssetPricesTableTableManager get assetPrices =>
      $$AssetPricesTableTableManager(_db, _db.assetPrices);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$TaxDeductionsTableTableManager get taxDeductions =>
      $$TaxDeductionsTableTableManager(_db, _db.taxDeductions);
  $$ForeignRemittancesTableTableManager get foreignRemittances =>
      $$ForeignRemittancesTableTableManager(_db, _db.foreignRemittances);
  $$FinancialHealthSettingsTableTableManager get financialHealthSettings =>
      $$FinancialHealthSettingsTableTableManager(
        _db,
        _db.financialHealthSettings,
      );
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(_db, _db.balanceSnapshots);
  $$InvestmentIncomesTableTableManager get investmentIncomes =>
      $$InvestmentIncomesTableTableManager(_db, _db.investmentIncomes);
  $$LiabilitiesTableTableManager get liabilities =>
      $$LiabilitiesTableTableManager(_db, _db.liabilities);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(_db, _db.insurancePolicies);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TaxRulesTableTableManager get taxRules =>
      $$TaxRulesTableTableManager(_db, _db.taxRules);
  $$TaxResidencyRecordsTableTableManager get taxResidencyRecords =>
      $$TaxResidencyRecordsTableTableManager(_db, _db.taxResidencyRecords);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$ConflictLogsTableTableManager get conflictLogs =>
      $$ConflictLogsTableTableManager(_db, _db.conflictLogs);
}
