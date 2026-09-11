import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/vehicle_type_bloc.dart';
import '../bloc/vehicle_type_event.dart';
import '../bloc/vehicle_type_state.dart';
import 'vehicle_type_form_page.dart' as form;

class VehicleTypeListPage extends StatefulWidget {
  const VehicleTypeListPage({super.key});

  @override
  State<VehicleTypeListPage> createState() => _VehicleTypeListPageState();
}

class _VehicleTypeListPageState extends State<VehicleTypeListPage> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<VehicleTypeBloc>().add(const LoadVehicleTypes());
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
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              Expanded(child: _buildVehicleTypeTable()),
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
          child: const Icon(Icons.category_outlined, color: Color(0xFF0F52BA), size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Types',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Manage vehicle type pricing',
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
          onPressed: () => _showFormDialog(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Vehicle Type'),
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

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<VehicleTypeBloc>().add(SearchVehicleTypes(value));
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search vehicle type...',
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
                context.read<VehicleTypeBloc>().add(LoadVehicleTypes(filterActive: isActive));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
        builder: (context, state) {
          if (state.status == VehicleTypeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.vehicleTypes.isEmpty) {
            return _buildEmptyState();
          }
          return _buildDataTable(state.vehicleTypes);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No vehicle types found', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('Add your first vehicle type to get started.', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Vehicle Type'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3B82), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List vehicleTypes) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columns: const [
          DataColumn(label: Text('Type', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Empty Price', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Load Price', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Status', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Actions', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
        ],
        rows: vehicleTypes.map((vehicleType) {
          return DataRow(cells: [
            DataCell(Text(vehicleType.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600))),
            DataCell(Text('₹${vehicleType.emptyPrice.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text('₹${vehicleType.loadPrice.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(_buildStatusBadge(vehicleType.isActive)),
            DataCell(Row(
              children: [
                _buildActionIcon(Icons.edit_outlined, () => _showFormDialog(context, vehicleType: vehicleType)),
                _buildActionIcon(Icons.delete_outline, () => _confirmDeactivate(context, vehicleType)),
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

  void _showFormDialog(BuildContext context, {dynamic vehicleType}) {
    form.VehicleTypeFormDialog.show(context, vehicleType: vehicleType);
  }

  void _confirmDeactivate(BuildContext context, dynamic vehicleType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Vehicle Type', style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to deactivate "${vehicleType.name}"?', style: const TextStyle(fontFamily: 'PlusJakartaSans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              context.read<VehicleTypeBloc>().add(DeactivateVehicleTypeRequested(vehicleType.id));
              Navigator.pop(ctx);
            },
            child: const Text('Deactivate', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }
}
