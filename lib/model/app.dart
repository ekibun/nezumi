import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nezumi/common/global.dart';
import 'package:nezumi/generated/l10n.dart';

class AppModel with ChangeNotifier {
  static const themeColors = <MaterialColor>[
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  static const PREF_THEME_COLOR = 'themeColor';
  static const PREF_DARK_MODE = 'darkMode';
  static const PREF_LOCALE = 'locale';

  static ThemeData themeData(Brightness brightness) {
    return ThemeData(
        brightness: brightness,
        primaryColor: _themeColor,
        accentColor: _themeColor,
        canvasColor: brightness == Brightness.light
            ? Colors.grey[200]
            : Colors.grey[850],
        hintColor: _themeColor,
        backgroundColor: Colors.transparent,
        splashColor: _themeColor.withAlpha(50),
        primaryColorBrightness: Brightness.dark);
  }

  final entries = [];
  AppModel() {
    entries.addAll([
      {
        #title: (S s) => s.SettingTheme,
        #items: [
          {
            #title: (S s) => s.SettingThemeColor,
            #getter: () => themeColor,
            #setter: (val) => themeColor = val,
            #options: themeColors,
          },
          {
            #title: (S s) => s.SettingThemeMode,
            #getter: () => darkMode,
            #setter: (val) => darkMode = val,
            #options: {
              ThemeMode.system: (S s) => s.SettingFollowSystem,
              ThemeMode.light: (S s) => s.SettingThemeModeLight,
              ThemeMode.dark: (S s) => s.SettingThemeModeDark
            }
          }
        ]
      },
      {
        #title: (S s) => s.SettingLocale,
        #items: [
          {
            #title: (S s) => s.SettingLocaleLanguage,
            #getter: () => locale,
            #setter: (val) => locale = val,
            #options: {
              null: (S s) => s.SettingFollowSystem,
              ...Map.fromIterable(S.delegate.supportedLocales,
                  key: (v) => v,
                  value: (v) => (S s) => {
                        'zh': '简体中文',
                        'en': 'English',
                      }[v.toString()])
            },
          },
        ],
      }
    ]);
  }

  static MaterialColor get _themeColor {
    final _theme = Global.sp.getInt(PREF_THEME_COLOR);
    return themeColors.firstWhere(
      (e) => e.value == _theme,
      orElse: () => themeColors.first,
    );
  }

  MaterialColor get themeColor => _themeColor;

  set themeColor(MaterialColor val) {
    Global.sp.setInt(PREF_THEME_COLOR, val.value);
    notifyListeners();
  }

  ThemeMode get darkMode {
    switch (Global.sp.getInt(PREF_DARK_MODE)) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  set darkMode(ThemeMode val) {
    switch (val) {
      case ThemeMode.light:
        Global.sp.setInt(PREF_DARK_MODE, 0);
        break;
      case ThemeMode.dark:
        Global.sp.setInt(PREF_DARK_MODE, 1);
        break;
      default:
        Global.sp.setInt(PREF_DARK_MODE, -1);
        break;
    }
    notifyListeners();
  }

  Locale? get locale {
    final _locale = Global.sp.getString(PREF_LOCALE);
    if (_locale != null) {
      final ret = Locale(_locale);
      if (S.delegate.isSupported(ret)) return ret;
    }
    return null;
  }

  set locale(Locale? val) {
    if (val == null) {
      Global.sp.remove(PREF_LOCALE);
    } else {
      Global.sp.setString(PREF_LOCALE, val.toString());
    }
    S.load(val ?? Locale(Platform.localeName));
    notifyListeners();
  }
}
