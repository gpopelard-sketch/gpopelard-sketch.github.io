# VoltSuivi

Carnet de suivi des recharges pour voiture électrique — 100 % hors ligne,
sans compte, sans publicité.

## Démarrer

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère lib/data/database.g.dart
flutter analyze
flutter test
flutter run
```

## Architecture

```
lib/
  main.dart, app.dart        Point d'entrée, thème, navigation (3 onglets)
  data/database.dart         Base SQLite locale (drift) — table Recharges
  utils/period.dart          Bornes des périodes (jour/semaine/mois/année)
  utils/calculations.dart    Toutes les formules (conso, coût/100km, %, …)
  utils/formatters.dart      Formats français (montants, nombres, dates)
  providers/                 État applicatif (Riverpod) : base, réglages, période
  screens/                   Accueil, Historique, Réglages, Ajout/modification, Détail période
  widgets/                   Composants réutilisables (graphique, cartes, barres…)
  services/csv_export_service.dart   Export CSV + partage natif Android
  theme/app_theme.dart       Palette de couleurs et thèmes clair/sombre
```

Les règles de calcul (distance, consommation moyenne, coût aux 100 km, prix
moyen du kWh, répartition réseau/vert, répartition par lieu…) sont couvertes
par des tests unitaires dans `test/calculations_test.dart`, avec un jeu de
données de test documenté en commentaire.

## Stockage

Toutes les données restent en local dans une base SQLite (`drift`), stockée
dans le répertoire documents de l'application. Aucune donnée n'est envoyée
sur un serveur, aucune connexion réseau n'est nécessaire.

## Publication sur le Play Store

Voir [`PUBLICATION.md`](PUBLICATION.md) pour les instructions complètes :
génération de la clé de signature, build de l'AAB signé, fiche Play Console
et checklist de publication.

## Portage iOS

Le projet est généré avec les plateformes `android` et `ios`. Aucune API
spécifique à Android n'est utilisée dans le code métier (`drift`,
`sqlite3_flutter_libs`, `path_provider`, `share_plus` et `shared_preferences`
sont tous multiplateformes), ce qui permet un portage iOS ultérieur sans
changement d'architecture.
