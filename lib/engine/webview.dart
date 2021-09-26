/*
 * @Description: 
 * @Author: ekibun
 * @Date: 2020-08-28 10:50:36
 * @LastEditors: ekibun
 * @LastEditTime: 2020-08-28 10:51:26
 */
import 'dart:async';

import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:flutter_webview/flutter_webview.dart';

Future<dynamic> webview(String url, Map options) async {
  Completer c = new Completer();
  var webview = FlutterWebview();
  JSRef.dupRecursive(options);
  await webview.setMethodHandler((String method, dynamic args) async {
    if (method == "onNavigationCompleted") {
      await Future.delayed(Duration(seconds: 10));
      if (!c.isCompleted)
        c.completeError(
            "Webview Call timeout 10 seconds after page completed.");
    }
    JSInvokable? callback = options[method];
    if (callback != null) if ((await callback.invoke([args])) == true) {
      if (!c.isCompleted) c.complete(args);
    }
    return;
  });
  if (options["ua"] != null) await webview.setUserAgent(options["ua"]);
  await webview.navigate(url);
  Future.delayed(Duration(seconds: 100)).then((value) {
    if (!c.isCompleted) c.completeError("Webview Call timeout 100 seconds.");
  });
  try {
    return await c.future;
  } finally {
    JSRef.freeRecursive(options);
    await webview.destroy();
  }
}
