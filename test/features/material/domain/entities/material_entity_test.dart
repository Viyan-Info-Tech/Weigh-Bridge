import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';

void main() {
  final now = DateTime(2026, 9, 21);

  MaterialItem buildMaterial({
    int id = 1,
    String code = '1',
    String name = 'Test Material',
    bool isActive = true,
  }) {
    return MaterialItem(
      id: id,
      code: code,
      name: name,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('MaterialItem entity', () {
    test('constructs with required fields only', () {
      final material = MaterialItem(
        id: 1,
        code: '1',
        name: 'Cement',
        createdAt: now,
        updatedAt: now,
      );
      expect(material.id, 1);
      expect(material.code, '1');
      expect(material.name, 'Cement');
      expect(material.isActive, isTrue);
    });

    test('constructs with all fields', () {
      final material = buildMaterial();
      expect(material.id, 1);
      expect(material.code, '1');
      expect(material.name, 'Test Material');
      expect(material.isActive, isTrue);
      expect(material.createdAt, now);
      expect(material.updatedAt, now);
    });

    test('equality is based on props', () {
      final a = buildMaterial();
      final b = buildMaterial();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different name makes materials unequal', () {
      final a = buildMaterial(name: 'Cement');
      final b = buildMaterial(name: 'Steel');
      expect(a, isNot(equals(b)));
    });

    test('different code makes materials unequal', () {
      final a = buildMaterial(code: '1');
      final b = buildMaterial(code: '2');
      expect(a, isNot(equals(b)));
    });

    test('different isActive makes materials unequal', () {
      final a = buildMaterial(isActive: true);
      final b = buildMaterial(isActive: false);
      expect(a, isNot(equals(b)));
    });

    test('props includes id, code, name, isActive', () {
      final material = buildMaterial();
      expect(material.props, [1, '1', 'Test Material', true]);
    });

    test('Tamil text in name is preserved', () {
      final material = buildMaterial(name: 'தமிழ் பொருள்');
      expect(material.name, 'தமிழ் பொருள்');
    });

    test('special characters in name are preserved', () {
      final material = buildMaterial(name: 'Cement + Additive (Premium)');
      expect(material.name, 'Cement + Additive (Premium)');
    });

    test('empty name is valid', () {
      final material = buildMaterial(name: '');
      expect(material.name, '');
    });

    test('inactive material defaults are correct', () {
      final material = buildMaterial(isActive: false);
      expect(material.isActive, isFalse);
    });
  });
}
