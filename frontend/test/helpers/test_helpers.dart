import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Wraps [child] in a [ProviderScope] and [MaterialApp] for widget tests.
Widget wrapApp(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Initializes the sqflite FFI backend and opens the shared [SqliteCache]
/// against an in-memory database. Safe to call from `setUpAll`.
Future<SqliteCache> initInMemoryCache() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final cache = SqliteCache();
  await cache.init(dbPath: inMemoryDatabasePath);
  return cache;
}

const MethodChannel _secureStorageChannel =
    MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

/// Registers an in-memory mock for the flutter_secure_storage plugin so that
/// [AppSession] and services can read/write tokens during tests.
///
/// Returns the backing store so tests can assert on it directly.
Map<String, String> mockSecureStorage([Map<String, String>? initial]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = <String, String>{...?initial};

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_secureStorageChannel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key']?.toString();
    switch (call.method) {
      case 'write':
        if (key != null) store[key] = args['value']?.toString() ?? '';
        return null;
      case 'read':
        return key == null ? null : store[key];
      case 'delete':
        if (key != null) store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return key != null && store.containsKey(key);
      default:
        return null;
    }
  });

  return store;
}

/// Removes the secure storage mock handler.
void clearSecureStorageMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_secureStorageChannel, null);
}

/// Resets the static [AppSession] fields back to their defaults between tests.
void resetAppSession() {
  AppSession.role = AppUserRole.user;
  AppSession.email = '';
  AppSession.displayName = '';
  AppSession.userId = null;
}
