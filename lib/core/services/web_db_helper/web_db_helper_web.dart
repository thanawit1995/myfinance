// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/wasm.dart';
import 'package:web/web.dart' as web;

Future<bool> restoreWebDatabase(Uint8List bytes) async {
  bool success = false;

  // 1. Restore to OPFS if supported
  try {
    final nav = web.window.navigator;
    final storage = nav.storage;
    final root = await storage.getDirectory().toDart;
    final driftDir = await root
        .getDirectoryHandle('drift_db', web.FileSystemGetDirectoryOptions(create: true))
        .toDart;
    final vaultDir = await driftDir
        .getDirectoryHandle('myfinance_vault', web.FileSystemGetDirectoryOptions(create: true))
        .toDart;
    final file = await vaultDir
        .getFileHandle('database', web.FileSystemGetFileOptions(create: true))
        .toDart;
    final writable = await file.createWritable().toDart;
    await writable.write(bytes.toJS).toDart;
    await writable.close().toDart;

    // Clean up temporary journals
    try {
      await vaultDir.removeEntry('database-journal').toDart;
    } catch (_) {}
    try {
      await vaultDir.removeEntry('database-wal').toDart;
    } catch (_) {}
    try {
      await vaultDir.removeEntry('database-shm').toDart;
    } catch (_) {}

    success = true;
    debugPrint('OPFS restore succeeded: ${bytes.length} bytes');
  } catch (e) {
    debugPrint('OPFS restore not used or failed: $e');
  }

  // 2. Restore to IndexedDbFileSystem (fallback / primary for GitHub Pages)
  try {
    final fs = await IndexedDbFileSystem.open(dbName: 'myfinance_vault');
    try {
      if (fs.xAccess('/database-journal', 0) != 0) {
        fs.xDelete('/database-journal', 0);
      }
    } catch (_) {}
    try {
      if (fs.xAccess('/database-wal', 0) != 0) {
        fs.xDelete('/database-wal', 0);
      }
    } catch (_) {}

    final (file: file, outFlags: _) =
        fs.xOpen(Sqlite3Filename('/database'), 0x00000002 | 0x00000004);
    file.xTruncate(0);
    file.xWrite(bytes, 0);
    file.xClose();
    await fs.close();
    success = true;
    debugPrint('IndexedDB restore succeeded: ${bytes.length} bytes');
  } catch (e) {
    debugPrint('IndexedDB restore error: $e');
  }

  return success;
}

Future<Uint8List?> exportWebDatabase() async {
  // 1. Try reading from OPFS
  try {
    final nav = web.window.navigator;
    final storage = nav.storage;
    final root = await storage.getDirectory().toDart;
    final driftDir = await root.getDirectoryHandle('drift_db').toDart;
    final vaultDir = await driftDir.getDirectoryHandle('myfinance_vault').toDart;
    final file = await vaultDir.getFileHandle('database').toDart;
    final blob = await file.getFile().toDart;
    final arrayBuffer = await blob.arrayBuffer().toDart;
    final bytes = arrayBuffer.toDart.asUint8List();
    if (bytes.isNotEmpty) {
      return bytes;
    }
  } catch (_) {}

  // 2. Fallback to IndexedDbFileSystem
  try {
    final fs = await IndexedDbFileSystem.open(dbName: 'myfinance_vault');
    if (fs.xAccess('/database', 0) != 0) {
      final (file: file, outFlags: _) =
          fs.xOpen(Sqlite3Filename('/database'), 0x00000002);
      final size = file.xFileSize();
      if (size > 0) {
        final buffer = Uint8List(size);
        file.xRead(buffer, 0);
        file.xClose();
        await fs.close();
        return buffer;
      }
      file.xClose();
    }
    await fs.close();
  } catch (e) {
    debugPrint('IndexedDB export error: $e');
  }

  return null;
}

void reloadWebPage() {
  html.window.location.reload();
}
