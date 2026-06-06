import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/items/data/items_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  final service = ItemsService();

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    mockSecureStorage({'token': 'token123'});
    resetAppSession();
    await cache.clear();
  });

  tearDown(() {
    clearSecureStorageMock();
  });

  Map<String, dynamic> itemMap(String id, {int? postedBy}) => {
        'id': id,
        'title': 'Item $id',
        'location': 'Loc',
        'description': 'Desc',
        'category': 'Electronics',
        'category_id': 1,
        'status': 'available',
        'image_url': '',
        if (postedBy != null) 'posted_by': postedBy,
      };

  group('getItems (cache-first)', () {
    test('returns cached items mapped to ItemModel', () async {
      await cache.set('items:list', [itemMap('1'), itemMap('2')]);

      final items = await service.getItems();

      expect(items, hasLength(2));
      expect(items.first.id, '1');
      expect(items.first.title, 'Item 1');
    });
  });

  group('getAdminItems (cache-first)', () {
    test('returns cached admin items', () async {
      await cache.set('items:admin', [itemMap('7')]);
      final items = await service.getAdminItems();
      expect(items.single.id, '7');
    });
  });

  group('getItemById (cache-first)', () {
    test('returns the cached item', () async {
      await cache.set('items:5', itemMap('5'));
      final item = await service.getItemById('5');
      expect(item, isNotNull);
      expect(item!.id, '5');
    });
  });

  group('getMyPostedItems', () {
    test('filters cached items by the current user id', () async {
      AppSession.userId = 100;
      await cache.set('items:list', [
        itemMap('1', postedBy: 100),
        itemMap('2', postedBy: 200),
        itemMap('3', postedBy: 100),
      ]);

      final mine = await service.getMyPostedItems();

      expect(mine.map((i) => i.id), containsAll(['1', '3']));
      expect(mine.any((i) => i.id == '2'), isFalse);
    });

    test('returns all items when no user id is set', () async {
      AppSession.userId = null;
      await cache.set('items:list', [itemMap('1', postedBy: 1)]);
      final mine = await service.getMyPostedItems();
      expect(mine, hasLength(1));
    });
  });

  group('submitClaim validation', () {
    test('throws for a non-numeric item id before any network call', () async {
      expect(
        () => service.submitClaim(itemId: 'not-a-number', answer: 'x'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('cache invalidation', () {
    test('invalidateItemCache removes list, admin and item keys', () async {
      await cache.set('items:list', [itemMap('1')]);
      await cache.set('items:admin', [itemMap('1')]);
      await cache.set('items:1', itemMap('1'));

      await service.invalidateItemCache(id: '1');

      expect(await cache.get('items:list'), isNull);
      expect(await cache.get('items:admin'), isNull);
      expect(await cache.get('items:1'), isNull);
    });

    test('invalidateClaimsCache removes the claims list key', () async {
      await cache.set('claims:list', [
        {'id': 1}
      ]);
      await service.invalidateClaimsCache();
      expect(await cache.get('claims:list'), isNull);
    });
  });
}
