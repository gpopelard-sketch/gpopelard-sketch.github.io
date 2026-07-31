import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../providers/period_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../utils/period.dart';
import '../utils/formatters.dart';
import '../widgets/lieu_style.dart';
import '../widgets/period_selector.dart';
import '../widgets/period_summary_banner.dart';
import '../widgets/proportion_bar.dart';
import '../widgets/stacked_bar_chart.dart';
import '../widgets/stat_card.dart';
import 'add_edit_recharge_sheet.dart';
import 'period_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _indexBanniere;

  @override
  Widget build(BuildContext context) {
    final rechargesAsync = ref.watch(rechargesStreamProvider);
    final periodType = ref.watch(selectedPeriodTypeProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(settings.nomVehicule)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditRechargeSheet(context),
        child: const Icon(Icons.add),
      ),
      body: rechargesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (recharges) {
          if (recharges.isEmpty) {
            return _EmptyState(onAdd: () => showAddEditRechargeSheet(context));
          }
          return _buildContent(context, recharges, periodType);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Recharge> recharges,
    PeriodType periodType,
  ) {
    final serie = seriePeriodes(recharges, periodType, count: 12);
    final courante = serie.last;
    final precedente = statsPourPeriode(recharges, courante.range.previous);
    final variation = variationPourcent(courante.cout, precedente.cout);

    final conso = consommationMoyenne(recharges);
    final cout100 = coutMoyenAux100km(recharges);
    final prixKwh = prixMoyenKwh(recharges);
    final distance = distanceTotaleKm(recharges);
    final intervalles = nombreIntervalles(recharges);

    final prixReseauGlobal = totalKwhReseau(recharges) > 0
        ? totalCoutReseau(recharges) / totalKwhReseau(recharges)
        : null;

    final statBanniere = _indexBanniere != null && _indexBanniere! < serie.length
        ? serie[_indexBanniere!]
        : null;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          PeriodSelector(
            selectionne: periodType,
            onChanged: (t) {
              ref.read(selectedPeriodTypeProvider.notifier).state = t;
              setState(() => _indexBanniere = null);
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  '${periodType.label} en cours',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatEuros(courante.cout),
                  style: AppTheme.styleOdometre(context, color: VoltColors.cuivre),
                ),
                const SizedBox(height: 6),
                if (variation != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        variation >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: variation >= 0 ? Colors.redAccent : VoltColors.solaire,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${variation.abs().toStringAsFixed(0)} % vs période précédente',
                        style: TextStyle(
                          fontSize: 12,
                          color: variation >= 0 ? Colors.redAccent : VoltColors.solaire,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Pas de période précédente',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PeriodSummaryBanner(stat: statBanniere),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: StackedBarChart(
              periodes: serie,
              indexSelectionne: _indexBanniere,
              onTap: (i) => setState(() => _indexBanniere = i),
              onDoubleTap: (i) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PeriodDetailScreen(
                      recharges: recharges,
                      range: serie[i].range,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                titre: 'Consommation moyenne',
                valeur: conso == null ? '—' : '${formatNombre(conso)} kWh/100km',
                icone: Icons.speed_rounded,
                couleurIcone: VoltColors.energie,
                sousTitre: intervalles < seuilIntervallesFiables
                    ? 'Estimation approximative'
                    : null,
              ),
              StatCard(
                titre: 'Coût moyen / 100 km',
                valeur: cout100 == null ? '—' : formatEuros(cout100),
                icone: Icons.local_gas_station_rounded,
                couleurIcone: VoltColors.cuivre,
              ),
              StatCard(
                titre: 'Prix moyen du kWh',
                valeur: prixKwh == null ? '—' : formatEuros(prixKwh),
                icone: Icons.bolt_rounded,
                couleurIcone: VoltColors.energie,
              ),
              StatCard(
                titre: 'Distance totale suivie',
                valeur: formatKm(distance),
                icone: Icons.route_rounded,
                couleurIcone: VoltColors.encre,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CarteRepartitionSource(stat: courante, prixReseauGlobal: prixReseauGlobal),
          const SizedBox(height: 16),
          _CarteRepartitionLieu(stat: courante),
        ],
      ),
    );
  }
}

class _CarteRepartitionSource extends StatelessWidget {
  final PeriodStat stat;
  final double? prixReseauGlobal;

  const _CarteRepartitionSource({required this.stat, this.prixReseauGlobal});

  @override
  Widget build(BuildContext context) {
    final evites = stat.eurosEvites(prixReseauDeRepli: prixReseauGlobal);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Répartition réseau / vert', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            ProportionBar(
              segments: [
                ProportionSegment(stat.kwhReseau, VoltColors.energie),
                ProportionSegment(stat.kwhVert, VoltColors.solaire),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Legende(
                  couleur: VoltColors.energie,
                  texte: 'Réseau ${stat.pctReseau.round()}% · ${formatNombre(stat.kwhReseau)} kWh',
                ),
                _Legende(
                  couleur: VoltColors.solaire,
                  texte: 'Vert ${stat.pctVert.round()}% · ${formatNombre(stat.kwhVert)} kWh',
                ),
              ],
            ),
            if (evites > 0) ...[
              const SizedBox(height: 10),
              Text(
                '${formatEuros(evites)} économisés grâce au solaire',
                style: const TextStyle(color: VoltColors.solaire, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarteRepartitionLieu extends StatelessWidget {
  final PeriodStat stat;

  const _CarteRepartitionLieu({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Répartition par lieu', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            ProportionBar(
              segments: [
                for (final l in Lieu.values)
                  ProportionSegment(stat.coutPourLieu(l), VoltColors.couleurLieu(l)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final l in Lieu.values)
                  _Legende(
                    couleur: VoltColors.couleurLieu(l),
                    icone: iconePourLieu(l),
                    texte:
                        '${libellePourLieu(l)} ${stat.pctCoutPourLieu(l).round()}% · ${formatEuros(stat.coutPourLieu(l))}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  final Color couleur;
  final String texte;
  final IconData? icone;

  const _Legende({required this.couleur, required this.texte, this.icone});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone != null)
          Icon(icone, size: 14, color: couleur)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(texte, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ev_station_rounded, size: 64, color: VoltColors.energie),
            const SizedBox(height: 16),
            Text(
              'Aucune recharge enregistrée',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre première recharge pour commencer le suivi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une recharge'),
            ),
          ],
        ),
      ),
    );
  }
}
