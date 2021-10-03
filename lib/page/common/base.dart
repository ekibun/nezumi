import 'package:flutter/material.dart';
import 'package:nezumi/generated/l10n.dart';
import 'package:nezumi/widget/actionbar.dart';

class BaseFragment extends StatelessWidget {
  final Widget? child;
  final List<Widget>? actions;
  final String Function(S)? title;

  const BaseFragment({
    Key? key,
    this.child,
    this.actions,
    this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          SafeArea(
            child: child ?? SizedBox(),
          ),
          GradientBackground(
            child: ActionBar(
              children: actions ??
                  [
                    Expanded(
                      child: Text(
                        title?.call(s) ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }
}
