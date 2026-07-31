import 'package:flutter_test/flutter_test.dart';
import 'package:voltsuivi/data/database.dart';
import 'package:voltsuivi/utils/calculations.dart';
import 'package:voltsuivi/utils/period.dart';

Recharge _r({
  required DateTime date,
  required int km,
  Lieu lieu = Lieu.domicile,
  double kwhReseau = 0,
  double kwhVert = 0,
  double coutReseau = 0,
  double coutVert = 0,
}) {
  return Recharge(
    id: 0,
    date: date,
    odometreKm: km,
    lieu: lieu,
    kwhReseau: kwhReseau,
    kwhVert: kwhVert,
    coutReseau: coutReseau,
    coutVert: coutVert,
  );
}

void main() {
  // Jeu de données de test : 4 recharges, kilométrage croissant.
  // 1) 10 000 km — 20 kWh réseau à 0,20€/kWh = 4,00€ (recharge « historique »,
  //    exclue du calcul de consommation).
  // 2) 10 400 km (+400 km) — 30 kWh réseau à 0,25€/kWh = 7,50€.
  // 3) 10 800 km (+400 km) — 10 kWh vert gratuit + 15 kWh réseau à 0,30€/kWh = 4,50€.
  // 4) 11 200 km (+400 km) — 25 kWh réseau à 0,20€/kWh = 5,00€.
  final recharges = [
    _r(
      date: DateTime(2026, 1, 1),
      km: 10000,
      kwhReseau: 20,
      coutReseau: 4.00,
    ),
    _r(
      date: DateTime(2026, 2, 1),
      km: 10400,
      kwhReseau: 30,
      coutReseau: 7.50,
    ),
    _r(
      date: DateTime(2026, 3, 1),
      km: 10800,
      kwhVert: 10,
      coutVert: 0,
      kwhReseau: 15,
      coutReseau: 4.50,
    ),
    _r(
      date: DateTime(2026, 4, 1),
      km: 11200,
      kwhReseau: 25,
      coutReseau: 5.00,
    ),
  ];

  test('distance totale = odomètre max - odomètre min', () {
    expect(distanceTotaleKm(recharges), 1200);
  });

  test('la première recharge (odomètre le plus bas) est exclue de la conso', () {
    final rest = rechargesPourConsommation(recharges);
    expect(rest.length, 3);
    expect(rest.every((r) => r.odometreKm != 10000), isTrue);
  });

  test('consommation moyenne kWh/100km exclut la première recharge', () {
    // kWh hors la première : 30 + (10+15) + 25 = 80 kWh sur 1200 km.
    final conso = consommationMoyenne(recharges);
    expect(conso, closeTo(80 / 1200 * 100, 1e-9));
    expect(conso, closeTo(6.6667, 1e-3));
  });

  test('coût moyen aux 100km exclut la première recharge', () {
    // Coût hors la première : 7.50 + 4.50 + 5.00 = 17.00 € sur 1200 km.
    final cout = coutMoyenAux100km(recharges);
    expect(cout, closeTo(17.0 / 1200 * 100, 1e-9));
    expect(cout, closeTo(1.4167, 1e-3));
  });

  test('prix moyen du kWh porte sur toutes les recharges (pas d\'exclusion)', () {
    // Total kWh = 20+30+25+15+10 = 100 ; total € = 4+7.5+4.5+5 = 21.
    final prix = prixMoyenKwh(recharges);
    expect(totalKwh(recharges), 100);
    expect(totalCout(recharges), 21.0);
    expect(prix, closeTo(0.21, 1e-9));
  });

  test('nombre d\'intervalles = nombre de recharges - 1', () {
    expect(nombreIntervalles(recharges), 3);
    expect(nombreIntervalles([]), 0);
    expect(nombreIntervalles([recharges.first]), 0);
  });

  test('moins de 2 recharges : distance et conso non calculables', () {
    final une = [recharges.first];
    expect(distanceTotaleKm(une), 0);
    expect(consommationMoyenne(une), isNull);
    expect(coutMoyenAux100km(une), isNull);
  });

  group('répartition réseau / vert par période', () {
    test('PeriodStat calcule les kWh et % réseau/vert', () {
      final range = periodContaining(DateTime(2026, 3, 1), PeriodType.month);
      final stat = statsPourPeriode(recharges, range);
      expect(stat.recharges.length, 1);
      expect(stat.kwhReseau, 15);
      expect(stat.kwhVert, 10);
      expect(stat.kwh, 25);
      expect(stat.pctReseau, closeTo(60, 1e-9));
      expect(stat.pctVert, closeTo(40, 1e-9));
    });

    test('euros évités = kWh verts × prix moyen du kWh réseau de la période', () {
      final range = periodContaining(DateTime(2026, 3, 1), PeriodType.month);
      final stat = statsPourPeriode(recharges, range);
      // Prix réseau de mars : 4.50 / 15 = 0.30 €/kWh ; 10 kWh verts => 3.00 €.
      expect(stat.eurosEvites(), closeTo(3.0, 1e-9));
    });
  });

  group('répartition par lieu', () {
    test('kWh, coût et % par lieu', () {
      final mixte = [
        _r(date: DateTime(2026, 5, 1), km: 100, lieu: Lieu.domicile, kwhReseau: 10, coutReseau: 2),
        _r(date: DateTime(2026, 5, 2), km: 200, lieu: Lieu.travail, kwhReseau: 10, coutReseau: 3),
        _r(date: DateTime(2026, 5, 3), km: 300, lieu: Lieu.autre, kwhReseau: 10, coutReseau: 5),
      ];
      final range = periodContaining(DateTime(2026, 5, 1), PeriodType.month);
      final stat = statsPourPeriode(mixte, range);
      expect(stat.coutPourLieu(Lieu.domicile), 2);
      expect(stat.coutPourLieu(Lieu.travail), 3);
      expect(stat.coutPourLieu(Lieu.autre), 5);
      expect(stat.pctCoutPourLieu(Lieu.domicile), closeTo(20, 1e-9));
      expect(stat.pctCoutPourLieu(Lieu.travail), closeTo(30, 1e-9));
      expect(stat.pctCoutPourLieu(Lieu.autre), closeTo(50, 1e-9));
    });
  });

  group('périodes', () {
    test('semaine = lundi à dimanche', () {
      // Le 29/07/2026 est un mercredi.
      final range = periodContaining(DateTime(2026, 7, 29), PeriodType.week);
      expect(range.start, DateTime(2026, 7, 27)); // lundi
      expect(range.end, DateTime(2026, 8, 3)); // lundi suivant (exclu)
      expect(range.start.weekday, DateTime.monday);
    });

    test('mois précédent/suivant gère le changement d\'année', () {
      final janvier = periodContaining(DateTime(2026, 1, 15), PeriodType.month);
      final decembre = janvier.previous;
      expect(decembre.start, DateTime(2025, 12, 1));
      expect(decembre.end, DateTime(2026, 1, 1));
      expect(decembre.next.start, janvier.start);
    });

    test('variationPourcent gère la période précédente vide', () {
      expect(variationPourcent(100, 0), isNull);
      expect(variationPourcent(150, 100), closeTo(50, 1e-9));
      expect(variationPourcent(50, 100), closeTo(-50, 1e-9));
    });

    test('seriePeriodes retourne le bon nombre de périodes triées', () {
      final serie = seriePeriodes(recharges, PeriodType.month, count: 6, anchor: DateTime(2026, 4, 15));
      expect(serie.length, 6);
      expect(serie.last.range.start, DateTime(2026, 4, 1));
      expect(serie.first.range.start, DateTime(2025, 11, 1));
    });
  });
}
