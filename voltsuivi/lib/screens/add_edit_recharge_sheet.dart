import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum _ModePrix { total, parKwh }

/// Ouvre la feuille d'ajout/modification d'une recharge, remontant du bas.
Future<void> showAddEditRechargeSheet(
  BuildContext context, {
  Recharge? existant,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddEditRechargeSheet(existant: existant),
  );
}

class AddEditRechargeSheet extends ConsumerStatefulWidget {
  final Recharge? existant;

  const AddEditRechargeSheet({super.key, this.existant});

  @override
  ConsumerState<AddEditRechargeSheet> createState() =>
      _AddEditRechargeSheetState();
}

class _AddEditRechargeSheetState extends ConsumerState<AddEditRechargeSheet> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late Lieu _lieu;
  late TextEditingController _odometreCtrl;

  late TextEditingController _kwhReseauCtrl;
  late TextEditingController _prixReseauCtrl;
  _ModePrix _modePrixReseau = _ModePrix.total;

  late TextEditingController _kwhVertCtrl;
  late TextEditingController _prixVertCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existant;
    _date = e?.date ?? DateTime.now();
    _lieu = e?.lieu ?? Lieu.domicile;
    _odometreCtrl = TextEditingController(text: e?.odometreKm.toString() ?? '');
    _kwhReseauCtrl =
        TextEditingController(text: _fmtInput(e?.kwhReseau));
    _prixReseauCtrl =
        TextEditingController(text: _fmtInput(e?.coutReseau));
    _kwhVertCtrl = TextEditingController(text: _fmtInput(e?.kwhVert));
    _prixVertCtrl = TextEditingController(text: _fmtInput(e?.coutVert));
    for (final c in [
      _odometreCtrl,
      _kwhReseauCtrl,
      _prixReseauCtrl,
      _kwhVertCtrl,
      _prixVertCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  String _fmtInput(double? v) {
    if (v == null || v == 0) return '';
    return v.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    _odometreCtrl.dispose();
    _kwhReseauCtrl.dispose();
    _prixReseauCtrl.dispose();
    _kwhVertCtrl.dispose();
    _prixVertCtrl.dispose();
    super.dispose();
  }

  double get _kwhReseau => parseNombreSaisi(_kwhReseauCtrl.text) ?? 0;
  double get _kwhVert => parseNombreSaisi(_kwhVertCtrl.text) ?? 0;

  double get _coutReseau {
    final saisie = parseNombreSaisi(_prixReseauCtrl.text) ?? 0;
    return _modePrixReseau == _ModePrix.total ? saisie : saisie * _kwhReseau;
  }

  double get _coutVert {
    final prixKwh = parseNombreSaisi(_prixVertCtrl.text) ?? 0;
    return prixKwh * _kwhVert;
  }

  double get _totalKwh => _kwhReseau + _kwhVert;
  double get _totalCout => _coutReseau + _coutVert;

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('fr', 'FR'),
    );
    if (choisie != null) setState(() => _date = choisie);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(databaseProvider);
    final odometre = int.parse(_odometreCtrl.text.trim());

    final companion = RechargesCompanion.insert(
      date: _date,
      odometreKm: odometre,
      lieu: Value(_lieu),
      kwhReseau: Value(_kwhReseau),
      kwhVert: Value(_kwhVert),
      coutReseau: Value(_coutReseau),
      coutVert: Value(_coutVert),
    );

    if (widget.existant == null) {
      await db.insertRecharge(companion);
    } else {
      await db.updateRecharge(
        widget.existant!.copyWith(
          date: _date,
          odometreKm: odometre,
          lieu: _lieu,
          kwhReseau: _kwhReseau,
          kwhVert: _kwhVert,
          coutReseau: _coutReseau,
          coutVert: _coutVert,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    widget.existant == null
                        ? 'Nouvelle recharge'
                        : 'Modifier la recharge',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _choisirDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_date),
                    ),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _odometreCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilométrage au compteur',
                      suffixText: 'km',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (int.tryParse(v.trim()) == null) return 'Nombre entier requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text('Lieu de recharge', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<Lieu>(
                    segments: const [
                      ButtonSegment(
                        value: Lieu.domicile,
                        label: Text('Domicile'),
                        icon: Icon(Icons.home_rounded),
                      ),
                      ButtonSegment(
                        value: Lieu.travail,
                        label: Text('Travail'),
                        icon: Icon(Icons.work_rounded),
                      ),
                      ButtonSegment(
                        value: Lieu.autre,
                        label: Text('Autre'),
                        icon: Icon(Icons.ev_station_rounded),
                      ),
                    ],
                    selected: {_lieu},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _lieu = s.first),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Énergie réseau', VoltColors.energie),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _kwhReseauCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Énergie réseau',
                      suffixText: 'kWh',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<_ModePrix>(
                    segments: const [
                      ButtonSegment(value: _ModePrix.total, label: Text('Prix total €')),
                      ButtonSegment(value: _ModePrix.parKwh, label: Text('€ / kWh')),
                    ],
                    selected: {_modePrixReseau},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _modePrixReseau = s.first),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _prixReseauCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _modePrixReseau == _ModePrix.total
                          ? 'Prix total payé'
                          : 'Prix au kWh',
                      suffixText: _modePrixReseau == _ModePrix.total ? '€' : '€/kWh',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle('Énergie verte / solaire', VoltColors.solaire),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _kwhVertCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Énergie verte',
                      suffixText: 'kWh',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _prixVertCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Prix au kWh (0 = gratuit)',
                      suffixText: '€/kWh',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${formatNombre(_totalKwh)} kWh au total'),
                          Text(
                            formatEuros(_totalCout),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: VoltColors.cuivre,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _enregistrer,
                    style: FilledButton.styleFrom(
                      backgroundColor: VoltColors.cuivre,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.existant == null ? 'Ajouter' : 'Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String texte;
  final Color couleur;

  const _SectionTitle(this.texte, this.couleur);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(texte, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
