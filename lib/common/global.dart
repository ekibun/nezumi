import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences _sp;
  static SharedPreferences get sp => _sp;
  static init() async {
    _sp = await SharedPreferences.getInstance();
  }
}
