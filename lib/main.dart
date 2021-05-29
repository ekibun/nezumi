import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nezumi/common/global.dart';
import 'package:nezumi/model/app.dart';
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
        builder: (context, appInfo, _) {
          return MaterialApp(
            title: 'nezumi',
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              S.delegate,
            ],
            debugShowCheckedModeBanner: false,
            supportedLocales: S.delegate.supportedLocales,
            theme: AppModel.themeData(Brightness.light),
            darkTheme: AppModel.themeData(Brightness.dark),
            themeMode: appInfo.darkMode,
            locale: appInfo.locale,
            home: SettingsPage(),
          );
        },
      ),
    );
  }
}
