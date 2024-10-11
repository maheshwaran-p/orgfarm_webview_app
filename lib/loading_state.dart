import 'dart:async';

import 'package:flutter/foundation.dart';

class LoadingState extends ChangeNotifier {
  bool _isLoading = false;
  Timer? _loadingTimer;

  bool get isLoading => _isLoading;

  void startLoading() {
    _isLoading = true;
    notifyListeners();
    _startLoadingTimer();
  }

  void stopLoading() {
    _isLoading = false;
    _loadingTimer?.cancel();
    notifyListeners();
  }

  void _startLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      stopLoading(); // Stop loading after 2 minutes
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
}
