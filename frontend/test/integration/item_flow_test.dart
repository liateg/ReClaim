import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/items/data/items_service.dart';

import '../helpers/test_helpers.dart';

/// Offline item flow: browse the catalogue, open a single item, filter the
/// signed-in user's own postings, then invalidate the cache.
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

  tearDown(clearSecureStorageMock);

  Map<String, dynamic> itemMap(String id, {int? postedBy}) => {
        'id': id,
        'title': 'Item $id',
        'location': 'Library',
        'description': 'A lost item',
        'category': 'Electronics',
        'category_id': 1,
        'status': 'available',
        'image_url': '',
        if (postedBy != null) 'posted_by': postedBy,
      };

  test('browse, open and filter the current user\'s items end-to-end',
      () async {
    AppSession.userId = 100;
    await cache.set('items:list', [
      itemMap('1', postedBy: 100),
      itemMap('2', postedBy: 200),
      itemMap('3', postedBy: 100),
    ]);
    await cache.set('items:2', itemMap('2', postedBy: 200));

    final all = await service.getItems();
    expect(all, hasLength(3));

    final detail = await service.getItemById('2');
    expect(detail, isNotNull);
    expect(detail!.title, 'Item 2');

    final mine = await service.getMyPostedItems();
    expect(mine.map((i) => i.id), containsAll(['1', '3']));
    expect(mine.any((i) => i.id == '2'), isFalse);
  });

  test('invalidating the cache removes the list and detail entries', () async {
    await cache.set('items:list', [itemMap('1')]);
    await cache.set('items:admin', [itemMap('1')]);
    await cache.set('items:1', itemMap('1'));

    await service.invalidateItemCache(id: '1');

    expect(await cache.get('items:list'), isNull);
    expect(await cache.get('items:admin'), isNull);
    expect(await cache.get('items:1'), isNull);
  });

  test('claiming an item with an invalid id fails before any network call',
      () async {
    expect(
      () => service.submitClaim(itemId: 'not-a-number', answer: 'mine'),
      throwsA(isA<Exception>()),
    );
  });
}
