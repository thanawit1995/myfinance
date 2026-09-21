import 'sqlite_workaround_stub.dart'
    if (dart.library.io) 'sqlite_workaround_io.dart';

Future<void> applySqliteWorkaround() => applyPlatformSqliteWorkaround();
