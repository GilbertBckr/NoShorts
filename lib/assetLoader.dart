import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAsset(String fileName) async {
  return await rootBundle.loadString('assets/$fileName');
}

//Future<String> loadJs() async {
//return await loadAsset("js.js");
//}

Future<String> loadCss() async {
  return await loadAsset("style.css");
}
