// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RechargesTable extends Recharges
    with TableInfo<$RechargesTable, Recharge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RechargesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometreKmMeta = const VerificationMeta(
    'odometreKm',
  );
  @override
  late final GeneratedColumn<int> odometreKm = GeneratedColumn<int>(
    'odometre_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Lieu, String> lieu =
      GeneratedColumn<String>(
        'lieu',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('domicile'),
      ).withConverter<Lieu>($RechargesTable.$converterlieu);
  static const VerificationMeta _kwhReseauMeta = const VerificationMeta(
    'kwhReseau',
  );
  @override
  late final GeneratedColumn<double> kwhReseau = GeneratedColumn<double>(
    'kwh_reseau',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kwhVertMeta = const VerificationMeta(
    'kwhVert',
  );
  @override
  late final GeneratedColumn<double> kwhVert = GeneratedColumn<double>(
    'kwh_vert',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coutReseauMeta = const VerificationMeta(
    'coutReseau',
  );
  @override
  late final GeneratedColumn<double> coutReseau = GeneratedColumn<double>(
    'cout_reseau',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coutVertMeta = const VerificationMeta(
    'coutVert',
  );
  @override
  late final GeneratedColumn<double> coutVert = GeneratedColumn<double>(
    'cout_vert',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    odometreKm,
    lieu,
    kwhReseau,
    kwhVert,
    coutReseau,
    coutVert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recharges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recharge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('odometre_km')) {
      context.handle(
        _odometreKmMeta,
        odometreKm.isAcceptableOrUnknown(data['odometre_km']!, _odometreKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometreKmMeta);
    }
    if (data.containsKey('kwh_reseau')) {
      context.handle(
        _kwhReseauMeta,
        kwhReseau.isAcceptableOrUnknown(data['kwh_reseau']!, _kwhReseauMeta),
      );
    }
    if (data.containsKey('kwh_vert')) {
      context.handle(
        _kwhVertMeta,
        kwhVert.isAcceptableOrUnknown(data['kwh_vert']!, _kwhVertMeta),
      );
    }
    if (data.containsKey('cout_reseau')) {
      context.handle(
        _coutReseauMeta,
        coutReseau.isAcceptableOrUnknown(data['cout_reseau']!, _coutReseauMeta),
      );
    }
    if (data.containsKey('cout_vert')) {
      context.handle(
        _coutVertMeta,
        coutVert.isAcceptableOrUnknown(data['cout_vert']!, _coutVertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recharge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recharge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      odometreKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometre_km'],
      )!,
      lieu: $RechargesTable.$converterlieu.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}lieu'],
        )!,
      ),
      kwhReseau: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kwh_reseau'],
      )!,
      kwhVert: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kwh_vert'],
      )!,
      coutReseau: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cout_reseau'],
      )!,
      coutVert: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cout_vert'],
      )!,
    );
  }

  @override
  $RechargesTable createAlias(String alias) {
    return $RechargesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Lieu, String, String> $converterlieu =
      const EnumNameConverter<Lieu>(Lieu.values);
}

class Recharge extends DataClass implements Insertable<Recharge> {
  final int id;

  /// Date de la recharge (stockée en ISO 8601).
  final DateTime date;

  /// Kilométrage au compteur au moment de la recharge.
  final int odometreKm;

  /// Lieu de la recharge : domicile / travail / autre.
  final Lieu lieu;

  /// Énergie provenant du réseau électrique (kWh).
  final double kwhReseau;

  /// Énergie verte / solaire (kWh).
  final double kwhVert;

  /// Coût de l'énergie réseau (€).
  final double coutReseau;

