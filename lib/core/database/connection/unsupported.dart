import 'package:drift/drift.dart';

Never _unsupported() => throw UnsupportedError(
      'No suitable database implementation was found on this platform.',
    );

QueryExecutor openConnection() => _unsupported();
DatabaseConnection inMemoryConnection() => _unsupported();
