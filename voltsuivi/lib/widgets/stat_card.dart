import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final String? sousTitre;
  final IconData icone;
  final Color? couleurIcone;

  const StatCard({
    super.key,
    required this.titre,
    required this.valeur,
    required this.icone,
    this.sousTitre,
    this.couleurIcone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 18, color: couleurIcone ?? scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titre,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              valeur,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (sousTitre != null) ...[
              const SizedBox(height: 4),
              Text(
                sousTitre!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
