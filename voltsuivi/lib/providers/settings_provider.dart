import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/formatters.dart' show deviseActuelle;

class Settings {
  final String nomVehicule;
  final String devise;
  final ThemeMode themeMode;

  const Settings({
    this.nomVehicule = 'Ma voiture électrique',
    this.devise = '€',
    this.themeMode = ThemeMode.system,
  });

  Settings copyWith({
    String? nomVehicule,
    String? devise,
    ThemeMode? themeMode,
  }) {
    return Settings(
      nomVehicule: nomVehicule ?? this.nomVehicule,
      devise: devise ?? this.devise,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

const _kNomVehicule = 'nom_vehicule';
const _kDevise = 'devise';
const _kThemeMode = 'theme_mode';

class SettingsController extends StateNotifier<Settings> {
  SettingsController() : super(const Settings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = Settings(
      nomVehicule: prefs.getString(_kNomVehicule) ?? state.nomVehicule,
      devise: prefs.getString(_kDevise) ?? state.devise,
      themeMode: ThemeMode.values[prefs.getInt(_kThemeMode) ?? 0],
    );
    deviseActuelle = state.devise;
  }

  Future<void> setNomVehicule(String value) async {
    state = state.copyWith(nomVehicule: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNomVehicule, value);
  }

  Future<void> setDevise(String value) async {
    state = state.copyWith(devise: value);
    deviseActuelle = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDevise, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode.index);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, Settings>((ref) {
  return SettingsController();
});
