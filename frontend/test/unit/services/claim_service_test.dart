import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/claims/data/claims_service.dart';

import '../../helpers/test_helpers.dart';

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

  tearDown(() {
    clearSecureStorageMock();
  });

  group('getClaims (cache-first)', () {
    test('returns the cached claims list', () async {
      await cache.set('claims:list', [
        {'id': 1, 'status': 'pending'},
        {'id': 2, 'status': 'approved'},
      ]);

      final claims = await service.getClaims();

      expect(claims, hasLength(2));
      expect(claims.first['id'], 1);
    });
  });

  group('getClaimById (cache-first)', () {
    test('returns the cached claim', () async {
      await cache.set('claims:3', {'id': 3, 'status': 'rejected'});
      // getClaimById forces a fresh fetch only when forceRefresh is true.
      final claim = await service.getClaimById('3');
      expect(claim['id'], 3);
      expect(claim['status'], 'rejected');
    });
  });

  group('invalidateClaimsCache', () {
    test('clears the list key', () async {
      await cache.set('claims:list', [
        {'id': 1}
      ]);
      await service.invalidateClaimsCache();
      expect(await cache.get('claims:list'), isNull);
    });

    test('clears a specific claim key when id provided', () async {
      await cache.set('claims:list', [
        {'id': 1}
      ]);
      await cache.set('claims:9', {'id': 9});
      await service.invalidateClaimsCache(id: '9');
      expect(await cache.get('claims:list'), isNull);
      expect(await cache.get('claims:9'), isNull);
    });
  });
}
