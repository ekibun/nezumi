import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:nezumi/common/storage.dart';

class Global {
  static late FileStorage _fs;
  static FileStorage get fs => _fs;
  static init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _fs = await FileStorage.getInstance();
    Hive.init(_fs.root.path);
    await Hive.openBox('settings');
  }
}
