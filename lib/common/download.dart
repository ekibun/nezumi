import 'package:nezumi/common/global.dart';
import 'package:nezumi/common/storage.dart';
import 'package:path/path.dart' as p;

class DownloadList extends DataStorage<Map> {
  DownloadList._() : super("download.json");

  Map getTask(
    String prefix,
    Map? req,
  ) {
    var task = data[prefix];
    if (task == null) {
      task = {
        "req": req,
      };
      data[prefix] = task;
      flush();
    }
    return task;
  }

  @override
  Map get defaultValue => {};

  static DownloadList? _inst;
  factory DownloadList() => _inst ??= DownloadList._();
}

mixin FileTask {
  String? prefix;
  late final Map task;

  Map? get(String url, {bool create = false, String? name}) {
    final prefix = this.prefix;
    if (prefix == null) return null;

    final files = task["files"] ??= {};
    var file = files[url];

    if (file is! Map && create) {
      // final hash =
      //     sha1.convert(utf8.encode(task["req"]["url"].toString())).toString();
      final fileName = name ?? url.split("?")[0].split("/").last;
      // TODO check conflict
      file = <String, dynamic>{
        "name": fileName,
      };
      files[url] = file;
      DownloadList().flush();
    }
    if (file is Map && file["done"] is! List<int>) {
      file["done"] = List<int>.from(file["done"] ?? []);
    }
    return file;
  }

  FileContext? openFile(String url, {bool create = false, String? name}) {
    final prefix = this.prefix;
    if (prefix == null) return null;
    final file = get(url, create: create, name: name);
    if (file == null) return null;
    return Global.fs.getContext(
      p.join(prefix, file["name"]),
      create: true,
      done: file["done"],
    );
  }
}
