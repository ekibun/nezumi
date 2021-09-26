import 'package:flutter/material.dart';
import 'package:nezumi/widget/ripple.dart';

class ActionButton extends StatelessWidget {
  final void Function()? onTap;
  final IconData? icon;

  const ActionButton({
    Key? key,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 8, 12, 8),
      child: Ripple(
        onTap: onTap,
        child: Container(
            height: 42,
            child: Icon(
              icon,
              size: 21,
              color: Theme.of(context).disabledColor,
            )),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget? child;

  const GradientBackground({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).canvasColor,
              Theme.of(context).canvasColor.withAlpha(230),
              Theme.of(context).canvasColor.withAlpha(200),
              Theme.of(context).canvasColor.withAlpha(80),
              Theme.of(context).canvasColor.withAlpha(0),
            ]),
      ),
      child: child,
    );
  }
}

class ActionBar extends StatelessWidget {
  final List<Widget>? children;
  final Widget? child;
  final bool showGoBack;

  const ActionBar({
    Key? key,
    this.children,
    this.showGoBack = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              showGoBack && Navigator.of(context).canPop()
                  ? ActionButton(
                      icon: Icons.arrow_back,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  : Container(),
              ...(children ?? []),
            ]),
            child ?? SizedBox(),
          ]),
        ),
      ),
    );
  }
}
