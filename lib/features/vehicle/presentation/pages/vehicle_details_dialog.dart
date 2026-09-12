import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vehicle.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';

class VehicleDetailsDialog extends StatelessWidget {
  final Vehicle vehicle;
  final String? typeName;

  const VehicleDetailsDialog({super.key, required this.vehicle, this.typeName});

  static Future<void> show(BuildContext context, {required Vehicle vehicle, String? typeName}) {
    return showDialog(
      context: context,
      builder: (_) => VehicleDetailsDialog(vehicle: vehicle, typeName: typeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogWrapper(
      title: 'Vehicle Details',
      subtitle: 'View vehicle information',
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Vehicle Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Vehicle Number', vehicle.vehicleNumber),
          _buildInfoRow('Vehicle Type', typeName),
          _buildStatusRow(vehicle.isActive),
          _buildInfoRow('Driver Name', vehicle.driverName),
          _buildInfoRow('Driver Phone', vehicle.driverPhone),
          _buildInfoRow('Created Date', DateFormat('dd MMM yyyy').format(vehicle.createdAt)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Close', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Color(0xFF64748B))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              (value != null && value.isNotEmpty) ? value : '—',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: (value != null && value.isNotEmpty) ? const Color(0xFF0F172A) : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              'Status',
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF16A34A).withValues(alpha: 0.1) : const Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
