import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show OrderingTerm;

import '../../../../core/database/app_database.dart'
    show AppDatabase, ChargeVehicleType, WeighmentRate;

class _ApplyChargeIntent extends Intent {
  const _ApplyChargeIntent();
}

class _CancelChargeIntent extends Intent {
  const _CancelChargeIntent();
}

class WeighmentChargeDialog extends StatefulWidget {
  const WeighmentChargeDialog({
    super.key,
    required this.database,
  });

  final AppDatabase database;

  static Future<double?> show(
    BuildContext context, {
    required AppDatabase database,
  }) {
    return showDialog<double>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (_) => WeighmentChargeDialog(database: database),
    );
  }

  @override
  State<WeighmentChargeDialog> createState() => _WeighmentChargeDialogState();
}

class _WeighmentChargeDialogState extends State<WeighmentChargeDialog> {
  late final Future<List<ChargeVehicleType>> _vehicleTypesFuture;
  Future<List<WeighmentRate>>? _ratesFuture;
  int? _vehicleTypeId;
  WeighmentRate? _selectedRate;
  List<WeighmentRate> _visibleRates = const [];
  final Map<int, FocusNode> _rateFocusNodes = {};

  @override
  void initState() {
    super.initState();
    _vehicleTypesFuture = (widget.database.select(
      widget.database.chargeVehicleTypes,
    )..where((type) => type.isActive.equals(true))
      ..orderBy([(type) => OrderingTerm.asc(type.id)])).get();
  }

  void _selectVehicleType(int? id) {
    setState(() {
      _vehicleTypeId = id;
      _selectedRate = null;
      _visibleRates = const [];
      _ratesFuture = id == null
          ? null
          : (widget.database.select(widget.database.weighmentRates)
                ..where((rate) => rate.vehicleTypeId.equals(id))
                ..orderBy([(rate) => OrderingTerm.asc(rate.id)]))
              .get();
    });
  }

