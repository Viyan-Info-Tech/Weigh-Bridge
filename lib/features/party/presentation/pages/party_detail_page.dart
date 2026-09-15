import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
import 'party_form_page.dart' as form;
import '../../../vehicle/presentation/pages/vehicle_list_page.dart';

class PartyDetailPage extends StatefulWidget {
  final int partyId;

  const PartyDetailPage({super.key, required this.partyId});

  @override
  State<PartyDetailPage> createState() => _PartyDetailPageState();
}

class _PartyDetailPageState extends State<PartyDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PartyBloc>().add(LoadPartyDetail(widget.partyId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Party Details',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _navigateToEdit(context),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Party'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PartyBloc, PartyState>(
      builder: (context, state) {
        if (state.status == PartyStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.selectedParty == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Party not found',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        final party = state.selectedParty!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(party),
              const SizedBox(height: 16),
              _buildVehiclesSection(party),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(dynamic party) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Party Information',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Party Name', party.name),
          if (party.contactPerson != null && party.contactPerson!.isNotEmpty)
            _buildInfoRow('Contact Person', party.contactPerson!),
          if (party.mobile != null && party.mobile!.isNotEmpty)
            _buildInfoRow('Phone', party.mobile!),
          if (party.email != null && party.email!.isNotEmpty)
            _buildInfoRow('Email', party.email!),
          if (party.gstNumber != null && party.gstNumber!.isNotEmpty)
            _buildInfoRow('GST Number', party.gstNumber!),
          if (party.city != null && party.city!.isNotEmpty)
            _buildInfoRow('City', party.city!),
          if (party.state != null && party.state!.isNotEmpty)
            _buildInfoRow('State', party.state!),
          if (party.address != null && party.address!.isNotEmpty)
            _buildInfoRow('Address', party.address!),
          _buildInfoRow('Status', party.isActive ? 'Active' : 'Inactive'),
          _buildInfoRow('Vehicles', party.vehicleCount.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection(dynamic party) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text(
                'Vehicles',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _navigateToVehicles(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B82),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (party.vehicleCount == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No vehicles found',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a vehicle for this party',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${party.vehicleCount} vehicle(s) registered',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    form.PartyFormDialog.show(context, partyId: widget.partyId);
  }

  void _navigateToVehicles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleListPage(partyId: widget.partyId),
      ),
    );
  }
}
