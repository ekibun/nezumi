import 'package:flutter/material.dart';
import 'package:nezumi/store/subject.dart';
import 'package:nezumi/engine/http.dart';
import 'package:nezumi/widget/httpImage.dart';
import 'package:nezumi/widget/ripple.dart';

class SubjectList extends StatelessWidget {
  final Iterable<Subject> items;
  final EdgeInsets? padding;
  final void Function(Subject)? onTapItem;
  final bool showCollection;

  const SubjectList(
    this.items, {
    Key? key,
    this.padding,
    this.onTapItem,
    this.showCollection = true,
  }) : super(key: key);

  Widget _buildItem(BuildContext context, int index) {
    final Subject data = items.elementAt(index);
    return Ripple(
      padding: EdgeInsets.all(12),
      borderless: false,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Theme.of(context).cardColor,
      onTap: () {
        onTapItem?.call(data);
      },
      child: Row(
        children: [
          HttpImage(
            Http.wrapReq(data.image ?? {}),
            borderRadius: BorderRadius.circular(6),
            width: 100,
            height: 100,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      data.name ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ]),
                SizedBox(height: 8),
                Text(
                  data.summary ?? "",
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      clipBehavior: Clip.none,
      padding: padding,
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisExtent: 124,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: _buildItem,
      itemCount: items.length,
    );
  }
}
