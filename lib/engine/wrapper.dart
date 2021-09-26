import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

typedef WrapperMethodCall<T> = dynamic Function(T obj, List args);

abstract class ClassWrapper<T> {
  dynamic constructor(List args);
  abstract Map<String, WrapperMethodCall<T>> _methods;
  Map<String, WrapperMethodCall>? _methodsWrap;
  Map<String, WrapperMethodCall> get methods {
    if (_methodsWrap == null)
      _methodsWrap = _methods
          .map((key, value) => MapEntry(key, (obj, args) => value(obj, args)));
    return _methodsWrap!;
  }
}

class HtmlParser extends ClassWrapper<dom.Element> {
  @override
  constructor(List args) => parser.parse(args[0]).documentElement;

  @override
  Map<String, WrapperMethodCall<dom.Element>> _methods = {
    "query": (el, args) => el.querySelector(args[0]),
    "queryAll": (el, args) => el.querySelectorAll(args[0]),
    "attr": (el, args) {
      if (args.length > 1) return el.attributes[args[0]] = args[1];
      return el.attributes[args[0]];
    },
    "text": (el, args) {
      if (args.length > 1) return el.text = args[1];
      return el.text;
    },
    "html": (el, args) {
      if (args.length > 1) return el.innerHtml = args[1];
      return el.innerHtml;
    },
    "outerHtml": (el, args) => el.outerHtml,
    "remove": (el, args) => el.remove(),
  };
}
