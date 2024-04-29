import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void webConfigure() {
  debugPrint('configure web');
  setUrlStrategy(null);
  document.onContextMenu.listen((event) => event.preventDefault());
}