  @override
  void dispose() {
    for (final focusNode in _rateFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  FocusNode _focusNodeFor(WeighmentRate rate) => _rateFocusNodes.putIfAbsent(
    rate.id,
    () => FocusNode(debugLabel: 'weighmentRate_${rate.id}'),
  );

  void _applySelectedRate() {
    final rate = _selectedRate;
    if (rate != null) Navigator.pop(context, rate.amount);
  }

  void _cancelSelection() => Navigator.pop(context);

  KeyEventResult _handleArrowKeys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _visibleRates.isEmpty) {
      return KeyEventResult.ignored;
    }
    final currentIndex = _visibleRates.indexWhere(
      (rate) => rate.id == _selectedRate?.id,
    );
    final index = currentIndex < 0 ? 0 : currentIndex;
    final key = event.logicalKey;
    var nextIndex = index;

    if (key == LogicalKeyboardKey.arrowUp) {
      nextIndex = (index - 2).clamp(0, _visibleRates.length - 1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      nextIndex = (index + 2).clamp(0, _visibleRates.length - 1);
    } else if (key == LogicalKeyboardKey.arrowLeft && index.isOdd) {
      nextIndex = index - 1;
    } else if (key == LogicalKeyboardKey.arrowRight &&
        index.isEven &&
        index + 1 < _visibleRates.length) {
      nextIndex = index + 1;
    } else {
      return KeyEventResult.ignored;
    }

    final rate = _visibleRates[nextIndex];
    setState(() => _selectedRate = rate);
    FocusScope.of(context).requestFocus(_focusNodeFor(rate));
    return KeyEventResult.handled;
  }

  String _label(WeighmentRate rate) {
    return switch (rate.rateType) {
      'EMPTY' => 'EMPTY',
      'LOAD' => 'LOAD',
      _ => 'ABOVE ${rate.weightLimit?.toStringAsFixed(0) ?? ''} TON',
    };
  }

  String _subLabel(WeighmentRate rate) {
    return switch (rate.rateType) {
      'EMPTY' => 'Tare / Unloaded weight',
      'LOAD' => 'Gross / Loaded weight',
      _ => rate.weightLimit != null
          ? '> ${rate.weightLimit!.toStringAsFixed(0)} Ton slab surcharge'
          : 'Weight surcharge rate',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.enter):
            const _ApplyChargeIntent(),
        const SingleActivator(LogicalKeyboardKey.space):
            const _ApplyChargeIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
            const _ApplyChargeIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const _CancelChargeIntent(),
        const SingleActivator(LogicalKeyboardKey.keyC, alt: true):
            const _CancelChargeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ApplyChargeIntent: CallbackAction<_ApplyChargeIntent>(
            onInvoke: (_) => _applySelectedRate(),
          ),
          _CancelChargeIntent: CallbackAction<_CancelChargeIntent>(
            onInvoke: (_) => _cancelSelection(),
          ),
        },
        child: Focus(
          onKeyEvent: _handleArrowKeys,
          child: Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F0F172A),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<List<ChargeVehicleType>>(
            future: _vehicleTypesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 180,
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
              if (snapshot.hasError) {
                return _buildErrorState('Could not load the vehicle rate sheet.');
              }

              final vehicleTypes = snapshot.data ?? const <ChargeVehicleType>[];
              if (vehicleTypes.isEmpty) {
                return _buildErrorState('No vehicle charge rates are available.');
              }

              _vehicleTypeId ??= vehicleTypes.first.id;
              _ratesFuture ??= (widget.database
                    .select(widget.database.weighmentRates)
                  ..where((rate) => rate.vehicleTypeId.equals(_vehicleTypeId!))
                  ..orderBy([(rate) => OrderingTerm.asc(rate.id)]))
                  .get();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // Divider
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 20),

                  // Vehicle Type Section
                  _buildSectionLabel(
                    icon: Icons.local_shipping_outlined,
                    label: 'Vehicle Category',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _vehicleTypeId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                  const SizedBox(height: 22),

                  // Rates Section
                  FutureBuilder<List<WeighmentRate>>(
                    future: _ratesFuture,
                    builder: (context, ratesSnapshot) {
                      if (ratesSnapshot.connectionState !=
                          ConnectionState.done) {
                        return const SizedBox(
                          height: 140,
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
                        return _buildErrorState(
                          'Could not load rates for this vehicle type.',
                        );
                      }

                      final rates =
                          ratesSnapshot.data ?? const <WeighmentRate>[];
                      if (rates.isEmpty) {
                        return _buildEmptyRatesState();
                      }
                      _visibleRates = rates;
                      _selectedRate ??= rates.first;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee_rounded,
                                size: 16,
                                color: Color(0xFF0D3B82),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Select Charge Rate',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
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
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  '${rates.length} Slabs Available',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth;
                              final cardWidth = availableWidth > 380
                                  ? (availableWidth - 10) / 2
                                  : availableWidth;
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: rates
                                    .map(
                                      (rate) => SizedBox(
                                        width: cardWidth,
                                        child: _buildRateCard(
                                          rate,
                                          autofocus:
                                              rate.id == rates.first.id,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  // Selected Highlight Summary
                  if (_selectedRate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Selected: ',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: _label(_selectedRate!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: '  •  '),
                                  TextSpan(
                                    text:
                                        '₹${_selectedRate!.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Text(
                            'Double-click card to apply',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _cancelSelection,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _selectedRate == null
                            ? null
                            : _applySelectedRate,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: Text(
                          _selectedRate == null
                              ? 'Select Charge'
                              : 'Apply ₹${_selectedRate!.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B82),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF0D3B82).withValues(alpha: 0.35),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: const Icon(
            Icons.scale_rounded,
            size: 20,
            color: Color(0xFF0D3B82),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Weighment Charge',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Choose vehicle category and applicable weighment rate slab',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0D3B82)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildRateCard(
    WeighmentRate rate, {
    required bool autofocus,
  }) {
    final isSelected = rate.id == _selectedRate?.id;
    final subLabel = _subLabel(rate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusNode: _focusNodeFor(rate),
        autofocus: autofocus,
        onFocusChange: (hasFocus) {
          if (hasFocus && _selectedRate?.id != rate.id) {
            setState(() => _selectedRate = rate);
          }
        },
        onTap: () => setState(() => _selectedRate = rate),
        onDoubleTap: () {
          setState(() => _selectedRate = rate);
          Navigator.pop(context, rate.amount);
        },
        borderRadius: BorderRadius.circular(10),
        hoverColor: isSelected
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.7),
        splashColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x182563EB),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Custom Selection Radio / Checkmark
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFF8FAFC),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // Title and category description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _label(rate),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Rate Amount Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${rate.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? const Color(0xFF0D3B82)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRatesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 30, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No rate slabs configured for this vehicle type',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Colors.grey.shade600,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
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
}
