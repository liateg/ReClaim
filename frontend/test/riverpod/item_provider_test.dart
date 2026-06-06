import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/items/data/items_service.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;

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

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

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

  test('itemsServiceProvider provides an ItemsService', () {
    final container = makeContainer();
    expect(container.read(itemsServiceProvider), isA<ItemsService>());
  });

  test('itemsListProvider returns cached items as maps', () async {
    await cache.set('items:list', [itemMap('1'), itemMap('2')]);
    final container = makeContainer();
    final items = await container.read(itemsListProvider.future);
    expect(items, hasLength(2));
    expect(items.first['id'], '1');
    expect(items.first['title'], 'Item 1');
  });

  test('itemByIdProvider returns a cached item map', () async {
    await cache.set('items:5', itemMap('5'));
    final container = makeContainer();
    final item = await container.read(itemByIdProvider('5').future);
    expect(item, isNotNull);
    expect(item!['id'], '5');
  });

  test('myItemsListProvider filters by the current user id', () async {
    AppSession.userId = 50;
    await cache.set('items:list', [
      itemMap('1', postedBy: 50),
      itemMap('2', postedBy: 99),
    ]);
    final container = makeContainer();
    final mine = await container.read(myItemsListProvider.future);
    expect(mine, hasLength(1));
    expect(mine.first['id'], '1');
  });
}
