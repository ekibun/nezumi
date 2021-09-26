import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_iconv/flutter_iconv.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:nezumi/common/global.dart';
import 'webview.dart';
import 'http.dart';
import 'wrapper.dart';

class Engine {
  static IsolateQjs? _engine;
  static Map<String, ClassWrapper> _classWrappers = {
    "html": HtmlParser(),
  };

  static Map<String, Object> _dataSource = {};

  static Future<String> Function(String) _moduleHandler = (module) async {
    if (module.startsWith("@source/")) {
      final data = await Global.fs.getObject("script/" +
          module.replaceAll(new RegExp(r"^@source/|.js$"), "") +
          ".js");
      return utf8.decode(data!);
    }
    var modulePath = module == "@init"
        ? "js/init.js"
        : "js/module/" + module.replaceFirst(new RegExp(r".js$"), "") + ".js";
    return rootBundle.loadString(modulePath);
  };

  static _methodHandler(String method, List args) {
    final classMethod = method.split('_');
    final wrapper = _classWrappers[classMethod[0]];
    if (wrapper != null) {
      if (classMethod.length < 2) return wrapper.constructor(args);
      return wrapper.methods[classMethod[1]]!(args[0], args.sublist(1));
    }
    switch (method) {
      case "encode":
        return convert(utf8.encode(args[0]), to: args[1], fatal: args[2]);
      case "decode":
        return utf8.decode(convert(args[0], from: args[1], fatal: args[2]),
            allowMalformed: args[2]);
      case "fetch":
        return Http.fetch(args[0]);
      case "console":
        print(args[1]);
        return;
      default:
        throw Exception("No such method");
    }
  }

  static _ensureEngine() async {
    if (_engine == null) {
      _engine = IsolateQjs(
        moduleHandler: _moduleHandler,
        stackSize: 1024 * 1024,
      );
      JSInvokable init = await _engine!
          .evaluate(await _moduleHandler("@init"), name: "<init>");
      await init.invoke([_methodHandler, IsolateFunction(webview)]);
      init.free();
    }
  }

  static reset() async {
    JSRef.freeRecursive(_dataSource);
    _dataSource.clear();
    if (_engine == null) return;
    final engine = _engine;
    _engine = null;
    try {
      await engine!.close();
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> _evaluate(String command, String name) async {
    await _ensureEngine();
    return await _engine!.evaluate(command, name: name);
  }

  static Future<Map> getSource(String name) async {
    if (_dataSource[name] == null) {
      _dataSource[name] =
          await _evaluate('import("@source/$name")', "<loadProvider>");
    }
    return _dataSource[name] as Map;
  }
}
