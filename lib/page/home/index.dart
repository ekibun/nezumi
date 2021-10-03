import 'package:flutter/material.dart';
import 'package:nezumi/page/common/base.dart';
import 'package:nezumi/page/common/subjectList.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/store/subject.dart';
import 'package:nezumi/widget/actionbar.dart';
import 'package:nezumi/widget/ripple.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BaseFragment(
      child: Consumer<SubjectDB>(
        builder: (context, list, _) {
          if (list.data.isEmpty) return Container();
          return SubjectList(
            list.data.values.cast<Subject>(),
            padding: EdgeInsets.fromLTRB(16, 54, 16, 16),
            showCollection: false,
            onTapItem: (subject) {
              Navigator.of(context).pushNamed("subject", arguments: subject);
            },
          );
        },
      ),
      actions: [
        Expanded(
          child: Container(
            child: Text(
              s.Collections,
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        ActionButton(
          icon: Icons.search,
          onTap: () {
            Navigator.of(context).pushNamed("search");
          },
        ),
        ActionButton(
          icon: Icons.settings,
          onTap: () {
            Navigator.of(context).pushNamed("settings");
          },
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 14),
          child: Ripple(
            onTap: () {},
            borderless: false,
            borderRadius: BorderRadius.circular(1000),
            backgroundColor: Colors.black12,
            child: Container(
                padding: EdgeInsets.fromLTRB(12, 4, 8, 4),
                child: Row(
                  children: [
                    Text(s.Sort),
                    SizedBox(width: 8),
                    Icon(
                      Icons.sort,
                      size: 21,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .color!
                          .withOpacity(0.5),
                    ),
                  ],
                )),
          ),
        )
      ],
    );
  }
}
