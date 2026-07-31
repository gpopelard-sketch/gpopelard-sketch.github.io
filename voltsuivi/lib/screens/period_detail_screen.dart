import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../utils/period.dart';
import '../utils/formatters.dart';
import '../widgets/lieu_style.dart';
import '../widgets/proportion_bar.dart';

/// Menu de détail d'une période, ouvert par double-tap sur une barre.
/// Se navigue avec des flèches précédent/suivant sur tout l'historique,
/// sans être limité aux 12 dernières périodes affichées dans le graphique.
class PeriodDetailScreen extends StatefulWidget {
  final List<Recharge> recharges;
  final PeriodRange range;

  const PeriodDetailScreen({
    super.key,
    required this.recharges,
    required this.range,
  });

  @override
  State<PeriodDetailScreen> createState() => _PeriodDetailScreenState();
}

class _PeriodDetailScreenState extends State<PeriodDetailScreen> {
  late PeriodRange _range;

  @override
  void initState() {
    super.initState();
    _range = widget.range;
  }

  @override
  Widget build(BuildContext context) {
    final stat = statsPourPeriode(widget.recharges, _range);
    final peutSuivant = _range.next.start.isBefore(
      DateTime.now().add(const Duration(days: 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _range = _range.previous),
            ),
            Expanded(
              child: Text(
                _range.fullLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: peutSuivant
                  ? () => setState(() => _range = _range.next)
                  : null,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              formatEuros(stat.cout),
              style: AppTheme.styleOdometre(context, size: 34, color: VoltColors.cuivre),
            ),
          ),
          Center(
            child: Text(
              '${formatNombre(stat.kwh)} kWh · ${stat.recharges.length} recharge(s)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          if (stat.recharges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Aucune recharge sur cette période.')),
            )
          else ...[
            _CarteRepartition(
              titre: 'Réseau / vert',
              segments: [
                (
                  'Réseau ${stat.pctReseau.round()}%',
                  VoltColors.energie,
                  stat.kwhReseau,
                ),
                ('Vert ${stat.pctVert.round()}%', VoltColors.solaire, stat.kwhVert),
              ],
            ),
            const SizedBox(height: 16),
            _CarteRepartition(
              titre: 'Domicile / travail / autre',
              segments: [
                for (final l in Lieu.values)
                  (
                    '${libellePourLieu(l)} ${stat.pctCoutPourLieu(l).round()}%',
                    VoltColors.couleurLieu(l),
                    stat.coutPourLieu(l),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recharges de la période', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            for (final r in stat.recharges.reversed)
              Card(
                child: ListTile(
                  leading: Icon(iconePourLieu(r.lieu), color: VoltColors.couleurLieu(r.lieu)),
                  title: Text(DateFormat('d MMMM yyyy', 'fr_FR').format(r.date)),
                  subtitle: Text(
                    '${formatKm(r.odometreKm)} · ${formatNombre(r.kwhReseau + r.kwhVert)} kWh',
                  ),
                  trailing: Text(
                    formatEuros(r.coutReseau + r.coutVert),
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CarteRepartition extends StatelessWidget {
  final String titre;
  final List<(String, Color, double)> segments;

  const _CarteRepartition({required this.titre, required this.segments});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titre, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            ProportionBar(
              segments: [
                for (final s in segments) ProportionSegment(s.$3, s.$2),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final s in segments)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: s.$2, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(s.$1, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
