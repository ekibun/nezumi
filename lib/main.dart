import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nezumi/page/settings/settings.dart';
import 'package:nezumi/page/video/index.dart';
import 'package:nezumi/store/download.dart';
import 'package:nezumi/store/global.dart';
import 'package:nezumi/store/subject.dart';
import 'package:nezumi/store/app.dart';
import 'package:nezumi/page/home/index.dart';
import 'package:nezumi/page/search/index.dart';
import 'package:nezumi/page/subject/index.dart';
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
      providers: [
        ChangeNotifierProvider.value(value: AppSettings()),
        ChangeNotifierProvider.value(value: DownloadDB()),
        ChangeNotifierProvider.value(value: SubjectDB()),
      ],
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
          theme: AppSettings.getTheme(false),
          darkTheme: AppSettings.getTheme(true),
          themeMode: settings['themeMode'],
          locale: settings['localeLanguage'],
          routes: {
            'home': (BuildContext context) => HomePage(),
            'settings': (BuildContext context) => SettingsPage(),
            'video': (BuildContext context) => VideoPage(),
            'search': (BuildContext context) => SearchPage(),
            'subject': (BuildContext context) => SubjectPage(),
          },
          initialRoute: 'home',
        );
      }),
    );
  }
}
