import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/model/app.dart';
import 'package:provider/provider.dart';

// final _settings = [
//   (BuildContext context) => Padding(
//         padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//         child: Text(
//           S.of(context).SettingTheme,
//           style: Theme.of(context)
//               .textTheme
//               .bodyText1!
//               .copyWith(color: Theme.of(context).accentColor),
//         ),
//       ),
//   (BuildContext context) => ListTile(
//         title: Text(S.of(context).SettingThemeColor),
//         trailing: Consumer<AppModel>(
//           builder: (context, appInfo, _) => DropdownButton<MaterialColor>(
//             value: appInfo.themeColor,
//             onChanged: (MaterialColor? val) {
//               if (val != null) appInfo.themeColor = val;
//             },
//             underline: SizedBox(),
//             items: AppModel.themeColors
//                 .map(
//                   (c) => DropdownMenuItem<MaterialColor>(
//                     value: c,
//                     child: Container(
//                       padding: EdgeInsets.all(20),
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(28),
//                         color: c,
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ),
//   (BuildContext context) => ListTile(
//         title: Text(S.of(context).SettingThemeDark),
//         trailing: Consumer<AppModel>(
//           builder: (context, appInfo, _) => DropdownButton<ThemeMode>(
//             value: appInfo.darkMode,
//             onChanged: (ThemeMode? val) {
//               if (val != null) appInfo.darkMode = val;
//             },
//             underline: SizedBox(),
//             items: ['跟随系统', '总是关闭', '总是启用'].map(
//               (c) {
//                 return DropdownMenuItem<ThemeMode>(
//                   value: {
//                     '跟随系统': ThemeMode.system,
//                     '总是关闭': ThemeMode.light,
//                     '总是启用': ThemeMode.dark
//                   }[c],
//                   child: Text(c),
//                 );
//               },
//             ).toList(),
//           ),
//         ),
//       ),
// ];

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Consumer<AppModel>(
              builder: (context, appInfo, _) => ListView(
                children: appInfo.entries
                    .map((v) => _buildSettingsItem(context, v))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, Map item) {
    final s = S.of(context);
    if (item.containsKey(#items)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            item[#title](s),
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Theme.of(context).accentColor),
          ),
        ),
        ...item[#items].map((v) => _buildSettingsItem(context, v))
      ]);
    } else if (item.containsKey(#options)) {
      final items = item[#options];
      return ListTile(
        title: Text(item[#title](s)),
        trailing: DropdownButton(
            value: item[#getter](),
            onChanged: item[#setter],
            underline: SizedBox(),
            items: (items is Map
                    ? items.entries.map((v) => DropdownMenuItem(
                          value: v.key,
                          child: Text(v.value(s)),
                        ))
                    : List.of(items).map((v) {
                        if (v is MaterialColor) {
                          return DropdownMenuItem(
                            value: v,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: v,
                              ),
                            ),
                          );
                        }
                        throw StateError('bad setting options');
                      }))
                .toList()),
      );
    }
    throw StateError('bad setting');
  }
}
