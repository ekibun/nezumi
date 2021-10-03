import 'package:flutter/widgets.dart';
import 'package:nezumi/store/storage.dart';

class Global {
  static late FileStorage _fs;
  static FileStorage get fs => _fs;
  static init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _fs = await FileStorage.getInstance();
  }
}
