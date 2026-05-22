import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/items/data/models/item_model.dart';
import 'package:frontend/features/claims/data/models/claim_model.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:frontend/features/reports/data/models/report_model.dart';

void main() {
  group('Integration: Items/Claims/Profile -> Cache -> Model -> Backend', () {
    final cache = SqliteCache();
    final dio = Dio()..options.baseUrl = 'http://localhost:3000';
    String? token;

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await cache.init(dbPath: inMemoryDatabasePath);
    });

    tearDownAll(() async {
      await cache.close();
    });

    test('login to backend', () async {
      print('Attempting login to backend...');
      final loginRes = await dio.post('/auth/login', data: {
        'email': 'admin@example.com',
        'password': 'TestPass123!',
      });

      expect(loginRes.statusCode, anyOf(200, 201));
      token = loginRes.data['accessToken'] as String?;
      expect(token, isNotNull);
      print('Received token: ${token!.substring(0, 10)}...');
    });

    test('items: fetch, map, cache, expiry', () async {
      // Fetch items (authenticated)
      print('Requesting /items from backend...');
      final itemsRes = await dio.get('/items',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      expect(itemsRes.statusCode, 200);
      final itemsList = (itemsRes.data['items'] as List).cast<dynamic>();
      print('Backend returned ${itemsList.length} items.');
      expect(itemsList, isNotEmpty);

      final first = Map<String, dynamic>.from(itemsList.first as Map);
      final model = ItemModel.fromJson(first);
      print('Mapped first item to ItemModel: id=${model.id}, title=${model.title}');
      expect(model.id, isNotNull);

      await cache.set('items:list', itemsList, ttl: Duration(seconds: 2));
      final cached = await cache.get<List<dynamic>>('items:list');
      expect(cached, isNotNull);
      expect(cached!.length, itemsList.length);
      print('Cached ${cached.length} items under key items:list');

      await Future.delayed(Duration(seconds: 3));
      final afterExpiry = await cache.get<List<dynamic>>('items:list');
      expect(afterExpiry, isNull);
      print('Items cache expired as expected');
    });

    test('claims: fetch, map, cache, expiry', () async {
      print('Requesting /claims from backend...');
      final claimsRes = await dio.get('/claims',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      expect(claimsRes.statusCode, 200);

      final claimsList = (claimsRes.data['claims'] as List).cast<dynamic>();
      print('Backend returned ${claimsList.length} claims.');
      expect(claimsList, isNotEmpty);

      final first = Map<String, dynamic>.from(claimsList.first as Map);
      final claimModel = ClaimModel.fromJson(first);
      print('Mapped first claim: id=${claimModel.id}, itemId=${claimModel.itemId}, status=${claimModel.status}');
      expect(claimModel.id, isNotNull);

      await cache.set('claims:list', claimsList, ttl: Duration(seconds: 2));
      final cached = await cache.get<List<dynamic>>('claims:list');
      expect(cached, isNotNull);
      expect(cached!.length, claimsList.length);
      print('Cached ${cached.length} claims under key claims:list');

      await Future.delayed(Duration(seconds: 3));
      final afterExpiry = await cache.get<List<dynamic>>('claims:list');
      expect(afterExpiry, isNull);
      print('Claims cache expired as expected');
    });

    test('reports: fetch, map, cache, expiry', () async {
      print('Requesting /reports from backend...');
      final reportsRes = await dio.get('/reports',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      expect(reportsRes.statusCode, 200);

      final reportsList = (reportsRes.data['reports'] as List).cast<dynamic>();
      print('Backend returned ${reportsList.length} reports.');
      expect(reportsList, isNotEmpty);

      final first = Map<String, dynamic>.from(reportsList.first as Map);
      final reportModel = ReportModel.fromJson(first);
      print('Mapped first report: id=${reportModel.id}, reason=${reportModel.reason}, status=${reportModel.status}');
      expect(reportModel.id, isNotNull);

      await cache.set('reports:list', reportsList, ttl: Duration(seconds: 2));
      final cached = await cache.get<List<dynamic>>('reports:list');
      expect(cached, isNotNull);
      expect(cached!.length, reportsList.length);
      print('Cached ${cached.length} reports under key reports:list');

      await Future.delayed(Duration(seconds: 3));
      final afterExpiry = await cache.get<List<dynamic>>('reports:list');
      expect(afterExpiry, isNull);
      print('Reports cache expired as expected');
    });

    test('profile: fetch current user and map to ProfileModel', () async {
      print('Requesting /auth/me from backend...');
      final meRes = await dio.get('/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      expect(meRes.statusCode, 200);

      final user = Map<String, dynamic>.from(meRes.data['user'] as Map);
      // Normalize backend `full_name` into `name` expected by ProfileModel
      final normalized = {
        'id': user['id'],
        'email': user['email'],
        'name': user['full_name'] ?? user['name'] ?? '',
        'phone': user['phone'] ?? null,
        'avatar_url': user['avatar_url'] ?? null,
        'created_at': user['created_at'] ?? null,
        'updated_at': user['updated_at'] ?? null,
      };

      final profile = ProfileModel.fromJson(normalized);
      print('Mapped profile: id=${profile.id}, email=${profile.email}, name=${profile.name}');
      expect(profile.email, isNotEmpty);

      final profileCacheKey = 'profile:${profile.email}';
      await cache.set(profileCacheKey, normalized, ttl: Duration(seconds: 2));
      final cached = await cache.get<Map<String, dynamic>>(profileCacheKey);
      expect(cached, isNotNull);
      expect(cached!['email'], profile.email);

      await Future.delayed(Duration(seconds: 3));
      final afterExpiry = await cache.get<Map<String, dynamic>>(profileCacheKey);
      expect(afterExpiry, isNull);
      print('Profile cache expired as expected');
    });
  });
}
