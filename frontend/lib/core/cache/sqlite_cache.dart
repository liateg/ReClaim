// Conditional export: use native sqlite implementation on IO, lightweight in-memory on web.
export 'sqlite_cache_io.dart' if (dart.library.html) 'sqlite_cache_web.dart';
