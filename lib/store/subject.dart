import 'package:nezumi/store/storage.dart';
import 'package:torrent/bencode.dart';

class Source with BencodeObject<Source> {
  String? site;
  String? id;

  @override
  String encodeKey = "src";

  Source({
    this.site,
    this.id,
  });

  @override
  Source decode(data) {
    return Source(
      site: data["site"]?.toString(),
      id: data["id"]?.toString(),
    );
  }

  @override
  encode() {
    return {
      "site": site,
      "id": id,
    };
  }
}

class Subject with BencodeObject<Subject> {
  String? name;
  Map? image;
  String? summary;
  String? _collect;
  int defaultSrc = 0;
  List<Source> src = [];

  bool get isCollected => _collect != null;

  Source? getSource([int? id]) {
    final _id = id ?? defaultSrc;
    if (src.isEmpty) return null;
    if (_id >= src.length)
      return src.last;
    else if (_id < 0) return src.first;
    return src[_id];
  }

  Subject({
    this.name,
    this.image,
    this.summary,
    this.defaultSrc = 0,
    List<Source>? src,
  }) : src = src ?? [];

  void merge(Subject subject) {
    name = subject.name ?? name;
    image = subject.image ?? image;
    summary = subject.summary ?? summary;
    src.addAll(subject.src);
  }

  Subject.fromMap(Map map) {
    name = map["name"]?.toString();
    image = map["image"];
    summary = map["summary"]?.toString();
    defaultSrc = map["defaultSrc"] ?? 0;
    src.addAll(List.castFrom(map["src"] ?? []));
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
      "defaultSrc": defaultSrc,
      "src": src
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
