import 'package:flutter/material.dart';

class CenterPage extends StatelessWidget {
  final Widget? child;

  const CenterPage({Key? key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: child,
          ),
        ],
      ),
    );
  }
}
