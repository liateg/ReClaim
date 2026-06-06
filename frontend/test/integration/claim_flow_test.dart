import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/claims/data/claims_service.dart';

import '../helpers/test_helpers.dart';

/// Offline claim flow: list claims, open one, then invalidate the cache.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  final service = ClaimsService();

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    mockSecureStorage({'token': 'token123'});
    await cache.clear();
  });

  tearDown(clearSecureStorageMock);

  test('list and open a claim end-to-end from the cache', () async {
    await cache.set('claims:list', [
      {'id': 1, 'status': 'pending'},
      {'id': 2, 'status': 'approved'},
    ]);
    await cache.set('claims:2', {'id': 2, 'status': 'approved'});

    final claims = await service.getClaims();
    expect(claims, hasLength(2));
    expect(claims.first['id'], 1);

    final claim = await service.getClaimById('2');
    expect(claim['id'], 2);
    expect(claim['status'], 'approved');
  });

  test('invalidating clears the list and the specific claim', () async {
    await cache.set('claims:list', [
      {'id': 1}
    ]);
    await cache.set('claims:9', {'id': 9});

    await service.invalidateClaimsCache(id: '9');

    expect(await cache.get('claims:list'), isNull);
    expect(await cache.get('claims:9'), isNull);
  });
}
