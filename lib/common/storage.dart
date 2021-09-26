import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileStorage {
  Directory root;
  FileStorage._(this.root);

  static Completer<FileStorage>? _inst;

  static Future<FileStorage> getInstance() async {
    final inst = _inst ?? Completer<FileStorage>();
    if (_inst == null) {
      _inst = inst;
      try {
        final dir = await getApplicationSupportDirectory();
        print(dir);
        inst.complete(FileStorage._(dir));
      } catch (e, stack) {
        inst.completeError(e, stack);
      }
    }
    return inst.future;
  }

  Map<String, Completer> _lock = {};

  Future saveObject(Uint8List bytes, String path) async {
    await _lock[path]?.future;
    final lock = Completer();
    _lock[path] = lock;
    final f = File(p.normalize(p.join(root.path, path)));
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes);
    lock.complete();
  }

  Future<Uint8List?> getObject(String path) async {
    await _lock[path]?.future;
    final lock = Completer();
    _lock[path] = lock;
    final f = File(p.normalize(p.join(root.path, path)));
    if (await f.exists()) {
      return f.readAsBytes();
    }
    lock.complete();
  }

  Future<Iterable<String>> list(String path) async {
    final dir = Directory(p.normalize(p.join(root.path, path)));
    if (await dir.exists()) {
      return (await dir.list().toList()).map((e) => p.basename(e.path));
    }
    return [];
  }
}
