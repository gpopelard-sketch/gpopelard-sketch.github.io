# Publier VoltSuivi sur le Google Play Store

Ce document décrit, étape par étape, comment générer la clé de signature,
produire l'App Bundle (AAB) signé, créer la fiche Play Console et publier
l'application.

> **Prérequis** : Flutter SDK stable installé, Android Studio (ou au minimum
> le SDK Android + les build-tools) installé, et un compte développeur
> Google Play (frais unique de 25 $).
>
> Ce projet a été développé et vérifié (analyse statique, tests unitaires,
> génération d'icônes) dans un environnement sans SDK Android ; le premier
> `flutter build appbundle` doit donc être lancé sur une machine disposant
> d'Android Studio / du SDK Android avant publication.

## 1. Vérifier le projet

```bash
cd voltsuivi
flutter pub get
flutter analyze
flutter test
```

Les trois commandes doivent passer sans erreur.

## 2. Générer la clé de signature (keystore)

La clé de signature doit être créée **une seule fois** et conservée
précieusement : sa perte empêche toute mise à jour future de l'application
sur le Play Store.

```bash
keytool -genkey -v -keystore ~/voltsuivi-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias voltsuivi
```

Renseignez un mot de passe de keystore et un mot de passe de clé (notez-les
dans un gestionnaire de mots de passe), ainsi que les informations d'identité
demandées (nom, organisation, pays, etc.).

## 3. Déclarer la clé au projet

Créez le fichier `android/key.properties` (déjà ignoré par git) :

```properties
storePassword=<mot de passe du keystore>
keyPassword=<mot de passe de la clé>
keyAlias=voltsuivi
storeFile=/chemin/absolu/vers/voltsuivi-release.jks
```

Le fichier `android/app/build.gradle.kts` du projet lit automatiquement ce
fichier s'il existe et signe le build `release` avec cette clé. En son
absence, `flutter run --release` continue de fonctionner avec la clé de
debug (pratique en développement), mais ce build **ne doit jamais** être
envoyé au Play Store.

## 4. Mettre à jour le numéro de version

Dans `pubspec.yaml` :

```yaml
version: 1.0.0+1   # <nom de version>+<numéro de build, incrémenté à chaque envoi>
```

Incrémentez le numéro après le `+` à chaque nouvel envoi sur le Play Store
(même pour un correctif mineur).

## 5. Construire l'App Bundle signé

```bash
flutter build appbundle --release
```

Le fichier signé est généré dans :

```
build/app/outputs/bundle/release/app-release.aab
```

Vous pouvez vérifier la signature avec :

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

### Icône et écran de démarrage

L'icône et le splash screen sont déjà générés à partir de
`assets/icon/app_icon.png` (icône), `assets/icon/app_icon_foreground.png`
(icône adaptative Android) et `assets/icon/splash_logo.png` (écran de
démarrage). Pour les régénérer après une modification des sources :

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## 6. Créer l'application dans la Play Console

1. Connectez-vous sur [play.google.com/console](https://play.google.com/console).
2. « Créer une application » → nom **VoltSuivi**, langue par défaut
   **Français (France)**, type **Application**, gratuite.
3. Remplissez le questionnaire de déclaration (application gratuite, pas de
   publicité, pas d'achats intégrés).

## 7. Fiche du Play Store (à copier-coller)

### Titre (30 caractères max)
```
VoltSuivi – Recharge VE
```

### Description courte (80 caractères max)
```
Suivez le coût réel de vos recharges de voiture électrique, 100 % hors ligne.
```

### Description longue

```
VoltSuivi est un carnet de suivi des recharges pour votre voiture électrique.
Enregistrez chaque recharge en quelques secondes et découvrez le coût réel de
votre véhicule, jour après jour.

FONCTIONNALITÉS

• Saisie rapide : date, kilométrage, lieu de recharge (domicile, travail ou
  ailleurs) et énergie utilisée. Une même recharge peut mélanger énergie
  réseau et énergie verte/solaire, avec calcul automatique du coût total.

• Statistiques complètes : coût et consommation par jour, semaine, mois ou
  année, avec comparaison à la période précédente.

• Graphique en barres empilées par lieu de recharge, avec détail complet
  (réseau/vert, domicile/travail/autre) accessible d'un double-appui.

• Répartition réseau / solaire : suivez la part d'énergie verte et les euros
  économisés grâce au solaire.

• Historique complet, modifiable et exportable en CSV.

• 100 % hors ligne : toutes vos données restent sur votre téléphone. Aucun
  compte, aucune publicité, aucune connexion Internet requise.

Simple, rapide et respectueux de votre vie privée : VoltSuivi vous aide à
comprendre précisément ce que vous coûte (ou vous fait économiser) votre
voiture électrique.
```

### Catégorie
Auto et véhicules (« Auto & Vehicles »)

### Coordonnées de l'application
Adresse e-mail de contact valide (support utilisateur).

### Politique de confidentialité

VoltSuivi ne collecte, ne transmet et ne stocke aucune donnée en dehors de
l'appareil de l'utilisateur (aucun compte, aucun serveur, aucune requête
réseau). Hébergez néanmoins une courte page de politique de confidentialité
(obligatoire par Google même pour une application 100 % hors ligne), par
exemple via GitHub Pages, indiquant :

- Aucune donnée personnelle n'est collectée.
- Les données saisies (recharges, kilométrage) sont stockées uniquement en
  local sur l'appareil (base SQLite locale).
- Aucune donnée n'est partagée avec des tiers.
- L'export CSV est déclenché manuellement par l'utilisateur via le partage
  natif Android, sous son contrôle exclusif.

### Captures d'écran nécessaires

Formats à préparer (au moins 2, jusqu'à 8, PNG ou JPEG 24 bits) :

| # | Écran | Contenu suggéré |
|---|-------|------------------|
| 1 | Accueil / Statistiques | Montant de la période, graphique en barres empilées, cartes de stats |
| 2 | Accueil (détail réseau/vert et par lieu) | Cartes de répartition réseau/vert et par lieu |
| 3 | Menu de détail d'une période | Ouvert par double-appui sur une barre |
| 4 | Ajout d'une recharge | Feuille remontant du bas, saisie mixte réseau/solaire |
| 5 | Historique | Liste en accordéon par mois |
| 6 | Réglages | Export CSV, apparence |

Résolution recommandée : captures issues d'un appareil au ratio 9:16 (ex.
1080 × 1920 px ou 1080 × 2400 px). Utiliser un simulateur/émulateur ou un
téléphone réel, puis `flutter run --release` sur l'écran concerné suivi
d'une capture d'écran système.

### Icône Play Store (haute résolution)
512 × 512 px, PNG 32 bits (avec canal alpha). Peut être régénérée à partir de
`assets/icon/app_icon.png` (redimensionner à 512×512).

### Image de couverture (feature graphic)
1024 × 500 px — bandeau de présentation affiché en haut de la fiche.

### Classification du contenu
Répondre au questionnaire IARC : application utilitaire sans contenu
sensible → classification « Tout public ».

### Ciblage et appareils
- Version minimale : Android 8.0 (API 26).
- Aucune permission sensible requise.

## 8. Checklist avant publication

- [ ] `flutter analyze` et `flutter test` passent sans erreur.
- [ ] Numéro de version incrémenté dans `pubspec.yaml`.
- [ ] AAB signé généré (`flutter build appbundle --release`) avec la clé de
      production (pas la clé de debug).
- [ ] Keystore et `key.properties` sauvegardés en lieu sûr (hors du dépôt
      git).
- [ ] Icône 512×512 et image de couverture 1024×500 préparées.
- [ ] Au moins 2 captures d'écran par type d'appareil ciblé.
- [ ] Description courte et longue relues (fautes, longueur).
- [ ] Politique de confidentialité publiée et son URL renseignée dans la
      Play Console.
- [ ] Questionnaire de classification du contenu (IARC) complété.
- [ ] Questionnaire « Sécurité des données » (Data safety) rempli en
      indiquant qu'aucune donnée n'est collectée.
- [ ] Pays de disponibilité sélectionnés.
- [ ] Test interne (« internal testing track ») effectué avant la
      publication en production.
- [ ] AAB envoyé sur la piste de production et déployé progressivement
      (rollout).
