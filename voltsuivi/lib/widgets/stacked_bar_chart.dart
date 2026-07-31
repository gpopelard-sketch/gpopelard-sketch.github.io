import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';

/// Graphique en barres empilées par lieu (domicile/travail/autre)
/// représentant les dépenses de chaque période.
///
/// Le tap simple déclenche [onTap] (résumé affiché dans un bandeau externe,
/// jamais en infobulle flottante). Deux taps rapprochés sur la même barre
/// déclenchent [onDoubleTap] (menu de détail).
class StackedBarChart extends StatefulWidget {
  final List<PeriodStat> periodes;
  final int? indexSelectionne;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onDoubleTap;

  const StackedBarChart({
    super.key,
    required this.periodes,
    required this.onTap,
    required this.onDoubleTap,
    this.indexSelectionne,
  });

  @override
  State<StackedBarChart> createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart> {
  int? _dernierIndexTape;
  DateTime? _dernierTapAt;

  void _onIndexTapped(int index) {
    final now = DateTime.now();
    final estDoubleTap = _dernierIndexTape == index &&
        _dernierTapAt != null &&
        now.difference(_dernierTapAt!) < const Duration(milliseconds: 350);
    if (estDoubleTap) {
      _dernierIndexTape = null;
      _dernierTapAt = null;
      widget.onDoubleTap(index);
    } else {
      _dernierIndexTape = index;
      _dernierTapAt = now;
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxY = widget.periodes.fold<double>(
          0,
          (m, p) => p.cout > m ? p.cout : m,
        ) *
        1.2;
    final safeMaxY = maxY <= 0 ? 10.0 : maxY;

    return BarChart(
      BarChartData(
        maxY: safeMaxY,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            getTooltipItem: (a, b, c, d) => null,
          ),
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) return;
            final index = response?.spot?.touchedBarGroupIndex;
            if (index == null) return;
            if (event is FlTapUpEvent) {
              _onIndexTapped(index);
            }
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= widget.periodes.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.periodes[i].range.shortLabel,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < widget.periodes.length; i++)
            _buildGroup(i, widget.periodes[i], safeMaxY),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  BarChartGroupData _buildGroup(int index, PeriodStat stat, double maxY) {
    final estSelectionne = widget.indexSelectionne == index;
    double cumul = 0;
    final items = <BarChartRodStackItem>[];
    for (final lieu in Lieu.values) {
      final cout = stat.coutPourLieu(lieu);
      if (cout <= 0) continue;
      items.add(
        BarChartRodStackItem(
          cumul,
          cumul + cout,
          VoltColors.couleurLieu(lieu),
        ),
      );
      cumul += cout;
    }
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: stat.cout <= 0 ? 0.01 : stat.cout,
          rodStackItems: items,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          color: stat.cout <= 0
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : null,
          borderSide: estSelectionne
              ? const BorderSide(color: VoltColors.encre, width: 1.5)
              : BorderSide.none,
        ),
      ],
    );
  }
}
