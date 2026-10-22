import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/material/data/datasources/material_local_datasource.dart';
import 'package:weighbridge/features/material/data/repositories/material_repository_impl.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/material/domain/usecases/update_material.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_bloc.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_event.dart';
import 'package:weighbridge/features/material/presentation/widgets/material_details_dialog.dart';
import 'package:weighbridge/features/material/presentation/widgets/material_list_page.dart';

import '../../support/test_database.dart';

/// Desktop window sizes the material screen must survive without a
/// RenderFlex overflow.
const _desktopSizes = <Size>[
  Size(800, 600),
  Size(1024, 768),
  Size(1280, 720),
  Size(1366, 768),
  Size(1920, 1080),
];

MaterialBloc _buildBloc(AppDatabase db) {
  final repository = MaterialRepositoryImpl(
    localDataSource: MaterialLocalDataSource(db),
  );
  return MaterialBloc(
    loadMaterials: LoadMaterials(repository),
    createMaterial: CreateMaterial(repository),
    updateMaterial: UpdateMaterial(repository),
    deleteMaterial: DeleteMaterial(repository),
  );
}

Future<void> _pumpMaterialList(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<MaterialBloc>(
        create: (_) => _buildBloc(db)..add(const LoadMaterialsEvent()),
        child: const Scaffold(body: MaterialListPage()),
      ),
    ),
  );
  // Let the initial load + first frame settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets(
    'material list renders long names and both types without overflow',
    (tester) async {
      await withDatabase((db) async {
        final repository = MaterialRepositoryImpl(
          localDataSource: MaterialLocalDataSource(db),
        );
        await repository.createMaterial('Very Long Material Name Example', 'Empty');
        await repository.createMaterial('Auto', 'Load');
        await repository.createMaterial('Sand', 'Empty');

        await _pumpMaterialList(tester, db);

        expect(tester.takeException(), isNull);
        expect(find.text('Very Long Material Name Example'), findsOneWidget);
        expect(find.text('Auto - Load'), findsOneWidget);
      });
    },
  );

  for (final size in _desktopSizes) {
    testWidgets(
      'no overflow at desktop size ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await withDatabase((db) async {
          final repository = MaterialRepositoryImpl(
            localDataSource: MaterialLocalDataSource(db),
          );
          await repository.createMaterial('Gravel', 'Load');
          await repository.createMaterial(
            'Extraordinarily Long Material Name That Keeps Going',
            'Empty',
          );

          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await _pumpMaterialList(tester, db);

          expect(tester.takeException(), isNull);
          // Actions stay reachable.
          expect(find.byTooltip('Edit'), findsWidgets);
          expect(find.byTooltip('Delete'), findsWidgets);
          expect(find.byTooltip('View Details'), findsWidgets);
        });
      },
    );
  }

  testWidgets('empty state shows guidance and add button', (tester) async {
    await withDatabase((db) async {
      await _pumpMaterialList(tester, db);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('No materials found'), findsOneWidget);
      expect(find.text('Add Material'), findsOneWidget);
    });
  });

  testWidgets('form and details dialogs fit a 800x600 window', (tester) async {
    await withDatabase((db) async {
      final repository = MaterialRepositoryImpl(
        localDataSource: MaterialLocalDataSource(db),
      );
      final id = await repository.createMaterial('Cement', 'Load');
      final material = await repository.getById(id);

      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MaterialBloc>(
            create: (_) => _buildBloc(db),
            child: Scaffold(
              body: MaterialDetailsDialog(material: material),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Cement - Load'), findsOneWidget);
    });
  });
}
