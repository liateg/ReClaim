// On-device / on-emulator integration test.
//
// Unlike the offline tests under test/integration/, this suite runs the REAL
// app code on a connected emulator or device and talks to your live backend.
// Because it runs inside the Android emulator, ApiConfig.baseUrl resolves to
// http://10.0.2.2:3000 (the emulator's alias for the host machine), and the
// native flutter_secure_storage + sqflite plugins are available — no mocks.
//
// Prerequisites before running:
//   1. Start the backend on the host machine at port 3000.
//   2. Boot an emulator/device (see the run instructions shared in chat).
//   3. Make sure the credentials below exist in your backend, or override them
//      with --dart-define (TEST_EMAIL / TEST_PASSWORD).
//
// Run with:
//   flutter test integration_test/backend_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/core/session/services/auth_service.dart';
import 'package:frontend/features/items/data/items_service.dart';
import 'package:frontend/features/claims/data/claims_service.dart';
import 'package:frontend/features/reports/data/reports_service.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

const _email = String.fromEnvironment('TEST_EMAIL',
    defaultValue: 'admin@example.com');
const _password = String.fromEnvironment('TEST_PASSWORD',
    defaultValue: 'TestPass123!');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final auth = AuthService();

  setUpAll(() async {
    await SqliteCache().init();
  });

  tearDownAll(() async {
    await auth.logout();
  });

  group('Backend integration (live server via 10.0.2.2:3000)', () {
    testWidgets('logs in and persists a session token', (tester) async {
      final response = await auth.login(_email, _password);

      final token =
          (response['accessToken'] ?? response['token'])?.toString();
      expect(token, isNotNull,
          reason: 'Backend should return an accessToken/token on login');

      await AppSession.saveToken(token!);
      expect(await AppSession.getToken(), token);
      expect(await AppSession.isLoggedIn(), isTrue);
    });

    testWidgets('fetches items and maps them to ItemModel', (tester) async {
      final items = await ItemsService().getItems(forceRefresh: true);
      expect(items, isA<List<ItemModel>>());

      // Cache should now hold the list under items:list.
      final cached = await SqliteCache().get<List<dynamic>>('items:list');
      expect(cached, isNotNull);
      expect(cached!.length, items.length);
    });

    testWidgets('fetches claims from the backend', (tester) async {
      final claims = await ClaimsService().getClaims(forceRefresh: true);
      expect(claims, isA<List>());

      final cached = await SqliteCache().get<List<dynamic>>('claims:list');
      expect(cached, isNotNull);
    });

    testWidgets('fetches reports from the backend', (tester) async {
      final reports = await ReportsService().getReports(forceRefresh: true);
      expect(reports, isA<List>());

      final cached = await SqliteCache().get<List<dynamic>>('reports:list');
      expect(cached, isNotNull);
    });
  });
}
