import 'package:flutter/material.dart';

import '../utils/period.dart';

class PeriodSelector extends StatelessWidget {
  final PeriodType selectionne;
  final ValueChanged<PeriodType> onChanged;

  const PeriodSelector({
    super.key,
    required this.selectionne,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PeriodType>(
      segments: PeriodType.values
          .map(
            (t) => ButtonSegment(value: t, label: Text(t.label)),
          )
          .toList(),
      selected: {selectionne},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
