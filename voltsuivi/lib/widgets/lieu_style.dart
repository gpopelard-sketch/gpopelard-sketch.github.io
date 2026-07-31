import 'package:flutter/material.dart';

import '../data/database.dart';

IconData iconePourLieu(Lieu lieu) => switch (lieu) {
      Lieu.domicile => Icons.home_rounded,
      Lieu.travail => Icons.work_rounded,
      Lieu.autre => Icons.ev_station_rounded,
    };

String libellePourLieu(Lieu lieu) => switch (lieu) {
      Lieu.domicile => 'Domicile',
      Lieu.travail => 'Travail',
      Lieu.autre => 'Autre',
    };
