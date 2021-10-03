import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_ffplay/flutter_ffplay.dart';
import 'package:nezumi/store/storage.dart';
import 'package:nezumi/engine/http.dart';
import 'package:nezumi/store/download.dart';

class _HttpResponse {
  static const int _initSize = 1024;
  static final _emptyList = Uint8List(0);
  int _bufferlength = 0;
  Uint8List _buffer;

  void add(List<int> bytes) {
    int byteCount = bytes.length;
    if (byteCount == 0) return;
    int required = _bufferlength + byteCount;
    if (_buffer.length < required) {
      _grow(required);
    }
    assert(_buffer.length >= required);
    _buffer.setRange(_bufferlength, required, bytes);
    _bufferlength = required;
  }

  int takeBytes(Uint8List target) {
    final byteTaken = min(target.length, _bufferlength);
    target.setRange(0, byteTaken, _buffer);
    takeOut(byteTaken);
    return byteTaken;
  }

  void takeOut(int byteTaken) {
    if (byteTaken <= 0) return;
    _offset += byteTaken;
    _bufferlength -= byteTaken;
    for (var i = 0; i < _bufferlength; ++i) {
      _buffer[i] = _buffer[i + byteTaken];
    }
    if (_bufferlength <= 0) _buffer = _emptyList;
  }

  void _grow(int required) {
    int newSize = required * 2;
    if (newSize < _initSize) {
      newSize = _initSize;
    } else {
      newSize = _pow2roundup(newSize);
    }
    var newBuffer = Uint8List(newSize);
    newBuffer.setRange(0, _buffer.length, _buffer);
    _buffer = newBuffer;
  }

  static int _pow2roundup(int x) {
    assert(x > 0);
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1;
  }

  int _offset = 0;
  final Response rsp;
  final StreamController _onData = StreamController.broadcast();
  late StreamSubscription _sub;
  bool get isClosed => _onData.isClosed;
  final HttpIOContext _ctx;
  late String fileName;
  int? length;

  _HttpResponse(this._ctx, this._offset, this.rsp, int maxBufferSize)
      : _buffer = _emptyList {
    final disposition = rsp.headers.value("content-disposition");
    final match = RegExp("filename=\"(.*?)\"").firstMatch(disposition ?? "");
    if (match != null)
      fileName = match.group(1)!;
    else
      fileName = rsp.realUri.toString().split("?")[0].split("/").last;
    try {
      if (rsp.statusCode == 206) {
        length = int.parse(
            rsp.headers.value(HttpHeaders.contentRangeHeader)!.split("/").last);
      } else
        length = int.parse(rsp.headers.value(HttpHeaders.contentLengthHeader)!);
    } catch (e) {
      length = null;
    }
    _sub = (rsp.data as ResponseBody).stream.listen((data) {
      try {
        final f = _ctx._task.task.files
            .putIfAbsent(_ctx.url, () => DownloadFile(name: fileName));
        final file = _ctx._file ??= _ctx._task.getFile(f);
        file?.write(_offset + _bufferlength, data).then(
          (value) {
            DownloadDB().flush();
          },
        );
      } catch (e) {
        print(e);
      }
      add(data);
      _onData.add(null);
      if (_bufferlength > maxBufferSize) _sub.pause();
    }, onDone: () => _onData.close());
  }

  close() async {
    _sub.cancel();
  }
}

class HttpIOHandler extends IOHandler with FileTask {
  HttpIOHandler(
    DownloadTask task, [
    int bufferSize = 32768,
  ]) : super(bufferSize) {
    this.task = task;
  }

  @override
  Future<IOContext> open(String url) async {
    return HttpIOContext(url, this);
  }
}

class HttpIOContext extends IOContext {
  int _offset = 0;
  int _length = 0;
  final FileTask _task;
  FileContext? _file;
  _HttpResponse? __rsp;

  Future<_HttpResponse> getRange(int start) async {
    final Map rangeReq = {
      "redirect": "follow",
      ...(_task.task.req ?? {}),
      "url": url,
      "headers": {
        ...(_task.task.req?["headers"] ?? {}),
        HttpHeaders.rangeHeader: "bytes=$start-",
      }
    };
    final rsp = await Http.request(rangeReq, responseType: ResponseType.stream);
    final ret = _HttpResponse(
      this,
      rsp.statusCode == 206 ? start : 0,
      rsp,
      128 * 1024,
    );
    final file = _task.task.files.putIfAbsent(
      url,
      () => DownloadFile(name: ret.fileName),
    );
    file.length = _length;
    DownloadDB().flush();
    return ret;
  }

  Future<_HttpResponse> get _rsp async {
    var rsp = __rsp ??= await getRange(_offset);
    if (rsp._offset <= _offset && rsp._offset + rsp._bufferlength >= _offset) {
      /*
       * [///|///buffer///////]
       *   offset
       */
      rsp.takeOut(_offset - rsp._offset);
    } else if (rsp._offset + rsp._bufferlength < _offset) {
      /*
       * [////buffer////]   |
       *                  offset
       */
      final newRsp = await getRange(_offset);
      if (newRsp._offset + newRsp._bufferlength >
          rsp._offset + rsp._bufferlength) {
        rsp.close();
        rsp = __rsp = newRsp;
      } else {
        // not support content-range
        newRsp.close();
      }
      // consume
      while (true) {
        if (rsp._offset + rsp._bufferlength >= _offset) {
          rsp.takeOut(_offset - rsp._offset);
          break;
        } else {
          rsp.takeOut(rsp._bufferlength);
        }
        if (rsp._sub.isPaused) rsp._sub.resume();
        await rsp._onData.stream.first;
      }
    } else {
      /*
       *   |    [////buffer////]
       * offset
       */
      __rsp?.close();
      __rsp = null;
      return _rsp;
    }
    return rsp;
  }

  String url;

  HttpIOContext(this.url, this._task);

  @override
  Future<int> read(Uint8List buf) async {
    final fileInfo = _task.task.files[url];
    if (fileInfo != null) {
      if ((fileInfo.length ?? 0) > 0 && _offset >= fileInfo.length!)
        return -1; // EOF
      final file = _file ??= _task.getFile(fileInfo);
      if (file != null) {
        final range = await file.read(_offset, buf);
        if (range > 0) {
          _offset += range;
          return range;
        }
      }
    }
    final rsp = await _rsp;
    if (rsp._sub.isPaused) rsp._sub.resume();
    while (true) {
      final range = rsp.takeBytes(buf);
      if (range == 0 && rsp.isClosed) return -1;
      if (range == 0) {
        try {
          await rsp._onData.stream.first;
        } catch (e) {
          return -1;
        }
        continue;
      }
      _offset += range;
      return range;
    }
  }

  @override
  Future<int> seek(int offset, int whence) async {
    switch (whence) {
      case AVSEEK_SIZE:
        if (_length != 0) return _length;
        final file = _task.task.files[url];
        if (file?.length != null) {
          return _length = file!.length!;
        }
        await _rsp;
        return _length;
      default:
        _offset = offset;
        return 0;
    }
  }

  @override
  Future<int> close() async {
    await __rsp?.close();
    await _file?.close();
    return 0;
  }
}
