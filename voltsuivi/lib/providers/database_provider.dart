import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Flux de toutes les recharges, triées par kilométrage croissant.
final rechargesStreamProvider = StreamProvider<List<Recharge>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllRecharges();
});
