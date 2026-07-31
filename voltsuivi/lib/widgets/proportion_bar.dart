import 'package:flutter/material.dart';

/// Segment coloré d'une barre de proportion.
class ProportionSegment {
  final double valeur;
  final Color couleur;

  const ProportionSegment(this.valeur, this.couleur);
}

/// Barre horizontale montrant la répartition proportionnelle de plusieurs
/// segments (ex : réseau/vert, ou domicile/travail/autre).
class ProportionBar extends StatelessWidget {
  final List<ProportionSegment> segments;
  final double hauteur;

  const ProportionBar({
    super.key,
    required this.segments,
    this.hauteur = 10,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.valeur);
    return ClipRRect(
      borderRadius: BorderRadius.circular(hauteur / 2),
      child: SizedBox(
        height: hauteur,
        child: total <= 0
            ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)
            : Row(
                children: segments
                    .where((s) => s.valeur > 0)
                    .map(
                      (s) => Expanded(
                        flex: (s.valeur * 1000 / total).round().clamp(1, 100000),
                        child: Container(color: s.couleur),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
