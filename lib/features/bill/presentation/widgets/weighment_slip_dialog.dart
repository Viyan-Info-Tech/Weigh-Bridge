import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weighbridge/app/app.dart' show showAppSnackBar;
import '../../../settings/domain/entities/billing_settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../../core/printing/print_service.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/services/weighment_receipt_data.dart';
import '../../domain/services/weighment_ticket_pdf_generator.dart';
import 'weighment_receipt_template.dart';

/// Authentic on-screen preview dialog for the industrial dot-matrix weighbridge slip.
///
/// The slip itself is [WeighmentReceiptTemplate], which the Settings live
/// preview renders too, so this dialog only owns its chrome: the modal header,
/// the action bar and the print pipeline.
class WeighmentSlipDialog extends StatefulWidget {
  final Weighment bill;
  final BillingSettings? settings;
  final PrintService printService;

  const WeighmentSlipDialog({
    super.key,
    required this.bill,
    this.settings,
    this.printService = const PrintService(),
  });

  @override
  State<WeighmentSlipDialog> createState() => _WeighmentSlipDialogState();
}

class _WeighmentSlipDialogState extends State<WeighmentSlipDialog> {
  bool _isPrinting = false;

  BillingSettings _resolveActiveSettings() {
    BillingSettings? blocSettings;
    try {
      blocSettings = context.read<SettingsBloc>().state.settings;
    } catch (_) {
      blocSettings = null;
    }
    return widget.settings ??
        blocSettings ??
        BillingSettings(updatedAt: DateTime.now());
  }

  Future<void> _handlePrint() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      final pdfBytes = await const WeighmentTicketPdfGenerator()
          .generateTicketPdf(
            bill: widget.bill,
            settings: _resolveActiveSettings(),
          );
      final printed = await widget.printService.printPdf(
        pdfBytes,
        jobName: 'Weighment_Ticket_${widget.bill.billNumber}',
      );
      if (!mounted) return;
      if (printed) {
        Navigator.of(context).pop();
        showAppSnackBar(
          'Print job sent for ${widget.bill.billNumber}',
          backgroundColor: const Color(0xFF16A34A),
        );
      } else {
        showAppSnackBar(
          'Unable to print ticket for ${widget.bill.billNumber}',
          backgroundColor: const Color(0xFFDC2626),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        'Failed to print ticket: $e',
        backgroundColor: const Color(0xFFDC2626),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptData = WeighmentReceiptData(
      bill: widget.bill,
      settings: _resolveActiveSettings(),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 880),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.20),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Modal Top Header Bar ─────────────────────
            _buildModalTopBar(context, widget.bill.billNumber),

            // ── Industrial Slip Sheet ────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: WeighmentReceiptTemplate(data: receiptData),
              ),
            ),

            // ── Modal Bottom Actions Bar ──────────────────
            _buildModalBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTopBar(BuildContext context, String billNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF16A34A),
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weighment Slip Preview',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Ticket #$billNumber',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: const Color(0xFF64748B),
            tooltip: 'Close (Esc)',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isPrinting ? null : _handlePrint,
            icon: _isPrinting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print_rounded, size: 18),
            label: Text(
              _isPrinting ? 'Printing...' : 'Print Ticket',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
