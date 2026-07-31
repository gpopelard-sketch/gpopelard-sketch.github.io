import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../utils/formatters.dart';

/// Bandeau fixe affiché au-dessus du graphique lors du tap simple sur une
/// barre : résumé de la période (coût, kWh, réseau/vert). Ne se superpose
/// jamais aux barres (pas d'infobulle flottante).
class PeriodSummaryBanner extends StatelessWidget {
  final PeriodStat? stat;

  const PeriodSummaryBanner({super.key, this.stat});

  @override
  Widget build(BuildContext context) {
    final s = stat;
    if (s == null) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: Text(
            'Touchez une barre pour voir le détail',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.range.shortLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  formatEuros(s.cout),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: VoltColors.cuivre,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _MiniStat(
              label: '${formatNombre(s.kwh)} kWh',
              color: VoltColors.energie,
            ),
          ),
          Expanded(
            child: _MiniStat(
              label: 'Réseau ${s.pctReseau.round()}%',
              color: VoltColors.energie,
            ),
          ),
          Expanded(
            child: _MiniStat(
              label: 'Vert ${s.pctVert.round()}%',
              color: VoltColors.solaire,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniStat({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
