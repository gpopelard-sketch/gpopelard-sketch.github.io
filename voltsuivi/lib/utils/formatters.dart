import 'package:intl/intl.dart';

/// Symbole de devise courant, tenu à jour par [SettingsController] (voir
/// providers/settings_provider.dart) à chaque changement du réglage devise.
String deviseActuelle = '€';

/// Formate un montant au format français : "1 234,56 €".
String formatEuros(double value, {String? symbole}) {
  final f = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: symbole ?? deviseActuelle,
    decimalDigits: 2,
  );
  return f.format(value);
}

/// Formate un nombre décimal au format français : "1 234,5".
String formatNombre(double value, {int decimales = 1}) {
  final f = NumberFormat.decimalPattern('fr_FR')
    ..maximumFractionDigits = decimales
    ..minimumFractionDigits = decimales;
  return f.format(value);
}

/// Formate un kilométrage entier : "12 345 km".
String formatKm(int value) {
  final f = NumberFormat.decimalPattern('fr_FR');
  return '${f.format(value)} km';
}

/// Convertit un texte saisi par l'utilisateur (avec virgule ou point
/// décimal) en [double]. Retourne null si le texte n'est pas un nombre.
double? parseNombreSaisi(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}