  /// Coût de l'énergie verte (€), généralement 0.
  final double coutVert;
  const Recharge({
    required this.id,
    required this.date,
    required this.odometreKm,
    required this.lieu,
    required this.kwhReseau,
    required this.kwhVert,
    required this.coutReseau,
    required this.coutVert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['odometre_km'] = Variable<int>(odometreKm);
    {
      map['lieu'] = Variable<String>(
        $RechargesTable.$converterlieu.toSql(lieu),
      );
    }
    map['kwh_reseau'] = Variable<double>(kwhReseau);
    map['kwh_vert'] = Variable<double>(kwhVert);
    map['cout_reseau'] = Variable<double>(coutReseau);
    map['cout_vert'] = Variable<double>(coutVert);
    return map;
  }

  RechargesCompanion toCompanion(bool nullToAbsent) {
    return RechargesCompanion(
      id: Value(id),
      date: Value(date),
      odometreKm: Value(odometreKm),
      lieu: Value(lieu),
      kwhReseau: Value(kwhReseau),
      kwhVert: Value(kwhVert),
      coutReseau: Value(coutReseau),
      coutVert: Value(coutVert),
    );
  }

  factory Recharge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recharge(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      odometreKm: serializer.fromJson<int>(json['odometreKm']),
      lieu: $RechargesTable.$converterlieu.fromJson(
        serializer.fromJson<String>(json['lieu']),
      ),
      kwhReseau: serializer.fromJson<double>(json['kwhReseau']),
      kwhVert: serializer.fromJson<double>(json['kwhVert']),
      coutReseau: serializer.fromJson<double>(json['coutReseau']),
      coutVert: serializer.fromJson<double>(json['coutVert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'odometreKm': serializer.toJson<int>(odometreKm),
      'lieu': serializer.toJson<String>(
        $RechargesTable.$converterlieu.toJson(lieu),
      ),
      'kwhReseau': serializer.toJson<double>(kwhReseau),
      'kwhVert': serializer.toJson<double>(kwhVert),
      'coutReseau': serializer.toJson<double>(coutReseau),
      'coutVert': serializer.toJson<double>(coutVert),
    };
  }

  Recharge copyWith({
    int? id,
    DateTime? date,
    int? odometreKm,
    Lieu? lieu,
    double? kwhReseau,
    double? kwhVert,
    double? coutReseau,
    double? coutVert,
  }) => Recharge(
    id: id ?? this.id,
    date: date ?? this.date,
    odometreKm: odometreKm ?? this.odometreKm,
    lieu: lieu ?? this.lieu,
    kwhReseau: kwhReseau ?? this.kwhReseau,
    kwhVert: kwhVert ?? this.kwhVert,
    coutReseau: coutReseau ?? this.coutReseau,
    coutVert: coutVert ?? this.coutVert,
  );
  Recharge copyWithCompanion(RechargesCompanion data) {
    return Recharge(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      odometreKm: data.odometreKm.present
          ? data.odometreKm.value
          : this.odometreKm,
      lieu: data.lieu.present ? data.lieu.value : this.lieu,
      kwhReseau: data.kwhReseau.present ? data.kwhReseau.value : this.kwhReseau,
      kwhVert: data.kwhVert.present ? data.kwhVert.value : this.kwhVert,
      coutReseau: data.coutReseau.present
          ? data.coutReseau.value
          : this.coutReseau,
      coutVert: data.coutVert.present ? data.coutVert.value : this.coutVert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recharge(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('odometreKm: $odometreKm, ')
          ..write('lieu: $lieu, ')
          ..write('kwhReseau: $kwhReseau, ')
          ..write('kwhVert: $kwhVert, ')
          ..write('coutReseau: $coutReseau, ')
          ..write('coutVert: $coutVert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    odometreKm,
    lieu,
    kwhReseau,
    kwhVert,
    coutReseau,
    coutVert,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recharge &&
          other.id == this.id &&
          other.date == this.date &&
          other.odometreKm == this.odometreKm &&
          other.lieu == this.lieu &&
          other.kwhReseau == this.kwhReseau &&
          other.kwhVert == this.kwhVert &&
          other.coutReseau == this.coutReseau &&
          other.coutVert == this.coutVert);
}

class RechargesCompanion extends UpdateCompanion<Recharge> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> odometreKm;
  final Value<Lieu> lieu;
  final Value<double> kwhReseau;
  final Value<double> kwhVert;
  final Value<double> coutReseau;
  final Value<double> coutVert;
  const RechargesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.odometreKm = const Value.absent(),
    this.lieu = const Value.absent(),
    this.kwhReseau = const Value.absent(),
    this.kwhVert = const Value.absent(),
    this.coutReseau = const Value.absent(),
    this.coutVert = const Value.absent(),
  });
  RechargesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int odometreKm,
    this.lieu = const Value.absent(),
    this.kwhReseau = const Value.absent(),
    this.kwhVert = const Value.absent(),
    this.coutReseau = const Value.absent(),
    this.coutVert = const Value.absent(),
  }) : date = Value(date),
       odometreKm = Value(odometreKm);
  static Insertable<Recharge> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? odometreKm,
    Expression<String>? lieu,
    Expression<double>? kwhReseau,
    Expression<double>? kwhVert,
    Expression<double>? coutReseau,
    Expression<double>? coutVert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (odometreKm != null) 'odometre_km': odometreKm,
      if (lieu != null) 'lieu': lieu,
      if (kwhReseau != null) 'kwh_reseau': kwhReseau,
      if (kwhVert != null) 'kwh_vert': kwhVert,
      if (coutReseau != null) 'cout_reseau': coutReseau,
      if (coutVert != null) 'cout_vert': coutVert,
    });
  }

  RechargesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? odometreKm,
    Value<Lieu>? lieu,
    Value<double>? kwhReseau,
    Value<double>? kwhVert,
    Value<double>? coutReseau,
    Value<double>? coutVert,
  }) {
    return RechargesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      odometreKm: odometreKm ?? this.odometreKm,
      lieu: lieu ?? this.lieu,
      kwhReseau: kwhReseau ?? this.kwhReseau,
      kwhVert: kwhVert ?? this.kwhVert,
      coutReseau: coutReseau ?? this.coutReseau,
      coutVert: coutVert ?? this.coutVert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (odometreKm.present) {
      map['odometre_km'] = Variable<int>(odometreKm.value);
    }
    if (lieu.present) {
      map['lieu'] = Variable<String>(
        $RechargesTable.$converterlieu.toSql(lieu.value),
      );
    }
    if (kwhReseau.present) {
      map['kwh_reseau'] = Variable<double>(kwhReseau.value);
    }
    if (kwhVert.present) {
      map['kwh_vert'] = Variable<double>(kwhVert.value);
    }
    if (coutReseau.present) {
      map['cout_reseau'] = Variable<double>(coutReseau.value);
    }
    if (coutVert.present) {
      map['cout_vert'] = Variable<double>(coutVert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RechargesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('odometreKm: $odometreKm, ')
          ..write('lieu: $lieu, ')
          ..write('kwhReseau: $kwhReseau, ')
          ..write('kwhVert: $kwhVert, ')
          ..write('coutReseau: $coutReseau, ')
          ..write('coutVert: $coutVert')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RechargesTable recharges = $RechargesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recharges];
}

typedef $$RechargesTableCreateCompanionBuilder =
    RechargesCompanion Function({
      Value<int> id,
      required DateTime date,
      required int odometreKm,
      Value<Lieu> lieu,
      Value<double> kwhReseau,
      Value<double> kwhVert,
      Value<double> coutReseau,
      Value<double> coutVert,
    });
typedef $$RechargesTableUpdateCompanionBuilder =
    RechargesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> odometreKm,
      Value<Lieu> lieu,
      Value<double> kwhReseau,
      Value<double> kwhVert,
      Value<double> coutReseau,
      Value<double> coutVert,
    });

