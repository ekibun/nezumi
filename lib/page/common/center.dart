import 'package:flutter/material.dart';
import 'package:nezumi/widget/actionbar.dart';

class CenterPage extends StatelessWidget {
  final Widget? child;
  final List<Widget>? actions;
  final String? title;

  const CenterPage({
    Key? key,
    this.child,
    this.actions,
    this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
          GradientBackground(
            child: ActionBar(
              children: actions ??
                  [
                    Expanded(
                      child: Text(
                        title ?? '',
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
