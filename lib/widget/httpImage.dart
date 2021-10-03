import 'package:flutter/cupertino.dart';

class HttpImage extends StatelessWidget {
  final Map req;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  const HttpImage(
    this.req, {
    Key? key,
    this.borderRadius,
    this.width,
    this.height,
  }) : super(key: key);

  static ImageProvider getImage(Map req) {
    return NetworkImage(req["url"]?.toString() ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: getImage(req),
          fit: BoxFit.cover,
        ),
        borderRadius: borderRadius,
      ),
    );
  }
}
