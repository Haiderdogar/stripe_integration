import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webviewscreen extends StatefulWidget {
  const Webviewscreen({super.key});

  @override
  State<Webviewscreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<Webviewscreen> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.disabled)
    ..loadRequest(Uri.parse('https://google.com'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Example'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
