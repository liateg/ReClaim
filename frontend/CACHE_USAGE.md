# Frontend SQLite Cache — Integration Guide (up-to-date)

Purpose

- Central reference for using the SQLite-backed cache across frontend features (Items, Claims, Reports, Profile).
- Describe initialization, common cache keys, TTL recommendations, invalidation hooks, testing, and security guidance.

Files introduced

- `lib/core/cache/sqlite_cache.dart` — key/value JSON cache using `sqflite`.
- `lib/features/items/data/items_service.dart` — `items:list` and `items:{id}` cache usage.
- `lib/features/claims/data/claims_service.dart` — `claims:list` and `claims:{id}` cache usage.
- `lib/features/reports/data/reports_service.dart` — `reports:list` and `reports:{id}` cache usage.
- `lib/features/profile/data/profile_service.dart` — `profile:{email}` cache usage.
- Tests: `test/sqlite_cache_test.dart`, `test/claims_cache_test.dart`, `test/reports_cache_test.dart`, `test/profile_cache_test.dart`.

Dependencies

- Runtime:
  - `sqflite`
  - `path_provider`
  - `path`
- Dev/test only:
  - `sqflite_common_ffi` (so unit tests run in the Dart VM without platform channels)

Install

```bash
cd frontend
flutter pub get
```

Initialization

- App runtime (do this early, e.g. in `main()`):

```dart
import 'package:frontend/core/cache/sqlite_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqliteCache().init();
  runApp(MyApp());
}
```

- Tests (use ffi and in-memory DB):

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

setUpAll(() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await SqliteCache().init(dbPath: inMemoryDatabasePath);
});
```

Cache Keys & TTLs (current conventions)

- Items
  - List: `items:list` (TTL ~5 minutes)
  - Single: `items:{id}` (TTL ~10 minutes)
- Claims
  - List: `claims:list` (TTL ~5 minutes)
  - Single: `claims:{id}` (TTL ~10 minutes)
- Reports
  - List: `reports:list` (TTL ~5 minutes)
  - Single: `reports:{id}` (TTL ~10 minutes)
- Profile
  - Per user: `profile:{email}` (TTL ~5–15 minutes depending on volatility)

Usage patterns (recommended)

- Read-through cache for lists & details:
  1. Service checks `SqliteCache().get(key)`.
  2. If cache hit and not expired → return it.
  3. If miss → call backend, cache payload with `set(key, payload, ttl: ...)`, then return.

- Force-refresh option: services expose `forceRefresh` to ignore cache when necessary (e.g., manual pull-to-refresh).

- Mutation workflows (create/update/delete):
  - After successful backend mutation, call the service invalidate helper to clear stale keys:
    - `ItemsService().invalidateItemCache({id})`
    - `ClaimsService().invalidateClaimsCache({id})`
    - `ReportsService().invalidateReportsCache({id})`
    - `ProfileService().invalidateProfile(email: currentEmail)` on profile change or logout

Where invalidation is already wired

- `lib/features/items/data/mock_data.dart` calls `ItemsService().invalidateItemCache()` after add/update/delete (local dev).
- `lib/features/claims/data/mock/mock_claims.dart` calls `ClaimsService().invalidateClaimsCache()` after add/update/delete.
- `lib/features/reports/data/mock/mock_feedback_reports.dart` calls `ReportsService().invalidateReportsCache()` after add/update/delete.
- `lib/features/auth/Riverpod/auth_provider.dart` seeds profile cache on login/register and invalidates profile cache on logout.

Profile & Auth guidance

- Tokens: continue to store JWTs in `flutter_secure_storage` (do NOT store tokens in `SqliteCache`). The project uses `AuthService` and `AppSession` for secure storage.
- Profile data: ok to cache in `SqliteCache` under `profile:{email}`. Cache short (5–15m) and invalidate on profile updates and logout.
- Seeding: on login/register the app writes user data into `ProfileService.setProfile(...)` so UI can render instantly.

Testing

- Use `sqflite_common_ffi` for unit tests to run in Dart VM. Example tests are provided under `test/`:
  - `sqlite_cache_test.dart`
  - `claims_cache_test.dart`
  - `reports_cache_test.dart`
  - `profile_cache_test.dart`

- Run tests:

```bash
cd frontend
flutter pub get
flutter test test/sqlite_cache_test.dart
flutter test test/claims_cache_test.dart
flutter test test/reports_cache_test.dart
flutter test test/profile_cache_test.dart
```

- If you see `databaseFactory not initialized`, ensure `sqflite_common_ffi` is in `dev_dependencies` and each test calls `sqfliteFfiInit()` and sets `databaseFactory = databaseFactoryFfi`.

Security & privacy

- Do not cache secrets (JWT refresh tokens, passwords) in `SqliteCache`.
- If you must cache PII, consider encrypting payloads before writing to the DB or using secure storage for small sensitive objects.

CI & platform notes

- `sqflite` requires native tools on emulators/runners; for unit tests prefer `sqflite_common_ffi` which runs cross-platform in CI.
- For widget/integration tests that run on devices, prefer platform `sqflite` and ensure the runner has the required native toolchain.

Troubleshooting

- Common: `databaseFactory not initialized` → initialize FFI in tests.
- Cache shape changes: call `SqliteCache().clear()` on first launch after deploy, or change DB filename to force a fresh DB.
- Serialization: cache stores JSON; ensure values passed to `set` are JSON-serializable (maps, lists, primitives).

Quick examples

- Seed profile on login (already wired):

```dart
// in auth flow after successful login
await ProfileService().setProfile(userEmail, userPayload);
```

- Invalidate cache after update or logout:

```dart
await api.updateProfile(userEmail, payload);
await ProfileService().invalidateProfile(email: userEmail);

