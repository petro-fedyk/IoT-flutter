import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _hasInternet = true;

  ConnectivityController({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get hasInternet => _hasInternet;

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _hasInternet = _isConnected(results);
    notifyListeners();

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final next = _isConnected(results);
      if (next != _hasInternet) {
        _hasInternet = next;
        notifyListeners();
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
