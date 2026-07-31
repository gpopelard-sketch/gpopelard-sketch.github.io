import '../data/database.dart';
import 'period.dart';

/// Nombre minimal d'intervalles de recharge pour considérer la consommation
/// moyenne comme fiable.
const int seuilIntervallesFiables = 5;

double totalKwh(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.kwhReseau + r.kwhVert);

double totalKwhReseau(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.kwhReseau);

double totalKwhVert(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.kwhVert);

double totalCout(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.coutReseau + r.coutVert);

double totalCoutReseau(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.coutReseau);

double totalCoutVert(Iterable<Recharge> l) =>
    l.fold(0.0, (s, r) => s + r.coutVert);

/// Trie une liste de recharges par kilométrage croissant (ordre chronologique
/// fiable, indépendant d'éventuelles dates identiques).
List<Recharge> sortedByOdometer(Iterable<Recharge> l) {
  final list = l.toList()..sort((a, b) => a.odometreKm.compareTo(b.odometreKm));
  return list;
}

/// Distance totale suivie = odomètre max − odomètre min.
/// Retourne 0 si moins de deux recharges.
int distanceTotaleKm(Iterable<Recharge> l) {
  if (l.length < 2) return 0;
  final sorted = sortedByOdometer(l);
  return sorted.last.odometreKm - sorted.first.odometreKm;
}

/// Nombre d'intervalles de recharge disponibles (recharges - 1).
int nombreIntervalles(Iterable<Recharge> l) =>
    l.isEmpty ? 0 : l.length - 1;

/// Recharges utilisées pour les calculs de consommation/coût aux 100 km :
/// toutes sauf la toute première (odomètre le plus bas), qui a pu recharger
/// de l'énergie utilisée sur une distance inconnue avant le début du suivi.
List<Recharge> rechargesPourConsommation(Iterable<Recharge> l) {
  final sorted = sortedByOdometer(l);
  if (sorted.length < 2) return const [];
  return sorted.sublist(1);
}

/// Consommation moyenne en kWh/100 km, ou null si non calculable.
double? consommationMoyenne(Iterable<Recharge> l) {
  final distance = distanceTotaleKm(l);
  if (distance <= 0) return null;
  final rest = rechargesPourConsommation(l);
  if (rest.isEmpty) return null;
  final kwh = totalKwh(rest);
  return kwh / distance * 100;
}

/// Coût moyen aux 100 km, ou null si non calculable.
double? coutMoyenAux100km(Iterable<Recharge> l) {
  final distance = distanceTotaleKm(l);
  if (distance <= 0) return null;
  final rest = rechargesPourConsommation(l);
  if (rest.isEmpty) return null;
  final cout = totalCout(rest);
  return cout / distance * 100;
}

/// Prix moyen du kWh, toutes recharges confondues (pas d'exclusion), ou null.
double? prixMoyenKwh(Iterable<Recharge> l) {
  final kwh = totalKwh(l);
  if (kwh <= 0) return null;
  return totalCout(l) / kwh;
}

/// Agrégat des recharges d'une période donnée.
class PeriodStat {
  final PeriodRange range;
  final List<Recharge> recharges;

  PeriodStat(this.range, this.recharges);

  double get kwhReseau => totalKwhReseau(recharges);
  double get kwhVert => totalKwhVert(recharges);
  double get kwh => kwhReseau + kwhVert;

  double get coutReseau => totalCoutReseau(recharges);
  double get coutVert => totalCoutVert(recharges);
  double get cout => coutReseau + coutVert;

  double get pctReseau => kwh <= 0 ? 0 : kwhReseau / kwh * 100;
  double get pctVert => kwh <= 0 ? 0 : kwhVert / kwh * 100;

  double kwhPourLieu(Lieu lieu) =>
      recharges.where((r) => r.lieu == lieu).fold(0.0, (s, r) => s + r.kwhReseau + r.kwhVert);

  double coutPourLieu(Lieu lieu) => recharges
      .where((r) => r.lieu == lieu)
      .fold(0.0, (s, r) => s + r.coutReseau + r.coutVert);

  double pctCoutPourLieu(Lieu lieu) =>
      cout <= 0 ? 0 : coutPourLieu(lieu) / cout * 100;

  /// € évités grâce au solaire = kWh verts × prix moyen du kWh réseau.
  /// Utilise le prix réseau de la période si disponible, sinon celui fourni
  /// en repli (calculé sur tout l'historique).
  double eurosEvites({double? prixReseauDeRepli}) {
    if (kwhVert <= 0) return 0;
    double? prixReseau;
    if (kwhReseau > 0) prixReseau = coutReseau / kwhReseau;
    prixReseau ??= prixReseauDeRepli;
    if (prixReseau == null) return 0;
    return kwhVert * prixReseau;
  }
}

PeriodStat statsPourPeriode(Iterable<Recharge> all, PeriodRange range) {
  final list = all.where((r) => range.contains(r.date)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return PeriodStat(range, list);
}

/// Variation en % entre deux périodes, ou null si la précédente est vide.
double? variationPourcent(double actuel, double precedent) {
  if (precedent == 0) return null;
  return (actuel - precedent) / precedent * 100;
}

/// Construit la série des [count] dernières périodes de type [type] avec
/// leurs statistiques agrégées, triées de la plus ancienne à la plus récente.
List<PeriodStat> seriePeriodes(
  Iterable<Recharge> all,
  PeriodType type, {
  int count = 12,
  DateTime? anchor,
}) {
  final ranges = lastPeriods(type, count: count, anchor: anchor);
  return ranges.map((r) => statsPourPeriode(all, r)).toList();
}
