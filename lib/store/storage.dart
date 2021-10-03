import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:nezumi/store/download.dart';
import 'package:nezumi/store/global.dart';
import 'package:nezumi/store/subject.dart';
import 'package:path_provider/path_provider.dart';
import 'package:torrent/bencode.dart';
import 'package:path/path.dart' as p;

class FileContext {
  int _ref = 0;
  Completer? _lock;

  RandomAccessFile? f;
  final List<int> _done;
  FileContext._(this.f, this._done);

  int get length {
    int sum = 0;
    for (int i = 0; i + 1 < _done.length; i += 2) {
      sum += _done[i + 1] - _done[i];
    }
    return sum;
  }

  Future<void> close() async {
    _ref--;
    if (_ref <= 0) {
      final lastLock = _lock;
      final lock = Completer();
      _lock = lock;
      await lastLock?.future;

      await f?.close();
      lock.completeError("cancel");
      f = null;
    }
  }

  Uint8List readSync() {
    f!.setPositionSync(0);
    return f!.readSync(f!.lengthSync());
  }

  Future<Uint8List> readAll() async {
    final lastLock = _lock;
    final lock = Completer();
    _lock = lock;
    await lastLock?.future;

    try {
      await f!.setPosition(0);
      return await f!.read(await f!.length());
    } finally {
      lock.complete();
    }
  }

  Future<void> writeAll(List<int> buf) async {
    final lastLock = _lock;
    final lock = Completer();
    _lock = lock;
    await lastLock?.future;

    try {
      // update range
      _done.clear();
      _done.addAll([0, buf.length]);
      // save
      await f!.setPosition(0);
      await f!.writeFrom(buf);
      await f!.truncate(buf.length);
      await f!.flush();
    } finally {
      lock.complete();
    }
  }

  Future<int> read(int offset, List<int> buf) async {
    // check avaliable
    var len = 0;
    for (int i = 0; i + 1 < _done.length; i += 2) {
      final st = _done[i];
      final ed = _done[i + 1];
      if (st <= offset && ed > offset) {
        len = min(buf.length, ed - offset);
        break;
      }
    }
    if (len == 0) return 0;
    // read
    final lastLock = _lock;
    final lock = Completer();
    _lock = lock;
    await lastLock?.future;

    try {
      await f!.setPosition(offset);
      return await f!.readInto(buf, 0, len);
    } finally {
      lock.complete();
    }
  }

  Future<void> write(int offset, List<int> buf) async {
    final lastLock = _lock;
    final lock = Completer();
    _lock = lock;
    await lastLock?.future;

    try {
      // update range
      final rangeStart = offset;
      final rangeEnd = offset + buf.length;
      int i = 0;
      for (; i + 1 < _done.length; i += 2) {
        if (_done[i + 1] < rangeStart) continue;
        int j = i;
        for (; j + 1 < _done.length; j += 2) {
          if (_done[j] > rangeEnd) break;
        }
        final st = min(rangeStart, _done[i]);
        final ed = j > 0 ? max(rangeEnd, _done[j - 1]) : rangeEnd;
        _done.replaceRange(i, j, [st, ed]);
        break;
      }
      if (i >= _done.length) _done.addAll([rangeStart, rangeEnd]);
      // save
      await f!.setPosition(offset);
      await f!.writeFrom(buf);
      await f!.flush();
    } finally {
      lock.complete();
    }
  }
}

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

  final Map<String, FileContext> _ctx = {};
  FileContext getContext(
    String path, {
    bool create = false,
    List<int>? done,
  }) {
    var ctx = _ctx[path];
    if (ctx == null) {
      final f = File(p.normalize(p.join(root.path, path)));
      if (create && !(f.existsSync())) {
        f.createSync(recursive: true);
      }
      ctx = FileContext._(f.openSync(mode: FileMode.append), done ?? []);
      _ctx[path] = ctx;
    }
    ctx._ref += 1;
    return ctx;
  }

  Future<Iterable<String>> list(String path) async {
    final dir = Directory(p.normalize(p.join(root.path, path)));
    if (await dir.exists()) {
      return (await dir.list().toList())
          .whereType<Directory>()
          .map((e) => p.basename(e.path));
    }
    return [];
  }
}

abstract class DataStorage<T> extends ChangeNotifier {
  final FileContext _ctx;
  late final T data;
  T get defaultValue;

  static final _extendObject = <BencodeObject>[
    Source(),
    Subject(),
    DownloadTask(),
    DownloadFile(),
  ];

  static registerDecodeData(int id, List<int> Function(dynamic) data) {}

  DataStorage(String path) : _ctx = Global.fs.getContext(path, create: true) {
    try {
      data = Bencode.decode(_ctx.readSync(), extend: _extendObject);
    } catch (e, stack) {
      print(stack);
      data = defaultValue;
    }
  }

  Future<void> close() async => _ctx.close();

  Future? _flushTask;
  int _lastTime = 0;
  void flush() {
    notifyListeners();
    if (_flushTask == null) {
      final last = _lastTime;
      _lastTime = DateTime.now().millisecondsSinceEpoch;
      _flushTask = Future.delayed(
        Duration(milliseconds: min(1000, _lastTime - last)),
        () {
          _flushTask = null;
          _ctx.writeAll(Bencode.encode(data));
        },
      );
    }
  }
}

abstract class Settings extends DataStorage<Map> {
  @override
  Map get defaultValue => {};

  abstract final Map<String, dynamic> settings;

  Settings(String path) : super(path);

  dynamic operator [](String key) {
    final _info = settings[key];
    if (_info is! Map) return null;
    final data = this.data[key];
    final option = _info[#option];
    if (option is Map)
      return option.keys.toList()[data ?? 0];
    else if (option is List)
      return option[data ?? 0];
    else
      return data;
  }

  void operator []=(String key, dynamic value) {
    final _info = settings[key];
    if (_info is! Map) return;
    final option = _info[#option];
    if (option is Map)
      this.data[key] = option.keys.toList().indexOf(value);
    else if (option is List)
      this.data[key] = option.indexOf(value);
    else
      this.data[key] = value;
    flush();
  }
}
