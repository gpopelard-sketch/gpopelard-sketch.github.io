import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../widgets/lieu_style.dart';

/// Exporte les recharges au format CSV et ouvre le partage natif Android.
class CsvExportService {
  static Future<void> exporter(List<Recharge> recharges) async {
    final lignes = <List<dynamic>>[
      ['Date', 'Kilométrage (km)', 'Lieu', 'kWh réseau', 'kWh vert', 'Coût réseau (€)', 'Coût vert (€)', 'Total kWh', 'Total (€)'],
      for (final r in recharges)
        [
          DateFormat('yyyy-MM-dd').format(r.date),
          r.odometreKm,
          libellePourLieu(r.lieu),
          r.kwhReseau.toStringAsFixed(2),
          r.kwhVert.toStringAsFixed(2),
          r.coutReseau.toStringAsFixed(2),
          r.coutVert.toStringAsFixed(2),
          (r.kwhReseau + r.kwhVert).toStringAsFixed(2),
          (r.coutReseau + r.coutVert).toStringAsFixed(2),
        ],
    ];

    final csv = const ListToCsvConverter(fieldDelimiter: ';').convert(lignes);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/voltsuivi_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
    );
    await file.writeAsString('﻿$csv', encoding: SystemEncoding());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Export VoltSuivi',
    );
  }
}
