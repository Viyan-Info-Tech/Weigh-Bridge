import 'package:flutter/material.dart' hide Material;
import 'package:intl/intl.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../domain/entities/weighment.dart';

class WeighmentSlipDialog extends StatelessWidget {
  final Weighment bill;
  final Vehicle? vehicle;
  final Party? party;
  final List<VehicleType> vehicleTypes;
  final String materialName;

  const WeighmentSlipDialog({
    super.key,
    required this.bill,
    this.vehicle,
    this.party,
    this.vehicleTypes = const [],
    required this.materialName,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleNo = vehicle?.vehicleNumber ?? '—';
    String vehicleTypeName = '—';
    if (vehicle != null) {
      try {
        vehicleTypeName = vehicleTypes.firstWhere((vt) => vt.id == vehicle!.vehicleTypeId).name;
      } catch (_) {}
    }
    final partyName = party?.name ?? '—';
    final partyPhone = party?.mobile ?? '';
    final dateFormatted = DateFormat('dd/MM/yyyy').format(bill.createdAt);
    final timeFormatted = DateFormat('hh:mm:ss a').format(bill.createdAt);
    final printDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final isCompleted = bill.status.toLowerCase() == 'completed';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildTitle(isCompleted: isCompleted),
                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildInfoRow('SL.NO.', bill.billNumber),
                      _buildInfoRow('Date', dateFormatted),
                      _buildInfoRow('Time', timeFormatted),
                      const SizedBox(height: 6),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildInfoRow('Vehicle No.', vehicleNo),
                      _buildInfoRow('Material', materialName),
                      _buildInfoRow('Party', partyName),
                      if (partyPhone.isNotEmpty)
                        _buildInfoRow('Party Mobile', partyPhone),
                      _buildInfoRow('Vehicle Type', vehicleTypeName),
                      const SizedBox(height: 6),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      if (isCompleted) ...[
                        _buildWeightRow('Gross Weight', '${bill.grossWeightKg.toStringAsFixed(3)} kg'),
                        _buildWeightRow('Tare Weight', '${bill.tareWeightKg?.toStringAsFixed(3) ?? '—'} kg'),
                        const SizedBox(height: 4),
                        _buildDivider(),
                        const SizedBox(height: 4),
                        _buildWeightRow('Net Weight', '${(bill.netWeightKg ?? 0).toStringAsFixed(3)} kg'),
                      ] else ...[
                        _buildWeightRow('Gross Weight', '${bill.grossWeightKg.toStringAsFixed(3)} kg'),
                        _buildWeightRow('Tare Weight', 'PENDING'),
                        const SizedBox(height: 4),
                        _buildDivider(),
                        const SizedBox(height: 4),
                        _buildWeightRow('Net Weight', '—'),
                      ],
                      const SizedBox(height: 6),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildInfoRow('Amount', 'Rs. ${bill.amount.toStringAsFixed(2)}'),
                      _buildInfoRow('Payment', bill.paymentMode.toUpperCase()),
                      _buildInfoRow('Cash Received', 'Rs. ${bill.amount.toStringAsFixed(2)}'),
                      _buildInfoRow('Pending', 'Rs. 0.00'),
                      if (!isCompleted) ...[
                        const SizedBox(height: 6),
                        _buildStatusBadge(),
                      ],
                      if (bill.remarks != null && bill.remarks!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildDivider(),
                        const SizedBox(height: 6),
                        _buildRemarks(bill.remarks!),
                      ],
                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildFooterNote(isCompleted: isCompleted),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '* $printDate *',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 7,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38BDF8), width: 1),
          ),
          child: const Icon(
            Icons.scale_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'VIYAN WEIGHBRIDGE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Computer Weigh Bridge',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '24 HOURS SERVICE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle({required bool isCompleted}) {
    return Center(
      child: Text(
        isCompleted ? 'WEIGHMENT RECEIPT' : 'WEIGHMENT RECEIPT — TARE WEIGHT PENDING',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: isCompleted ? 12 : 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: List.generate(
        40,
        (i) => Expanded(
          child: Container(
            height: 1,
            color: i.isEven ? const Color(0xFF64748B) : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRow(String label, String value) {
    final isPending = value == 'PENDING';
    final isDash = value == '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: isPending ? 10 : 11,
                fontWeight: FontWeight.w800,
                color: isPending
                    ? const Color(0xFFD97706)
                    : isDash
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_outlined, size: 12, color: Color(0xFFD97706)),
          SizedBox(width: 4),
          Text(
            'TARE WEIGHT PENDING',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD97706),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarks(String remarks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note: ',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        Expanded(
          child: Text(
            remarks,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote({required bool isCompleted}) {
    return Text(
      isCompleted
          ? 'Note: Please check the weight before leaving the weighbridge.'
          : 'Note: Tare weight is pending.\nPlease return to the weighbridge for the second weighing.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF94A3B8),
        height: 1.3,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text(
            'Close',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Print job sent for ${bill.billNumber}'),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.print_rounded, size: 18),
          label: const Text(
            'Print Ticket',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }
}
