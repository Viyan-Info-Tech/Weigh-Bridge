import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/services/weight_pairing_service.dart';

void main() {
  const service = WeightPairingService();

  test('current > previous pairs gross/tare', () {
    final result = service.pair(previousKg: 10000, currentKg: 13000);
    expect(result, isA<WeightPairingPaired>());
    final paired = result as WeightPairingPaired;
    expect(paired.grossKg, 13000);
    expect(paired.tareKg, 10000);
    expect(paired.netKg, 3000);
  });

  test('current == previous is rejected', () {
    final result = service.pair(previousKg: 10000, currentKg: 10000);
    expect(result, isA<WeightPairingRejected>());
  });

  test('current < previous pairs previous as gross', () {
    final result = service.pair(previousKg: 10000, currentKg: 4000);
    expect(result, isA<WeightPairingPaired>());
    final paired = result as WeightPairingPaired;
    expect(paired.grossKg, 10000);
    expect(paired.tareKg, 4000);
    expect(paired.netKg, 6000);
  });

  test('zero is rejected', () {
    final result = service.pair(previousKg: 10000, currentKg: 0);
    expect(result, isA<WeightPairingRejected>());
  });

  test('negative is rejected', () {
    final result = service.pair(previousKg: 10000, currentKg: -5);
    expect(result, isA<WeightPairingRejected>());
  });

  test('NaN is rejected', () {
    final result = service.pair(previousKg: 10000, currentKg: double.nan);
    expect(result, isA<WeightPairingRejected>());
  });
}
