import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Ripple extends StatelessWidget {
  final bool borderless;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;

  Ripple({
    Key? key,
    this.child,
    this.borderRadius,
    this.onTap,
    this.borderless = true,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: InkResponse(
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
        onTap: onTap,
        containedInkWell: !borderless,
        borderRadius: borderRadius,
        highlightShape: borderless ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
