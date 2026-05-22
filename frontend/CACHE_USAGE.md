# Frontend SQLite Cache — Integration Guide

Purpose
- Provide a single reference for integrating the SQLite-backed cache into the Flutter frontend.
- Show how to initialize, use, invalidate, and test the cache for the `items` feature (example).

Files added
- `lib/core/cache/sqlite_cache.dart` — simple key/value JSON cache built on `sqflite`.
- `lib/features/items/data/items_service.dart` — service that checks cache before network and writes responses.
- `test/sqlite_cache_test.dart` — unit tests demonstrating cache behavior using ffi-backed sqlite.

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
3. Add tests for UI flows where caching is expected (integration or widget tests).
4. Consider expanding cache tables to store metadata (ETag, lastUpdated, version) if you need server-driven validation.

Contact
- If anything breaks while integrating, open an issue in the repo and tag `@your-frontend-team` with the failing test output and the screen/file you edited.

---
Created: May 22, 2026
