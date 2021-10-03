import 'package:flutter/material.dart';
import 'package:nezumi/widget/ripple.dart';

class TabItem extends StatelessWidget {
  final void Function()? onTap;
  final IconData icon;
  final String title;
  final bool isSelected;
  final Orientation orientation;

  const TabItem(
    this.icon,
    this.title, {
    Key? key,
    this.onTap,
    this.isSelected = false,
    this.orientation = Orientation.portrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isLandscape = this.orientation == Orientation.landscape;
    var childern = <Widget>[
      Icon(
        icon,
        size: isLandscape ? 20 : 18,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      SizedBox(width: 12, height: 4),
      Text(
        title,
        style: TextStyle(
          fontSize: isLandscape ? 15 : 12,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ];
    final ret = Ripple(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(8),
      borderless: !isLandscape,
      backgroundColor: isSelected && isLandscape
          ? Theme.of(context).primaryColor.withAlpha(40)
          : null,
      child: isLandscape
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: childern,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: childern,
            ),
    );
    return isLandscape
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: ret,
          )
        : ret;
  }
}
