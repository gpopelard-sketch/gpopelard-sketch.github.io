import 'package:intl/intl.dart';

/// Types de période disponibles pour les statistiques.
enum PeriodType { day, week, month, year }

extension PeriodTypeLabel on PeriodType {
  String get label => switch (this) {
        PeriodType.day => 'Jour',
        PeriodType.week => 'Semaine',
        PeriodType.month => 'Mois',
        PeriodType.year => 'Année',
      };
}

/// Bornes [start, end[ d'une période, `end` exclusive.
class PeriodRange {
  final DateTime start;
  final DateTime end;
  final PeriodType type;

  const PeriodRange(this.start, this.end, this.type);

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(end);

  PeriodRange get previous {
    switch (type) {
      case PeriodType.day:
        return PeriodRange(
          start.subtract(const Duration(days: 1)),
          start,
          type,
        );
      case PeriodType.week:
        return PeriodRange(
          start.subtract(const Duration(days: 7)),
          start,
          type,
        );
      case PeriodType.month:
        final prevMonthStart = DateTime(start.year, start.month - 1, 1);
        return PeriodRange(prevMonthStart, start, type);
      case PeriodType.year:
        return PeriodRange(
          DateTime(start.year - 1, 1, 1),
          DateTime(start.year, 1, 1),
          type,
        );
    }
  }

  PeriodRange get next {
    switch (type) {
      case PeriodType.day:
        return PeriodRange(end, end.add(const Duration(days: 1)), type);
      case PeriodType.week:
        return PeriodRange(end, end.add(const Duration(days: 7)), type);
      case PeriodType.month:
        final nextMonthEnd = DateTime(end.year, end.month + 2, 1);
        return PeriodRange(end, nextMonthEnd, type);
      case PeriodType.year:
        return PeriodRange(
          DateTime(end.year, 1, 1),
          DateTime(end.year + 1, 1, 1),
          type,
        );
    }
  }

  /// Étiquette courte utilisée dans le graphique.
  String get shortLabel {
    switch (type) {
      case PeriodType.day:
        return DateFormat('dd/MM', 'fr_FR').format(start);
      case PeriodType.week:
        return DateFormat('dd/MM', 'fr_FR').format(start);
      case PeriodType.month:
        return _capitalize(DateFormat('MMM yy', 'fr_FR').format(start));
      case PeriodType.year:
        return DateFormat('yyyy', 'fr_FR').format(start);
    }
  }

  /// Nom complet de la période, utilisé dans le menu de détail.
  String get fullLabel {
    switch (type) {
      case PeriodType.day:
        return _capitalize(
          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(start),
        );
      case PeriodType.week:
        final lastDay = end.subtract(const Duration(days: 1));
        final sameMonth = start.month == lastDay.month;
        final startFmt = sameMonth
            ? DateFormat('d', 'fr_FR').format(start)
            : DateFormat('d MMMM', 'fr_FR').format(start);
        final endFmt = DateFormat('d MMMM yyyy', 'fr_FR').format(lastDay);
        return 'Semaine du $startFmt au $endFmt';
      case PeriodType.month:
        return _capitalize(DateFormat('MMMM yyyy', 'fr_FR').format(start));
      case PeriodType.year:
        return 'Année ${start.year}';
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Calcule la [PeriodRange] du type [type] contenant [date].
PeriodRange periodContaining(DateTime date, PeriodType type) {
  final d = DateTime(date.year, date.month, date.day);
  switch (type) {
    case PeriodType.day:
      return PeriodRange(d, d.add(const Duration(days: 1)), type);
    case PeriodType.week:
      // Semaine du lundi au dimanche (weekday: lundi = 1 ... dimanche = 7).
      final start = d.subtract(Duration(days: d.weekday - 1));
      return PeriodRange(start, start.add(const Duration(days: 7)), type);
    case PeriodType.month:
      final start = DateTime(d.year, d.month, 1);
      final end = DateTime(d.year, d.month + 1, 1);
      return PeriodRange(start, end, type);
    case PeriodType.year:
      return PeriodRange(
        DateTime(d.year, 1, 1),
        DateTime(d.year + 1, 1, 1),
        type,
      );
  }
}

/// Construit les [count] dernières périodes de type [type], se terminant par
/// la période contenant [anchor] (aujourd'hui par défaut), triées de la plus
/// ancienne à la plus récente.
List<PeriodRange> lastPeriods(
  PeriodType type, {
  required int count,
  DateTime? anchor,
}) {
  final current = periodContaining(anchor ?? DateTime.now(), type);
  final result = <PeriodRange>[current];
  for (var i = 1; i < count; i++) {
    result.insert(0, result.first.previous);
  }
  return result;
}
