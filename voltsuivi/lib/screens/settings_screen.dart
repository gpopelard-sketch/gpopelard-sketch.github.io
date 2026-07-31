import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/csv_export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_car_filled_rounded),
              title: const Text('Nom du véhicule'),
              subtitle: Text(settings.nomVehicule),
              onTap: () => _editerNomVehicule(context, controller, settings.nomVehicule),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.euro_rounded),
              title: const Text('Devise'),
              subtitle: Text(settings.devise),
              onTap: () => _editerDevise(context, controller, settings.devise),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Apparence'),
              subtitle: Text(_libelleTheme(settings.themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                underline: const SizedBox.shrink(),
                onChanged: (v) {
                  if (v != null) controller.setThemeMode(v);
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Système')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: const Text('Exporter les données (CSV)'),
              subtitle: const Text('Partage un fichier CSV de toutes les recharges'),
              onTap: () async {
                final db = ref.read(databaseProvider);
                final recharges = await db.allRechargesSortedByDate();
                if (recharges.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aucune donnée à exporter.')),
                    );
                  }
                  return;
                }
                await CsvExportService.exporter(recharges);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Effacer toutes les données',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmerEffacement(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'VoltSuivi — 100 % hors ligne, aucune donnée envoyée en ligne.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _libelleTheme(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Système',
        ThemeMode.light => 'Clair',
        ThemeMode.dark => 'Sombre',
      };

  Future<void> _editerNomVehicule(
    BuildContext context,
    SettingsController controller,
    String valeurActuelle,
  ) async {
    final ctrl = TextEditingController(text: valeurActuelle);
    final resultat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nom du véhicule'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (resultat != null && resultat.isNotEmpty) {
      controller.setNomVehicule(resultat);
    }
  }

  Future<void> _editerDevise(
    BuildContext context,
    SettingsController controller,
    String valeurActuelle,
  ) async {
    final ctrl = TextEditingController(text: valeurActuelle);
    final resultat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Devise'),
        content: TextField(controller: ctrl, autofocus: true, maxLength: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (resultat != null && resultat.isNotEmpty) {
      controller.setDevise(resultat);
    }
  }

  Future<void> _confirmerEffacement(BuildContext context, WidgetRef ref) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer toutes les données ?'),
        content: const Text(
          'Toutes les recharges enregistrées seront définitivement supprimées. Cette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref.read(databaseProvider).deleteAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données effacées.')),
        );
      }
    }
  }
}
