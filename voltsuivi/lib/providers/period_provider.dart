import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/period.dart';

/// Type de période actuellement sélectionné sur l'écran d'accueil.
final selectedPeriodTypeProvider =
    StateProvider<PeriodType>((ref) => PeriodType.month);
