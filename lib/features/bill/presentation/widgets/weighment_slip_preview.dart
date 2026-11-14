import 'package:flutter/material.dart';

import '../../../settings/domain/entities/billing_settings.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/services/preprinted_ticket_layout.dart';

/// On-screen preview of the weighment slip: a single, centered receipt card
/// with a modern, professional layout. The printed ticket is still built by
/// `PrePrintedTicketPdfGenerator` and is unaffected by anything drawn here.
class WeighmentSlipPreview extends StatelessWidget {
  const WeighmentSlipPreview({
    super.key,
    required this.bill,
    required this.settings,
  });

  final Weighment bill;
  final BillingSettings settings;

  static const double ticketDesignWidth = 620;

  @override
  Widget build(BuildContext context) {
    final data = PrePrintedTicketData(bill: bill, settings: settings);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : ticketDesignWidth;
        final receipt = _ReceiptCard(data: data);

        if (available >= ticketDesignWidth) {
          return Center(child: receipt);
        }
        if (available >= ticketDesignWidth * 0.75) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: receipt,
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: receipt,
        );
      },
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  static const double ticketDesignWidth = WeighmentSlipPreview.ticketDesignWidth;

  const _ReceiptCard({required this.data});

  final PrePrintedTicketData data;

  @override
  Widget build(BuildContext context) {
    final weights = data.weights;
    final settings = data.settings;
    final businessName = settings.businessName.trim().isEmpty
        ? 'VIYAN WEIGHBRIDGE'
        : settings.businessName.trim().toUpperCase();
    final subtitle = (settings.businessSubtitle?.trim().isNotEmpty ?? false)
        ? settings.businessSubtitle!.trim()
        : 'Computer Weigh Bridge';
    final serviceText = (settings.serviceText?.trim().isNotEmpty ?? false)
        ? settings.serviceText!.trim()
        : '24 HOURS SERVICE';
    final title = settings.receiptTitle.trim().isEmpty
        ? 'WEIGHMENT RECEIPT'
        : settings.receiptTitle.trim().toUpperCase();

    String weightText(double? kg) {
      if (kg == null) return '—';
      return '${kg.toStringAsFixed(0)} Kg';
    }

    String chargesText() {
      final v = data.valueFor(PrePrintedField.charges);
      return v.isEmpty ? '—' : '$v Rs.';
    }

    String materialText() {
      final v = data.valueFor(PrePrintedField.material);
      return v.isEmpty ? '—' : v;
    }

    String customerText() {
      final v = data.valueFor(PrePrintedField.customer);
      return v.isEmpty ? '—' : v;
    }

    return Container(
      width: ticketDesignWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Company identity ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D3B82), Color(0xFF1E6FD9)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  businessName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bill information ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              children: [
                _infoRow('Serial Number', data.valueFor(PrePrintedField.serial)),
                _infoRow('Date', data.dateText),
                _infoRow('Time', data.timeText),
                _infoRow('Vehicle Number', data.valueFor(PrePrintedField.vehicle)),
                _infoRow('Customer', customerText()),
                _infoRow('Material', materialText()),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 24, endIndent: 24),

          // ── Weight information ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: _weightCard(
                    label: 'GROSS WEIGHT',
                    value: weightText(weights.grossKg),
                    color: const Color(0xFF0284C7),
                    bg: const Color(0xFFF0F9FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _weightCard(
                    label: 'TARE WEIGHT',
                    value: weightText(weights.tareKg),
                    color: const Color(0xFF64748B),
                    bg: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _weightCard(
                    label: 'NET WEIGHT',
                    value: weightText(weights.netKg),
                    color: const Color(0xFF16A34A),
                    bg: const Color(0xFFECFDF5),
                    emphasize: true,
                  ),
                ),
              ],
            ),
          ),

          // ── Charges ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight Charges',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Text(
                    chargesText(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                const Text(
                  'Thank you for using Viyan Weighbridge',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '24x7 SERVICE',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B82),
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'DRIVE SAFE!',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B82),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.trim().isEmpty || value == '—') {
      // Still show a dash for empty values to keep layout stable.
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightCard({
    required String label,
    required String value,
    required Color color,
    required Color bg,
    bool emphasize = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: emphasize ? 20 : 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}