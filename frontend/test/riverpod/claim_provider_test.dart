import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/claims/data/claims_service.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;

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

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('claimsServiceProvider provides a ClaimsService', () {
    final container = makeContainer();
    expect(container.read(claimsServiceProvider), isA<ClaimsService>());
  });

  test('claimsListProvider resolves the cached claims list', () async {
    await cache.set('claims:list', [
      {'id': 1, 'status': 'pending'},
      {'id': 2, 'status': 'approved'},
    ]);
    final container = makeContainer();
    final claims = await container.read(claimsListProvider.future);
    expect(claims, hasLength(2));
    expect(claims.first['id'], 1);
  });
}
