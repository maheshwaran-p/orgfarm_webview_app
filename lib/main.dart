import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orgfarm/firebase_options.dart';
import 'package:orgfarm/services/constant.dart';
import 'package:orgfarm/services/remote_config_service.dart';
import 'package:orgfarm/utils_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'loading_state.dart'; 

void showUpdateAlert(BuildContext context) {

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Update Available'),
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('A new version of the app is available. Please update to the latest version.'),
          ),
          actions: <Widget>[
            
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Update'),
              onPressed: () {
              if(Platform.isAndroid){
              Utils.openLink(url: 'https://play.google.com/store/apps/details?id=com.orgfarm.customer');
                FirebaseAnalytics.instance.logEvent(
                  name: 'update_popup_shown_in_android',
                  parameters: {'status': 'success'},
                );

              }else{
                Utils.openLink(url: 'https://apps.apple.com/us/app/orgfarm/id1515008376?platform=iphone');
                FirebaseAnalytics.instance.logEvent(
                  name: 'update_popup_shown_in_ios',
                  parameters: {'status': 'success'},
                );
              }   
              },
            ),
          ],
        );
      },
    );
  
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // (Platform.isAndroid)?
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //:await Firebase.initializeApp();

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(Constants.isRelease);

  runApp(
    ChangeNotifierProvider(
      create: (context) => LoadingState(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WebViewExample(),
      ),
    ),
  );
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({Key? key}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates(); // Check for updates when the widget initializes
  }

  Future<void> _checkForUpdates() async {
    final remoteConfig = RemoteConfigService();
    await remoteConfig.setup();
    final info = await PackageInfo.fromPlatform();

    final localVersion = int.parse(info.version.replaceAll('.', ''));
  
    final remoteVersion = Platform.isAndroid? int.parse(remoteConfig.newAndriodAppVersion.replaceAll('.', '')):int.parse(remoteConfig.newIosAppVersion.replaceAll('.', ''));
    debugPrint('localVersion::::$localVersion');
    debugPrint('remoteVersion:::::$remoteVersion' );



    if (localVersion < remoteVersion) {
      // Show update alert based on the platform
      showUpdateAlert(context);
    }
  }

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

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

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
