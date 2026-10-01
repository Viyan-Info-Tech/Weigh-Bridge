import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart'
    show AppDatabase, ChargeVehicleType, WeighmentRate, WeighmentRatesCompanion;
import 'settings_form_field.dart';

class WeighmentRateSettingsCard extends StatefulWidget {
  const WeighmentRateSettingsCard({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<WeighmentRateSettingsCard> createState() =>
      _WeighmentRateSettingsCardState();
}

class _WeighmentRateSettingsCardState extends State<WeighmentRateSettingsCard> {
  AppDatabase? _database;
  Future<List<ChargeVehicleType>>? _vehicleTypesFuture;
  Future<List<WeighmentRate>>? _ratesFuture;
  final Map<int, TextEditingController> _amountControllers = {};
  int? _vehicleTypeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    try {
      final db = context.read<AppDatabase>();
      _database = db;
      _vehicleTypesFuture = (db.select(
        db.chargeVehicleTypes,
      )..where((type) => type.isActive.equals(true))).get();
    } catch (_) {
      _database = null;
      _vehicleTypesFuture = null;
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectVehicleType(int? id) {
    final db = _database;
    setState(() {
      _vehicleTypeId = id;
      _ratesFuture = (id == null || db == null)
          ? null
          : (db.select(
              db.weighmentRates,
            )..where((rate) => rate.vehicleTypeId.equals(id))).get();
    });
  }

  String _rateLabel(WeighmentRate rate) => switch (rate.rateType) {
    'EMPTY' => 'EMPTY',
    'LOAD' => 'LOAD',
    _ => 'ABOVE ${rate.weightLimit?.toStringAsFixed(0) ?? ''} TON',
  };

  (String subtitle, IconData icon, Color iconColor, Color iconBg) _rateMeta(
    WeighmentRate rate,
  ) {
    return switch (rate.rateType) {
      'EMPTY' => (
        'Tare / Unloaded weight',
        Icons.local_shipping_outlined,
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
      ),
      'LOAD' => (
        'Gross / Loaded weight',
        Icons.inventory_2_outlined,
        const Color(0xFF16A34A),
        const Color(0xFFF0FDF4),
      ),
      _ => (
        rate.weightLimit != null
            ? '> ${rate.weightLimit!.toStringAsFixed(0)} Ton limit surcharge'
            : 'Weight slab surcharge',
        Icons.scale_rounded,
        const Color(0xFFD97706),
        const Color(0xFFFFFBEB),
      ),
    };
  }

  Future<void> _saveRates(List<WeighmentRate> rates) async {
    final amounts = <int, double>{};
    for (final rate in rates) {
      final amount = double.tryParse(_amountControllers[rate.id]?.text ?? '');
      if (amount == null || !amount.isFinite || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid non-negative rate.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      amounts[rate.id] = amount;
    }

    final db = _database;
    if (db == null) return;
    setState(() => _saving = true);
    try {
      await db.batch((batch) {
        for (final rate in rates) {
          batch.update(
            db.weighmentRates,
            WeighmentRatesCompanion(amount: Value(amounts[rate.id]!)),
            where: (row) => row.id.equals(rate.id),
          );
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weighment rates successfully updated.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _selectVehicleType(_vehicleTypeId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save weighment rates.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.payments_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF0D3B82),
      title: 'Weighment Charge Rates',
      subtitle:
          'Configure charges and weight slab rates for each vehicle category',
      child: _vehicleTypesFuture == null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No weighment rate sheet is available.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<ChargeVehicleType>>(
              future: _vehicleTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0D3B82),
                        ),
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No weighment rate sheet is available.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final vehicleTypes = snapshot.data!;
                _vehicleTypeId ??= vehicleTypes.first.id;
                final db = _database;
                if (db != null) {
                  _ratesFuture ??=
                      (db.select(db.weighmentRates)..where(
                            (rate) =>
                                rate.vehicleTypeId.equals(_vehicleTypeId!),
                          ))
                          .get();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle category selector
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 15,
                          color: Color(0xFF0D3B82),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Vehicle Category',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _vehicleTypeId,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D3B82),
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: vehicleTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(
                                type.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _selectVehicleType,
                    ),
                    const SizedBox(height: 16),

                    // Rates sheet
                    FutureBuilder<List<WeighmentRate>>(
                      future: _ratesFuture,
                      builder: (context, ratesSnapshot) {
                        if (ratesSnapshot.connectionState !=
                            ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0D3B82),
                                ),
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        if (ratesSnapshot.hasError) {
                          return const Text(
                            'Could not load rates for this vehicle type.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: Color(0xFFDC2626),
                              fontSize: 12.5,
                            ),
                          );
                        }
                        final rates =
                            ratesSnapshot.data ?? const <WeighmentRate>[];
                        if (rates.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 14,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              'No rate slabs configured for this vehicle type',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        // Update amount controllers with current values
                        for (final rate in rates) {
                          if (!_amountControllers.containsKey(rate.id)) {
                            _amountControllers[rate.id] = TextEditingController(
                              text: rate.amount.toStringAsFixed(2),
                            );
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section header with slab count
                            Row(
                              children: [
                                const Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 15,
                                  color: Color(0xFF0D3B82),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Charge Slabs',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    '${rates.length} Slabs Configured',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Responsive grid of rate cards
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 480;
                                final cardWidth = isWide
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  children: rates.map((rate) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: _buildRateTile(rate),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            // Bottom action / info bar
                            if (widget.isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Update the amount for each slab and click "Save Rates".',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: _saving
                                        ? null
                                        : () => _saveRates(rates),
                                    icon: _saving
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.save_rounded,
                                            size: 16,
                                          ),
                                    label: Text(
                                      _saving ? 'Saving...' : 'Save Rates',
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D3B82),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                        0xFF0D3B82,
                                      ).withValues(alpha: 0.4),
                                      disabledForegroundColor: Colors.white70,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 15,
                                      color: Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Click "Edit Settings" in the top bar to update these rate slabs.',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 11.5,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildRateTile(WeighmentRate rate) {
    final (subtitle, iconData, iconColor, iconBg) = _rateMeta(rate);
    final controller = _amountControllers[rate.id];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),

          // Label and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _rateLabel(rate),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Price field or display badge
          if (widget.isEditing && controller != null)
            SizedBox(
              width: 115,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0D3B82),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '₹ ${rate.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