// logout
await AuthService().logout();
await ProfileService().invalidateProfile(email: userEmail);
```

Next integration steps

1. Replace mock data consumers across UI with the corresponding `*Service` calls:
   - `ItemsService.getItems()` / `getItemById()`
   - `ClaimsService.getClaims()` / `getClaimById()`
   - `ReportsService.getReports()` / `getReportById()`
   - `ProfileService.getProfile()`
2. Ensure every mutation calls the matching `invalidate*Cache()` helper after a successful backend response.
3. Add widget/integration tests for major screens to assert caching behaviour (optional).

Contact

- If you hit errors while integrating, paste failing test output and the screen file you edited; I can patch the wiring.

---

Updated: May 22, 2026

# Frontend SQLite Cache — Integration Guide

Purpose

- Provide a single reference for integrating the SQLite-backed cache into the Flutter frontend.
- Show how to initialize, use, invalidate, and test the cache for the `items` feature (example).

Files added

- `lib/core/cache/sqlite_cache.dart` — simple key/value JSON cache built on `sqflite`.
- `lib/features/items/data/items_service.dart` — service that checks cache before network and writes responses.
- `test/sqlite_cache_test.dart` — unit tests demonstrating cache behavior using ffi-backed sqlite.
- `lib/features/claims/data/claims_service.dart` — claims cache/service mirroring items behavior.
- `test/claims_cache_test.dart` — unit tests for claims cache usage.

Dependencies

- Runtime:
  - `sqflite`
  - `path_provider`
  - `path`
- Dev/test only:
  - `sqflite_common_ffi` (so tests run in the Dart VM)

Install

```bash
cd frontend
flutter pub get
```

Initialization

- Initialize the cache early in the app (e.g., in `main()` before `runApp()`):

```dart
import 'package:frontend/core/cache/sqlite_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqliteCache().init();
  runApp(MyApp());
}
```

- For tests, prefer an in-memory DB. Example test setup uses `sqflite_common_ffi`:

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

setUpAll(() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await SqliteCache().init(dbPath: inMemoryDatabasePath);
});
```

Usage (Items example)

- `ItemsService.getItems({bool forceRefresh=false, Duration? ttl})`:
  - Returns cached list if present and not expired.
  - On cache miss or `forceRefresh=true`, fetches from `/items` endpoint, caches response under key `items:list`.

