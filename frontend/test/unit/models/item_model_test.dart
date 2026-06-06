import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

void main() {
  group('ItemModel.fromMap', () {
    test('parses snake_case API map', () {
      final item = ItemModel.fromMap({
        'id': 10,
        'title': 'Black Wallet',
        'location': 'Library',
        'description': 'Leather wallet',
        'category': 'Accessories',
        'category_id': 2,
        'status': 'available',
        'date_found': 'Jun 5, 2026',
        'verification_question': 'Color?',
        'verification_answer': 'Black',
        'image_url': 'https://x/y.png',
        'hidden_details': 'engraving',
        'posted_by': 7,
        'created_at': '2026-01-01',
        'updated_at': '2026-01-02',
      });

      expect(item.id, '10');
      expect(item.title, 'Black Wallet');
      expect(item.location, 'Library');
      expect(item.category, 'Accessories');
      expect(item.categoryId, 2);
      expect(item.status, 'available');
      expect(item.postedBy, 7);
      expect(item.hiddenDetails, 'engraving');
    });

    test('derives category name from category_id when category missing', () {
      final item = ItemModel.fromMap({
        'id': 1,
        'title': 'Phone',
        'category_id': 1,
      });
      expect(item.category, 'Electronics');
    });

    test('unknown category id resolves to Other', () {
      final item = ItemModel.fromMap({'id': 1, 'category_id': 99});
      expect(item.category, 'Other');
    });

    test('applies sensible defaults for missing fields', () {
      final item = ItemModel.fromMap({});
      expect(item.id, '');
      expect(item.title, '');
      expect(item.status, 'available');
      expect(item.categoryId, isNull);
      expect(item.hiddenDetails, isNull);
    });

    test('supports camelCase fallbacks', () {
      final item = ItemModel.fromMap({
        'id': 2,
        'dateFound': '2026-05-01',
        'verificationQuestion': 'Q',
        'verificationAnswer': 'A',
        'imageUrl': 'http://img',
        'postedBy': 3,
      });
      expect(item.dateFound, '2026-05-01');
      expect(item.verificationQuestion, 'Q');
      expect(item.verificationAnswer, 'A');
      expect(item.imageUrl, 'http://img');
      expect(item.postedBy, 3);
    });

    test('blank hidden details become null', () {
      final item = ItemModel.fromMap({'id': 1, 'hidden_details': '   '});
      expect(item.hiddenDetails, isNull);
    });
  });

  group('ItemModel serialization', () {
    test('toMap round-trips through fromMap', () {
      const item = ItemModel(
        id: '5',
        title: 'Keys',
        location: 'Cafe',
        description: 'Set of keys',
        category: 'Other',
        categoryId: null,
        status: 'claimed',
        dateFound: 'Jun 1, 2026',
        verificationQuestion: 'How many?',
        verificationAnswer: '3',
        imageUrl: '',
      );

      final restored = ItemModel.fromMap(item.toMap());
      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.status, item.status);
      expect(restored.verificationAnswer, item.verificationAnswer);
    });

    test('fromJson delegates to fromMap', () {
      final item = ItemModel.fromJson({'id': 1, 'title': 'X'});
      expect(item.title, 'X');
    });

    test('exposes a placeholder image constant', () {
      expect(ItemModel.placeholderImage, contains('placeholder'));
    });
  });
}
