import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'lieu_style.dart';

class RechargeListTile extends StatelessWidget {
  final Recharge recharge;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RechargeListTile({
    super.key,
    required this.recharge,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = VoltColors.couleurLieu(recharge.lieu);
    final kwh = recharge.kwhReseau + recharge.kwhVert;
    final cout = recharge.coutReseau + recharge.coutVert;
    return Dismissible(
      key: ValueKey(recharge.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) async {
        final confirme = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer cette recharge ?'),
            content: Text(
              '${DateFormat('d MMMM yyyy', 'fr_FR').format(recharge.date)} — ${formatEuros(cout)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
        return confirme ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: couleur.withValues(alpha: 0.15),
          child: Icon(iconePourLieu(recharge.lieu), color: couleur, size: 20),
        ),
        title: Text(DateFormat('d MMMM yyyy', 'fr_FR').format(recharge.date)),
        subtitle: Text(
          '${formatKm(recharge.odometreKm)} · ${libellePourLieu(recharge.lieu)} · ${formatNombre(kwh)} kWh',
        ),
        trailing: Text(
          formatEuros(cout),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            color: VoltColors.cuivre,
          ),
        ),
      ),
    );
  }
}