- `ItemsService.getItemById(id, ...)`:
  - Uses `items:{id}` cache key for single items.

- Example UI usage (replace mock data):

```dart
class ItemsList extends StatefulWidget { ... }

class _ItemsListState extends State<ItemsList> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final items = await ItemsService().getItems();
      setState(() => _items = items);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // render _items
  }
}
```

Cache invalidation

- The service provides `ItemsService().invalidateItemCache({String? id})`.
  - Call this after any mutation that affects items (create/update/delete).
  - If you already call backend mutations (POST/PUT/DELETE), make sure to call invalidate after successful response.

Examples:

- After creating an item (network call succeeded):

```dart
await api.createItem(payload);
await ItemsService().invalidateItemCache(); // clears list cache
```

- After updating an item:

```dart
await api.updateItem(id, payload);
await ItemsService().invalidateItemCache(id: id);
```

- After deleting an item:

```dart
await api.deleteItem(id);
await ItemsService().invalidateItemCache(id: id);
```

Notes on the current mock data helper

- `lib/features/items/data/mock_data.dart` now calls `ItemsService().invalidateItemCache()` after add/remove/update so local dev flows keep cache consistent.
- If you switch UIs to call real network APIs, ensure you call `invalidateItemCache` after the network response.

TTL strategy & recommendations

- Default TTL used in `ItemsService`:
  - `items:list` cached for ~5 minutes (recommended)
  - `items:{id}` cached for ~10 minutes
- Choose TTL based on how fresh you want data to be. For higher consistency prefer shorter TTLs + explicit invalidation on mutations.

Testing

- Unit tests for `SqliteCache` are in `test/sqlite_cache_test.dart` and use `sqflite_common_ffi`.
- Run tests:

```bash
cd frontend
flutter pub get
flutter test test/sqlite_cache_test.dart
```

- If you see `databaseFactory not initialized`, ensure `sqflite_common_ffi` is in `dev_dependencies` and the test initializes `sqfliteFfiInit()` and `databaseFactory = databaseFactoryFfi`.

Troubleshooting

- "databaseFactory not initialized": tests need `sqflite_common_ffi` initialization.
- CI runners: ensure necessary native toolchain for `sqflite` exists on the runner. For pure unit tests prefer `sqflite_common_ffi` (no platform channels).
- Serialization: the cache stores JSON-encoded payloads. Ensure objects passed to `SqliteCache.set()` are JSON-serializable (maps, lists, primitives).

Security & privacy

- Avoid caching highly sensitive user data unless encrypted at rest.
- The backend already hides `verification_answer` from public item responses; do not cache server-only secrets.

Schema migrations & clearing cache

- `SqliteCache` stores key/value pairs; if you need to change shape of cached payloads, bump the DB file name (e.g., `frontend_cache_v2.db`) or call `SqliteCache().clear()` on first-run after deploy.

Roadmap / Next integration steps

1. Replace `mockItems` consumers with `ItemsService` calls in the UI screens (e.g., Discover, Item detail, Admin lists).
2. Ensure all create/update/delete flows call `ItemsService().invalidateItemCache()` after successful network responses.
   2b. Replace `mockClaims` consumers with `ClaimsService` calls and use `addMockClaim`/`updateMockClaim`/`removeMockClaim` helpers during local dev flows.
3. Add profile caching:

- Use `ProfileService` to cache per-user profile under `profile:{email}`.
- Seed the profile cache on login/register (this is done in `auth_provider.dart`).
- Invalidate profile cache on logout and after profile updates.
- Do NOT store JWTs or refresh tokens in the Sqlite cache — keep them in `flutter_secure_storage`.

3. Add tests for UI flows where caching is expected (integration or widget tests).
4. Consider expanding cache tables to store metadata (ETag, lastUpdated, version) if you need server-driven validation.

Contact

- If anything breaks while integrating, open an issue in the repo and tag `@your-frontend-team` with the failing test output and the screen/file you edited.

---

Created: May 22, 2026