class $$RechargesTableFilterComposer
    extends Composer<_$AppDatabase, $RechargesTable> {
  $$RechargesTableFilterComposer({
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

  ColumnFilters<int> get odometreKm => $composableBuilder(
    column: $table.odometreKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Lieu, Lieu, String> get lieu =>
      $composableBuilder(
        column: $table.lieu,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get kwhReseau => $composableBuilder(
    column: $table.kwhReseau,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kwhVert => $composableBuilder(
    column: $table.kwhVert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coutReseau => $composableBuilder(
    column: $table.coutReseau,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coutVert => $composableBuilder(
    column: $table.coutVert,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RechargesTableOrderingComposer
    extends Composer<_$AppDatabase, $RechargesTable> {
  $$RechargesTableOrderingComposer({
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

  ColumnOrderings<int> get odometreKm => $composableBuilder(
    column: $table.odometreKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lieu => $composableBuilder(
    column: $table.lieu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kwhReseau => $composableBuilder(
    column: $table.kwhReseau,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kwhVert => $composableBuilder(
    column: $table.kwhVert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coutReseau => $composableBuilder(
    column: $table.coutReseau,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coutVert => $composableBuilder(
    column: $table.coutVert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RechargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RechargesTable> {
  $$RechargesTableAnnotationComposer({
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

  GeneratedColumn<int> get odometreKm => $composableBuilder(
    column: $table.odometreKm,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Lieu, String> get lieu =>
      $composableBuilder(column: $table.lieu, builder: (column) => column);

  GeneratedColumn<double> get kwhReseau =>
      $composableBuilder(column: $table.kwhReseau, builder: (column) => column);

  GeneratedColumn<double> get kwhVert =>
      $composableBuilder(column: $table.kwhVert, builder: (column) => column);

  GeneratedColumn<double> get coutReseau => $composableBuilder(
    column: $table.coutReseau,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coutVert =>
      $composableBuilder(column: $table.coutVert, builder: (column) => column);
}

class $$RechargesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RechargesTable,
          Recharge,
          $$RechargesTableFilterComposer,
          $$RechargesTableOrderingComposer,
          $$RechargesTableAnnotationComposer,
          $$RechargesTableCreateCompanionBuilder,
          $$RechargesTableUpdateCompanionBuilder,
          (Recharge, BaseReferences<_$AppDatabase, $RechargesTable, Recharge>),
          Recharge,
          PrefetchHooks Function()
        > {
  $$RechargesTableTableManager(_$AppDatabase db, $RechargesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RechargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RechargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RechargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> odometreKm = const Value.absent(),
                Value<Lieu> lieu = const Value.absent(),
                Value<double> kwhReseau = const Value.absent(),
                Value<double> kwhVert = const Value.absent(),
                Value<double> coutReseau = const Value.absent(),
                Value<double> coutVert = const Value.absent(),
              }) => RechargesCompanion(
                id: id,
                date: date,
                odometreKm: odometreKm,
                lieu: lieu,
                kwhReseau: kwhReseau,
                kwhVert: kwhVert,
                coutReseau: coutReseau,
                coutVert: coutVert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int odometreKm,
                Value<Lieu> lieu = const Value.absent(),
                Value<double> kwhReseau = const Value.absent(),
                Value<double> kwhVert = const Value.absent(),
                Value<double> coutReseau = const Value.absent(),
                Value<double> coutVert = const Value.absent(),
              }) => RechargesCompanion.insert(
                id: id,
                date: date,
                odometreKm: odometreKm,
                lieu: lieu,
                kwhReseau: kwhReseau,
                kwhVert: kwhVert,
                coutReseau: coutReseau,
                coutVert: coutVert,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RechargesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RechargesTable,
      Recharge,
      $$RechargesTableFilterComposer,
      $$RechargesTableOrderingComposer,
      $$RechargesTableAnnotationComposer,
      $$RechargesTableCreateCompanionBuilder,
      $$RechargesTableUpdateCompanionBuilder,
      (Recharge, BaseReferences<_$AppDatabase, $RechargesTable, Recharge>),
      Recharge,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RechargesTableTableManager get recharges =>
      $$RechargesTableTableManager(_db, _db.recharges);
}
