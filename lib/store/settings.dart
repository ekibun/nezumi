import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class Settings {
  abstract final String boxName;
  abstract final Map<String, dynamic> settings;
  late final Box _box;

  Settings() {
    _box = Hive.box(boxName);
  }

  Widget watchImpl(
    Widget Function(BuildContext context, Settings settings) builder,
  ) {
    return ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box box, widget) => builder(context, this));
  }

  dynamic operator [](String key) {
    final _info = settings[key];
    if (_info is! Map) return null;
    final data = _box.get(key);
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
      _box.put(key, option.keys.toList().indexOf(value));
    else if (option is List)
      _box.put(key, option.indexOf(value));
    else
      _box.put(key, value);
  }
}
