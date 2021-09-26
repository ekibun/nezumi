//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_iconv/flutter_iconv_plugin.h>
#include <flutter_qjs/flutter_qjs_plugin.h>
#include <flutter_webview/flutter_webview_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterIconvPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterIconvPlugin"));
  FlutterQjsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterQjsPlugin"));
  FlutterWebviewPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebviewPlugin"));
}
