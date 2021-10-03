import 'package:nezumi/store/global.dart';
import 'package:nezumi/store/storage.dart';
import 'package:path/path.dart' as p;
import 'package:torrent/bencode.dart';

class DownloadDB extends DataStorage<Map> {
  DownloadDB._() : super("download");

  @override
  Map<String, DownloadTask> get defaultValue => {};

  static DownloadDB? _inst;
  factory DownloadDB() => _inst ??= DownloadDB._();
}

class DownloadFile with BencodeObject<DownloadFile> {
  final String name;
  int? length;
  final List<int> dl;

  DownloadFile({
    this.name = "",
    List<int>? dl,
  }) : dl = dl ?? [];

  @override
  String encodeKey = "file";

  @override
  DownloadFile decode(data) {
    return DownloadFile(
      name: data["name"],
      dl: data["dl"],
    );
  }

  @override
  encode() {
    return {
      "name": name,
      "dl": dl,
    };
  }
}

class DownloadTask with BencodeObject<DownloadTask> {
  String? prefix;
  Map? req;
  final Map<String, DownloadFile> files;

  DownloadTask({
    this.prefix,
    this.req,
    Map<String, DownloadFile>? files,
  }) : files = files ?? {};

  @override
  String encodeKey = 'download';

  @override
  DownloadTask decode(data) {
    return DownloadTask(
      req: data["req"],
      files: data["files"],
    );
  }

  @override
  encode() {
    return {
      "req": req,
      "files": files,
    };
  }
}

mixin FileTask {
  late final DownloadTask task;

  FileContext? getFile(DownloadFile file) {
    final prefix = this.task.prefix;
    if (prefix == null) return null;
    return Global.fs.getContext(
      p.join(prefix, file.name),
      create: true,
      done: file.dl,
    );
  }
}
