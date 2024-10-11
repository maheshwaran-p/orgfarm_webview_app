import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'loading_state.dart'; // Import the LoadingState provider

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => LoadingState(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebViewExample(),
        ),
      ),
    );

class WebViewExample extends StatelessWidget {
  const WebViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingState = Provider.of<LoadingState>(context);

    return Scaffold(
      body: Stack(
        children: [
          _WebViewWidget(loadingState: loadingState),
          if (loadingState.isLoading)
            const Center(
              child: CupertinoActivityIndicator(radius: 10), // Cupertino loading indicator
            ),
        ],
      ),
    );
  }
}

class _WebViewWidget extends StatefulWidget {
  final LoadingState loadingState;

  const _WebViewWidget({Key? key, required this.loadingState}) : super(key: key);

  @override
  State<_WebViewWidget> createState() => __WebViewWidgetState();
}

class __WebViewWidgetState extends State<_WebViewWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            widget.loadingState.startLoading(); // Start loading in provider
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            widget.loadingState.stopLoading(); // Stop loading in provider
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Page resource error: ${error.description}');
            widget.loadingState.stopLoading(); // Stop loading in provider
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigating to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent('orgfarm-mobile-app') // Set the custom user-agent
      ..loadRequest(Uri.parse('https://orgfarm.store'));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
