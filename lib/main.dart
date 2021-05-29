import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nezumi/common/global.dart';
import 'package:nezumi/model/app.dart';
import 'package:nezumi/page/common/center.dart';
import 'package:nezumi/page/settings/settings_page.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

void main() async {
  await Global.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AppModel())],
      child: Consumer<AppModel>(
        builder: (context, appModel, _) {
          final themeColor = appModel[#themeColor];
          final theme = ThemeData(
              brightness: Brightness.light,
              primaryColor: themeColor,
              accentColor: themeColor,
              canvasColor: Colors.grey[200],
              hintColor: themeColor,
              backgroundColor: Colors.transparent,
              splashColor: themeColor.withAlpha(50),
              primaryColorBrightness: Brightness.dark);
          return MaterialApp(
            title: 'nezumi',
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              S.delegate,
            ],
            debugShowCheckedModeBanner: false,
            supportedLocales: S.delegate.supportedLocales,
            theme: theme,
            darkTheme: theme.copyWith(
              brightness: Brightness.dark,
              canvasColor: Colors.grey[850],
            ),
            themeMode: appModel[#themeMode],
            locale: appModel[#localeLanguage],
            home: CenterPage(
              child: SettingsPage(),
            ),
          );
        },
      ),
    );
  }
}
