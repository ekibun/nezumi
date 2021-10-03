import 'package:flutter/material.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/store/storage.dart';

class AppSettings extends Settings {
  static getTheme(bool dark) {
    final MaterialColor themeColor = AppSettings()['themeColor'];
    if (dark) {
      return ThemeData(
          brightness: Brightness.dark,
          primaryColor: themeColor,
          canvasColor: Colors.grey[850],
          hintColor: themeColor,
          backgroundColor: Colors.transparent,
          splashColor: themeColor.withAlpha(50),
          primaryColorBrightness: Brightness.dark);
    } else {
      return ThemeData(
          brightness: Brightness.light,
          primaryColor: themeColor,
          canvasColor: Colors.grey[200],
          hintColor: themeColor,
          backgroundColor: Colors.transparent,
          splashColor: themeColor.withAlpha(50),
          primaryColorBrightness: Brightness.dark);
    }
  }

  @override
  Map<String, dynamic> get settings => {
        'theme': (S s) => s.SettingTheme,
        'themeColor': {
          #title: (S s) => s.SettingThemeColor,
          #option: <MaterialColor>[
            Colors.pink,
            Colors.red,
            Colors.orange,
            Colors.green,
            Colors.blue,
            Colors.purple,
          ],
        },
        'themeMode': {
          #title: (S s) => s.SettingThemeMode,
          #option: {
            ThemeMode.system: (S s) => s.SettingFollowSystem,
            ThemeMode.light: (S s) => s.SettingThemeModeLight,
            ThemeMode.dark: (S s) => s.SettingThemeModeDark
          }
        },
        'locale': (S s) => s.SettingLocale,
        'localeLanguage': {
          #title: (S s) => s.SettingLocaleLanguage,
          #option: {
            null: (S s) => s.SettingFollowSystem,
            Locale('zh'): '简体中文',
            Locale('en'): 'English',
          }
        },
      };

  AppSettings._() : super("settings");
  static AppSettings? _inst;
  factory AppSettings() => _inst ??= AppSettings._();
}
