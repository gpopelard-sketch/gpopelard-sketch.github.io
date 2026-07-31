import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

part 'database.g.dart';

/// Lieux de recharge possibles.
enum Lieu { domicile, travail, autre }

/// Table des recharges enregistrées par l'utilisateur.
class Recharges extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Date de la recharge (stockée en ISO 8601).
  DateTimeColumn get date => dateTime()();

  /// Kilométrage au compteur au moment de la recharge.
  IntColumn get odometreKm => integer()();

  /// Lieu de la recharge : domicile / travail / autre.
  TextColumn get lieu =>
      textEnum<Lieu>().withDefault(const Constant('domicile'))();

  /// Énergie provenant du réseau électrique (kWh).
  RealColumn get kwhReseau => real().withDefault(const Constant(0))();

  /// Énergie verte / solaire (kWh).
  RealColumn get kwhVert => real().withDefault(const Constant(0))();

  /// Coût de l'énergie réseau (€).
  RealColumn get coutReseau => real().withDefault(const Constant(0))();

  /// Coût de l'énergie verte (€), généralement 0.
  RealColumn get coutVert => real().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Recharges])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<List<Recharge>> allRechargesSortedByDate() {
    return (select(recharges)
          ..orderBy([(t) => OrderingTerm.asc(t.odometreKm)]))
        .get();
  }

  Stream<List<Recharge>> watchAllRecharges() {
    return (select(recharges)
          ..orderBy([(t) => OrderingTerm.asc(t.odometreKm)]))
        .watch();
  }

  Future<int> insertRecharge(RechargesCompanion entry) {
    return into(recharges).insert(entry);
  }

  Future<bool> updateRecharge(Recharge entry) {
    return update(recharges).replace(entry);
  }

  Future<int> deleteRecharge(int id) {
    return (delete(recharges)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAll() {
    return delete(recharges).go();
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'voltsuivi.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    return NativeDatabase.createInBackground(file);
  });
}
