import 'package:nezumi/store/storage.dart';
import 'package:torrent/bencode.dart';

class Subject with BencodeObject<Subject> {
  String? name;
  String? type;
  Map? image;
  String? summary;
  String? _collect;
  String? info;
  Map<String, dynamic> sites = {};

  bool get isCollected => _collect != null;

  Subject({
    this.name,
    this.type,
    this.image,
    this.summary,
    this.info,
    Map<String, dynamic>? sites,
  }) : sites = sites ?? {};

  void merge(Subject subject) {
    name = subject.name ?? name;
    image = subject.image ?? image;
    summary = subject.summary ?? summary;
    type = subject.type ?? type;
    info = subject.info ?? info;
    sites.addAll(subject.sites);
  }

  Subject.fromMap(Map map) {
    name = map["name"]?.toString();
    image = map["image"];
    summary = map["summary"]?.toString();
    info = map["info"]?.toString();
    sites.addAll(map["sites"] ?? {});
  }

  @override
  String encodeKey = 'subject';

  @override
  Subject decode(data) {
    return Subject.fromMap(data);
  }

  @override
  encode() {
    return {
      "name": name,
      "image": image,
      "summary": summary,
      "info": info,
      "sites": sites
    };
  }
}

class SubjectDB extends DataStorage<Map> {
  SubjectDB._() : super("subject") {
    data.forEach((key, value) {
      value._collect = key;
    });
  }

  void collect(Subject subject, bool collected) {
    if (collected) {
      assert(subject._collect == null);
      // TODO check conflict
      final key = subject.name ?? "";
      subject._collect = key;
      data[key] = subject;
    } else {
      data.remove(subject._collect);
      subject._collect = null;
    }
    flush();
  }

  @override
  Map<String, Subject> get defaultValue => {};

  static SubjectDB? _inst;
  factory SubjectDB() => _inst ??= SubjectDB._();
}
