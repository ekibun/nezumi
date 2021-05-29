import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nezumi/common/global.dart';
import 'package:nezumi/generated/l10n.dart';

class AppModel with ChangeNotifier {
  static const _themeColors = <MaterialColor>[
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

  final _settings = <Symbol, AppSetting>{};
  dynamic operator [](Symbol id) => _settings[id]!.value;
  get values => _settings.values;

  AppModel() {
    _settings.addAll({
      #theme: AppSetting((s) => s.SettingTheme),
      #themeColor: AppOptionSetting<MaterialColor>(
        (s) => s.SettingThemeColor,
        () {
          final _theme = Global.sp.getInt(PREF_THEME_COLOR);
          return _themeColors.firstWhere(
            (e) => e.value == _theme,
            orElse: () => _themeColors.first,
          );
        },
        (val) {
          Global.sp.setInt(PREF_THEME_COLOR, val.value);
          notifyListeners();
        },
        _themeColors,
      ),
      #themeMode: AppOptionSetting<ThemeMode>(
        (s) => s.SettingThemeMode,
        () {
          switch (Global.sp.getInt(PREF_DARK_MODE)) {
            case 0:
              return ThemeMode.light;
            case 1:
              return ThemeMode.dark;
            default:
              return ThemeMode.system;
          }
        },
        (val) {
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
        },
        {
          ThemeMode.system: (S s) => s.SettingFollowSystem,
          ThemeMode.light: (S s) => s.SettingThemeModeLight,
          ThemeMode.dark: (S s) => s.SettingThemeModeDark
        },
      ),
      #locale: AppSetting((s) => s.SettingLocale),
      #localeLanguage: AppOptionSetting<Locale?>(
        (s) => s.SettingLocaleLanguage,
        () {
          final _locale = Global.sp.getString(PREF_LOCALE);
          if (_locale != null) {
            final ret = Locale(_locale);
            if (S.delegate.isSupported(ret)) return ret;
          }
          return null;
        },
        (val) {
          if (val == null) {
            Global.sp.remove(PREF_LOCALE);
          } else {
            Global.sp.setString(PREF_LOCALE, val.toString());
          }
          S.load(val ?? Locale(Platform.localeName));
          notifyListeners();
        },
        {
          null: (S s) => s.SettingFollowSystem,
          ...Map.fromIterable(S.delegate.supportedLocales,
              key: (v) => v,
              value: (v) => (S s) => {
                    'zh': '简体中文',
                    'en': 'English',
                  }[v.toString()])
        },
      )
    });
  }
}

class AppSetting<T> {
  final String Function(S) title;
  final T Function()? _getter;
  final void Function(T)? _setter;
  AppSetting(
    this.title, {
    T Function()? getter,
    void Function(T)? setter,
  })  : _getter = getter,
        _setter = setter;
  get value => _getter!();
  set value(val) => _setter!(val);
}

class AppOptionSetting<T> extends AppSetting<T> {
  final options;
  AppOptionSetting(
    String Function(S) title,
    T Function() getter,
    void Function(T) setter,
    this.options,
  ) : super(title, getter: getter, setter: setter);
}
