import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';
import '../bloc/material_state.dart' as app_material;
import 'material_form_page.dart' as form;

class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<MaterialBloc>().add(const LoadMaterials());
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
              Expanded(child: _buildMaterialTable()),
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
              'Materials',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Manage material records',
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
          label: const Text('Add Material'),
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
              context.read<MaterialBloc>().add(SearchMaterials(value));
            },
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search material...',
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
                context.read<MaterialBloc>().add(FilterMaterialsByStatus(isActive));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: BlocBuilder<MaterialBloc, app_material.MaterialState>(
        builder: (context, state) {
          if (state.status == app_material.AppMaterialStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.materials.isEmpty) {
            return _buildEmptyState();
          }
          return _buildDataTable(state.materials);
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
          Text('No materials found', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('Add your first material to get started.', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Material'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3B82), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List materials) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columns: const [
          DataColumn(label: Text('#', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Material', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Category', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Unit', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Rate', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Status', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Actions', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600))),
        ],
        rows: materials.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final material = entry.value;
          return DataRow(cells: [
            DataCell(Text(index.toString(), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text(material.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600))),
            DataCell(Text(material.category ?? '-', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text(material.unit, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(Text('₹${material.defaultRate.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DataCell(_buildStatusBadge(material.isActive)),
            DataCell(Row(
              children: [
                _buildActionIcon(Icons.edit_outlined, () => _navigateToForm(context, materialId: material.id)),
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

  void _navigateToForm(BuildContext context, {int? materialId}) {
    form.MaterialFormDialog.show(context, materialId: materialId);
  }
}
