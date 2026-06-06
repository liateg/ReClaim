import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/claims/data/claims_service.dart';
import 'package:frontend/features/items/data/items_service.dart';

import '../helpers/test_helpers.dart';

/// Offline admin flow: an admin signs in, then reviews the admin item list and
/// the claims queue served from the cache.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  final itemsService = ItemsService();
  final claimsService = ClaimsService();

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    mockSecureStorage({'token': 'admin-token'});
    resetAppSession();
    await cache.clear();
  });

  tearDown(clearSecureStorageMock);

  Map<String, dynamic> itemMap(String id) => {
        'id': id,
        'title': 'Item $id',
        'location': 'Office',
        'description': 'Desc',
        'category': 'Electronics',
        'category_id': 1,
        'status': 'available',
        'image_url': '',
      };

  test('an admin session is recognised as admin', () async {
    await AppSession.signIn(
      role: AppUserRole.admin,
      email: 'admin@aau.edu.et',
      displayName: 'Site Admin',
      userId: 1,
    );

    expect(AppSession.isAdmin, isTrue);
    expect(await AppSession.isLoggedIn(), isTrue);
  });

  test('admin reviews cached items and claims', () async {
    await AppSession.signIn(
      role: AppUserRole.admin,
      email: 'admin@aau.edu.et',
      displayName: 'Site Admin',
      userId: 1,
    );

    await cache.set('items:admin', [itemMap('7'), itemMap('8')]);
    await cache.set('claims:list', [
      {'id': 1, 'status': 'pending'},
      {'id': 2, 'status': 'pending'},
      {'id': 3, 'status': 'approved'},
    ]);

    final adminItems = await itemsService.getAdminItems();
    expect(adminItems.map((i) => i.id), containsAll(['7', '8']));

    final claims = await claimsService.getClaims();
    final pending =
        claims.where((c) => c['status'] == 'pending').toList();
    expect(claims, hasLength(3));
    expect(pending, hasLength(2));
  });
}
