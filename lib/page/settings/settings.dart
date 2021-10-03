import 'package:flutter/material.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/page/common/base.dart';
import 'package:nezumi/store/app.dart';
import 'package:nezumi/store/storage.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseFragment(
      title: (s) => s.Settings,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: EdgeInsets.only(top: 54),
          child: Material(
            clipBehavior: Clip.hardEdge,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Consumer<AppSettings>(
              builder: (context, settings, _) => ListView(
                clipBehavior: Clip.none,
                children: List<Widget>.from(
                  settings.settings.entries
                      .map((v) => _buildSettingsItem(context, v, settings)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, MapEntry<String, dynamic> item, Settings settings) {
    final s = S.of(context);
    if (item.value is! Map) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          item.value(s),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Theme.of(context).primaryColor),
        ),
      );
    }
    final option = item.value[#option];
    if (option != null) {
      return ListTile(
        title: Text(item.value[#title](s)),
        trailing: DropdownButton<dynamic>(
          value: settings[item.key],
          onChanged: (val) => settings[item.key] = val,
          underline: SizedBox(),
          items: List<DropdownMenuItem>.from(option is Map
              ? option.entries.map((v) => DropdownMenuItem(
                    value: v.key,
                    child: Text(v.value is String ? v.value : v.value(s)),
                  ))
              : List.of(option).map((v) {
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
                })),
        ),
      );
    }
    throw UnimplementedError();
  }
}
