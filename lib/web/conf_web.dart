import 'dart:html';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void webConfigure() {
  debugPrint('configure web');
  js.context.callMethod('endLoading');
  setUrlStrategy(null);
  document.onContextMenu.listen((event) => event.preventDefault());
}
