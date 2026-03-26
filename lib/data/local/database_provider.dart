import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';

part 'database_provider.g.dart';

/// Shared production database instance with SQLCipher encryption.
/// All feature providers should depend on this instead of AppDatabase.forTesting().
@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: 'db_encryption_key');
  if (key == null) {
    key = AppDatabase.generateEncryptionKey();
    await storage.write(key: 'db_encryption_key', value: key);
  }

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(dir.path, 'finme.db');

  final db = AppDatabase(
    DatabaseConnection(
      NativeDatabase(
        File(dbPath),
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = '$key'");
        },
      ),
    ),
  );

  ref.onDispose(() => db.close());
  return db;
}
