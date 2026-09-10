import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weighment.dart';
import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';

class RecentBillsPanel extends StatelessWidget {
  final List<Weighment> recentBills;
  final List<Party> parties;
  final List<Vehicle> vehicles;

  const RecentBillsPanel({
    super.key,
    required this.recentBills,
    required this.parties,
    required this.vehicles,
  });

  String _getPartyName(int partyId) {
    try {
      return parties.firstWhere((p) => p.id == partyId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  String _getVehicleNumber(int vehicleId) {
    try {
      return vehicles.firstWhere((v) => v.id == vehicleId).vehicleNumber;
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Bills',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              if (recentBills.isNotEmpty)
                Text(
                  '${recentBills.length} records',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentBills.isEmpty)
            _buildEmptyState()
          else
            _buildBillsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No bills found',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saved bills will appear here',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: recentBills.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bill = recentBills[index];
          final dateStr = DateFormat('dd MMM yy').format(bill.createdAt);
          return _buildBillRow(bill, dateStr);
        },
      ),
    );
  }

  Widget _buildBillRow(Weighment bill, String dateStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.billNumber,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D3B82),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getVehicleNumber(bill.vehicleId),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${bill.netWeightKg.toStringAsFixed(0)} kg',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateStr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
