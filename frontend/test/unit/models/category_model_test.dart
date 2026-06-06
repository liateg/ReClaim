import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/items/data/models/category_model.dart';

void main() {
  group('CategoryModel mapping', () {
    test('nameFromId resolves known ids', () {
      expect(CategoryModel.nameFromId(1), 'Electronics');
      expect(CategoryModel.nameFromId(2), 'Accessories');
      expect(CategoryModel.nameFromId(3), 'Clothing');
    });

    test('nameFromId defaults unknown ids to Other', () {
      expect(CategoryModel.nameFromId(99), 'Other');
      expect(CategoryModel.nameFromId(null), 'Other');
      expect(CategoryModel.nameFromId('not-int'), 'Other');
    });

    test('nameFromId accepts numeric strings', () {
      expect(CategoryModel.nameFromId('1'), 'Electronics');
    });

    test('idFromName resolves known names', () {
      expect(CategoryModel.idFromName('Electronics'), 1);
      expect(CategoryModel.idFromName('Clothing'), 3);
    });

    test('idFromName returns null for unknown or empty names', () {
      expect(CategoryModel.idFromName('Other'), isNull);
      expect(CategoryModel.idFromName(''), isNull);
      expect(CategoryModel.idFromName(null), isNull);
    });
  });

  group('CategoryModel serialization', () {
    test('all returns the three known categories', () {
      expect(CategoryModel.all.length, 3);
      expect(CategoryModel.all.map((c) => c.name),
          containsAll(['Electronics', 'Accessories', 'Clothing']));
    });

    test('fromJson reads id and name', () {
      final c = CategoryModel.fromJson({'id': 2, 'name': 'Accessories'});
      expect(c.id, 2);
      expect(c.name, 'Accessories');
    });

    test('fromJson derives name from category_id when name missing', () {
      final c = CategoryModel.fromJson({'category_id': 1});
      expect(c.id, 1);
      expect(c.name, 'Electronics');
    });

    test('toJson round-trips and equality holds', () {
      const c = CategoryModel(id: 3, name: 'Clothing');
      final restored = CategoryModel.fromJson(c.toJson());
      expect(restored, c);
      expect(restored.hashCode, c.hashCode);
    });
  });
}
