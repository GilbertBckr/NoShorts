import 'dart:async';
import "dart:developer";

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_but_it_sucks/assetLoader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoShorts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NoShorts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            blckShorts();
          },
          onWebResourceError: (WebResourceError error) {},
          onUrlChange: (change) {
            if (isAShortsUrl(change.url ?? "")) {
              controller.goBack();
            }
          },
          onNavigationRequest: (request) {
            if (isAShortsUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://m.youtube.com'));
    super.initState();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      blckShorts();
    });
  }

  isAShortsUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.contains('shorts');
    } catch (e) {
      return false;
    }
  }

  late final WebViewController controller;

  blckShorts() async {
    log("running block shorts");

    final css = await loadCss();

    String insertStyleTag = """
         styleElement = document.getElementById('injected-style');

         if (!styleElement) {
            styleElement = document.createElement('style');
            styleElement.type = 'text/css';
            styleElement.id = 'injected-style';
            document.head.appendChild(styleElement);
          }

          styleElement.textContent = `${css}`;""";
    log(insertStyleTag);

    final result = controller.runJavaScript(insertStyleTag);
    result.catchError((e) {
      log("was an error" + e.toString());
    });
    result.then((value) {
      log("was a success");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: WebViewWidget(
          controller: controller,
        ),
      )),
    );
  }
}
