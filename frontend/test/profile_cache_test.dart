import 'package:test/test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/profile/data/profile_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ProfileService cache', () {
    final cache = SqliteCache();
    final service = ProfileService();

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await cache.init(dbPath: inMemoryDatabasePath);
    });

    tearDownAll(() async {
      await cache.close();
    });

    test('set and get profile', () async {
      final sample = {'email': 'u@x.com', 'full_name': 'User X'};
      await service.setProfile('u@x.com', sample);
      final res = await service.getProfile('u@x.com');
      expect(res, isNotNull);
      expect(res!['full_name'], 'User X');
    });

    test('invalidateProfile clears entry', () async {
      await service.setProfile('u2@x.com', {'email': 'u2@x.com'});
      await service.invalidateProfile(email: 'u2@x.com');
      final after = await cache.get('profile:u2@x.com');
      expect(after, isNull);
    });
  });
}
