import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle/domain/usecases/create_vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/usecases/delete_vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/usecases/load_vehicles.dart';
import 'package:weighbridge/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:weighbridge/features/vehicle/presentation/pages/vehicles_merged_page.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/create_vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/delete_vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/load_vehicle_types.dart';
import 'package:weighbridge/features/vehicle_type/presentation/bloc/vehicle_type_bloc.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}
class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}

void main() {
  late MockVehicleRepository mockVehicleRepo;
  late VehicleBloc vehicleBloc;

  late MockVehicleTypeRepository mockVehicleTypeRepo;
  late VehicleTypeBloc vehicleTypeBloc;

  final testVehicleType = VehicleType(
    id: 1,
    name: 'Truck',
    emptyPrice: 100,
    loadPrice: 200,
    isActive: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  final testVehicle = Vehicle(
    id: 1,
    vehicleNumber: 'TN31CM2026',
    vehicleTypeId: 1,
    driverName: 'Ramesh',
    driverPhone: '9876543210',
    isActive: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  setUp(() {
    mockVehicleRepo = MockVehicleRepository();
    mockVehicleTypeRepo = MockVehicleTypeRepository();

    when(() => mockVehicleRepo.getAllVehicles())
        .thenAnswer((_) => Future.value([testVehicle]));
    when(() => mockVehicleRepo.getVehiclesByStatus(isActive: any(named: 'isActive')))
        .thenAnswer((_) => Future.value([testVehicle]));
    when(() => mockVehicleRepo.searchVehicles(any()))
        .thenAnswer((_) => Future.value([testVehicle]));

    when(() => mockVehicleTypeRepo.getAllVehicleTypes())
        .thenAnswer((_) => Future.value([testVehicleType]));
    when(() => mockVehicleTypeRepo.getVehicleTypesByStatus(isActive: any(named: 'isActive')))
        .thenAnswer((_) => Future.value([testVehicleType]));
    when(() => mockVehicleTypeRepo.searchVehicleTypes(any()))
        .thenAnswer((_) => Future.value([testVehicleType]));

    vehicleBloc = VehicleBloc(
      loadVehiclesUseCase: LoadVehiclesUseCase(mockVehicleRepo),
      createVehicleUseCase: CreateVehicleUseCase(mockVehicleRepo),
      deleteVehicleUseCase: DeleteVehicleUseCase(mockVehicleRepo),
      vehicleRepository: mockVehicleRepo,
    );

    vehicleTypeBloc = VehicleTypeBloc(
      loadVehicleTypesUseCase: LoadVehicleTypesUseCase(mockVehicleTypeRepo),
      createVehicleTypeUseCase: CreateVehicleTypeUseCase(mockVehicleTypeRepo),
      deleteVehicleTypeUseCase: DeleteVehicleTypeUseCase(mockVehicleTypeRepo),
      vehicleTypeRepository: mockVehicleTypeRepo,
    );
  });

  tearDown(() {
    vehicleBloc.close();
    vehicleTypeBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<VehicleBloc>.value(value: vehicleBloc),
          BlocProvider<VehicleTypeBloc>.value(value: vehicleTypeBloc),
        ],
        child: const Scaffold(body: VehiclesMergedPage()),
      ),
    );
  }

  testWidgets('renders header, stats cards, and both vehicle panels with correct data', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    // Verify page header
    expect(find.text('Vehicles & Types'), findsOneWidget);
    expect(find.text('Manage registered vehicles and pricing tiers'), findsOneWidget);

    // Verify stats cards
    expect(find.text('Registered Fleet'), findsOneWidget);
    expect(find.text('Vehicle Categories'), findsOneWidget);
    expect(find.text('Operational Rate'), findsOneWidget);

    // Verify panel titles and counts
    expect(find.text('Vehicles'), findsWidgets);
    expect(find.text('Vehicle Types'), findsWidgets);
    expect(find.text('Add Vehicle'), findsOneWidget);
    expect(find.text('Add Type'), findsOneWidget);

    // Verify table headers
    expect(find.text('VEHICLE NUMBER'), findsOneWidget);
    expect(find.text('DRIVER'), findsOneWidget);
    expect(find.text('EMPTY'), findsOneWidget);
    expect(find.text('LOAD'), findsOneWidget);

    // Verify data row content
    expect(find.text('TN31CM2026'), findsOneWidget);
    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('Truck'), findsWidgets);
    expect(find.text('₹100'), findsOneWidget);
    expect(find.text('₹200'), findsOneWidget);

    // Verify footers
    expect(find.text('Total 1 vehicle'), findsOneWidget);
    expect(find.text('Total 1 type'), findsOneWidget);
  });
}
