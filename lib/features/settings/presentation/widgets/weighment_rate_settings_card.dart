import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart'
    show
        AppDatabase,
        ChargeVehicleType,
        WeighmentRate,
        WeighmentRatesCompanion;

class WeighmentRateSettingsCard extends StatefulWidget {
  const WeighmentRateSettingsCard({
    super.key,
    required this.isEditing,
  });

  final bool isEditing;

  @override
  State<WeighmentRateSettingsCard> createState() =>
      _WeighmentRateSettingsCardState();
}

class _WeighmentRateSettingsCardState extends State<WeighmentRateSettingsCard> {
  late final AppDatabase _database;
  late final Future<List<ChargeVehicleType>> _vehicleTypesFuture;
  Future<List<WeighmentRate>>? _ratesFuture;
  final Map<int, TextEditingController> _amountControllers = {};
  int? _vehicleTypeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _database = context.read<AppDatabase>();
    _vehicleTypesFuture = (_database.select(_database.chargeVehicleTypes)
          ..where((type) => type.isActive.equals(true)))
        .get();
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectVehicleType(int? id) {
    setState(() {
      _vehicleTypeId = id;
      _ratesFuture = id == null
          ? null
          : (_database.select(_database.weighmentRates)
                ..where((rate) => rate.vehicleTypeId.equals(id)))
              .get();
    });
  }

  String _rateLabel(WeighmentRate rate) => switch (rate.rateType) {
    'EMPTY' => 'EMPTY',
    'LOAD' => 'LOAD',
    _ => 'ABOVE ${rate.weightLimit?.toStringAsFixed(0) ?? ''} TON',
  };

  Future<void> _saveRates(List<WeighmentRate> rates) async {
    final amounts = <int, double>{};
    for (final rate in rates) {
      final amount = double.tryParse(_amountControllers[rate.id]?.text ?? '');
      if (amount == null || !amount.isFinite || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid non-negative rate.')),
        );
        return;
      }
      amounts[rate.id] = amount;
    }

    setState(() => _saving = true);
    try {
      await _database.batch((batch) {
        for (final rate in rates) {
          batch.update(
            _database.weighmentRates,
            WeighmentRatesCompanion(amount: Value(amounts[rate.id]!)),
            where: (row) => row.id.equals(rate.id),
          );
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weighment rates saved.')),
      );
      _selectVehicleType(_vehicleTypeId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save weighment rates.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<ChargeVehicleType>>(
          future: _vehicleTypesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
              return const Text('No weighment rate sheet is available.');
            }
            final vehicleTypes = snapshot.data!;
            _vehicleTypeId ??= vehicleTypes.first.id;
            _ratesFuture ??= (_database.select(_database.weighmentRates)
                  ..where(
                    (rate) => rate.vehicleTypeId.equals(_vehicleTypeId!),
                  ))
                .get();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Weighment Charge Rates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Update the charge sheet used by the weighment screen.',
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _vehicleTypeId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                  ),
                  items: vehicleTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type.id,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: _selectVehicleType,
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<WeighmentRate>>(
                  future: _ratesFuture,
                  builder: (context, ratesSnapshot) {
                    if (ratesSnapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (ratesSnapshot.hasError) {
                      return const Text('Could not load these rates.');
                    }
                    final rates = ratesSnapshot.data ?? const <WeighmentRate>[];
                    return Column(
                      children: [
                        for (final rate in rates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _rateLabel(rate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _amountControllers.putIfAbsent(
                                      rate.id,
                                      () => TextEditingController(
                                        text: rate.amount.toStringAsFixed(2),
                                      ),
                                    ),
                                    enabled: widget.isEditing,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      prefixText: '₹ ',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _saving || !widget.isEditing
                                ? null
                                : () => _saveRates(rates),
                            icon: const Icon(Icons.save_outlined),
                            label: Text(_saving ? 'Saving...' : 'Save Rates'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
