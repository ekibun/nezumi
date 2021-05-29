import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/model/app.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, _) => ListView(
        children: List<Widget>.from(
          appModel.values.map((v) => _buildSettingsItem(context, v)),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, AppSetting item) {
    final s = S.of(context);
    if (item is AppOptionSetting) {
      return ListTile(
        title: Text(item.title(s)),
        trailing: DropdownButton<dynamic>(
          value: item.value,
          onChanged: (val) => item.value = val,
          underline: SizedBox(),
          items: List<DropdownMenuItem>.from(item.options is Map
              ? item.options.entries.map((v) => DropdownMenuItem(
                    value: v.key,
                    child: Text(v.value(s)),
                  ))
              : List.of(item.options).map((v) {
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
                })),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        item.title(s),
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: Theme.of(context).accentColor),
      ),
    );
  }
}
