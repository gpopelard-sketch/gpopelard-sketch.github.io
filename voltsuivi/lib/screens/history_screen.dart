import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../widgets/recharge_list_tile.dart';
import 'add_edit_recharge_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _MonthGroup {
  final DateTime moisAnnee;
  final List<Recharge> recharges;

  _MonthGroup(this.moisAnnee, this.recharges);

  String get libelle {
    final s = DateFormat('MMMM yyyy', 'fr_FR').format(moisAnnee);
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _recherche = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_MonthGroup> _grouper(List<Recharge> recharges) {
    final tri = [...recharges]..sort((a, b) => b.date.compareTo(a.date));
    final groupes = <String, _MonthGroup>{};
    for (final r in tri) {
      final key = '${r.date.year}-${r.date.month}';
      final moisAnnee = DateTime(r.date.year, r.date.month);
      groupes.putIfAbsent(key, () => _MonthGroup(moisAnnee, []));
      groupes[key]!.recharges.add(r);
    }
    final liste = groupes.values.toList()
      ..sort((a, b) => b.moisAnnee.compareTo(a.moisAnnee));
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    final rechargesAsync = ref.watch(rechargesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: rechargesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (recharges) {
          if (recharges.isEmpty) {
            return const Center(child: Text('Aucune recharge enregistrée.'));
          }
          final groupes = _grouper(recharges);
          final normaliserRecherche = _normaliser(_recherche);
          final groupesFiltres = normaliserRecherche.isEmpty
              ? groupes
              : groupes
                  .where((g) => _normaliser(g.libelle).contains(normaliserRecherche))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un mois (ex. juillet 2026)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _recherche.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _recherche = '');
                            },
                          ),
                  ),
                  onChanged: (v) => setState(() => _recherche = v),
                ),
              ),
              Expanded(
                child: groupesFiltres.isEmpty
                    ? const Center(child: Text('Aucun mois ne correspond à la recherche.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: groupesFiltres.length,
                        itemBuilder: (context, index) {
                          final groupe = groupesFiltres[index];
                          return ExpansionTile(
                            key: PageStorageKey(groupe.libelle),
                            initiallyExpanded: index == 0,
                            title: Text(groupe.libelle),
                            subtitle: Text('${groupe.recharges.length} recharge(s)'),
                            children: [
                              for (final r in groupe.recharges)
                                RechargeListTile(
                                  recharge: r,
                                  onTap: () => showAddEditRechargeSheet(context, existant: r),
                                  onDelete: () =>
                                      ref.read(databaseProvider).deleteRecharge(r.id),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _normaliser(String s) => s.toLowerCase().trim();
}
