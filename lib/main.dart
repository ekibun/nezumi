import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nezumi/common/global.dart';
import 'package:nezumi/page/download/download.dart';
import 'package:nezumi/page/settings/app.dart';
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
      providers: [ChangeNotifierProvider.value(value: AppSettings())],
      child: Consumer<AppSettings>(builder: (context, settings, _) {
        final MaterialColor themeColor = settings['themeColor'];
        return MaterialApp(
          title: 'nezumi',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            S.delegate,
          ],
          debugShowCheckedModeBanner: false,
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: themeColor,
              canvasColor: Colors.grey[200],
              hintColor: themeColor,
              backgroundColor: Colors.transparent,
              splashColor: themeColor.withAlpha(50),
              primaryColorBrightness: Brightness.dark),
          darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: themeColor,
              canvasColor: Colors.grey[850],
              hintColor: themeColor,
              backgroundColor: Colors.transparent,
              splashColor: themeColor.withAlpha(50),
              primaryColorBrightness: Brightness.dark),
          themeMode: settings['themeMode'],
          locale: settings['localeLanguage'],
          home: Material(
              type: MaterialType.canvas,
              child: SafeArea(child: DownloadFragment())),
        );
      }),
    );
  }
}
