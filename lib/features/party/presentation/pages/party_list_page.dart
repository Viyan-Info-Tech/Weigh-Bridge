import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
import 'party_form_page.dart' as form;
import 'party_detail_page.dart';

class PartyListPage extends StatefulWidget {
  const PartyListPage({super.key});

  @override
  State<PartyListPage> createState() => _PartyListPageState();
}

class _PartyListPageState extends State<PartyListPage> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<PartyBloc>().add(const LoadParties());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              Expanded(child: _buildPartyTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F52BA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.people_outline, color: Color(0xFF0F52BA), size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parties',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Manage party records',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _navigateToForm(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Party'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<PartyBloc, PartyState>(
      builder: (context, state) {
        return Row(
          children: [
            _buildSummaryCard('Total Parties', state.totalParties.toString(), const Color(0xFF0F52BA)),
            const SizedBox(width: 12),
            _buildSummaryCard('Active', state.activeParties.toString(), const Color(0xFF16A34A)),
            const SizedBox(width: 12),
            _buildSummaryCard('Inactive', state.inactiveParties.toString(), const Color(0xFFDC2626)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<PartyBloc>().add(SearchParties(value));
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search party...',
              hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D3B82))),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              hint: Text('Status', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade600)),
              items: const [
                DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
                DropdownMenuItem(value: 'active', child: Text('Active', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
                bool? isActive;
                if (value == 'active') isActive = true;
                if (value == 'inactive') isActive = false;
                context.read<PartyBloc>().add(FilterPartiesByStatus(isActive));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartyTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: BlocBuilder<PartyBloc, PartyState>(
        builder: (context, state) {
          if (state.status == PartyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.parties.isEmpty) {
            return _buildEmptyState();
          }
          return _buildDataTable(state.parties);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No parties found', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('Add your first party to get started.', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Party'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3B82), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List parties) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columns: const [
          DataColumn(label: Text('#', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Party Name', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Phone', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Vehicles', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Status', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Actions', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
        ],
        rows: parties.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final party = entry.value;
          return DataRow(cells: [
            DataCell(Text(index.toString(), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text(party.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600))),
            DataCell(Text(party.mobile ?? '-', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text(party.vehicleCount.toString(), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(_buildStatusBadge(party.isActive)),
            DataCell(Row(
              children: [
                _buildActionIcon(Icons.visibility_outlined, () => _navigateToDetail(context, party.id)),
                _buildActionIcon(Icons.edit_outlined, () => _navigateToForm(context, partyId: party.id)),
                _buildActionIcon(Icons.more_vert, () {}),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF16A34A).withValues(alpha: 0.1) : const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  void _navigateToForm(BuildContext context, {int? partyId}) {
    form.PartyFormDialog.show(context, partyId: partyId);
  }

  void _navigateToDetail(BuildContext context, int partyId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartyDetailPage(partyId: partyId)),
    );
  }
}
