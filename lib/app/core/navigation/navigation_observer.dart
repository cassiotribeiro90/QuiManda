import 'package:flutter/material.dart';

class NavigationObserver extends NavigatorObserver {
  static bool _isNavigating = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _isNavigating = false;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _isNavigating = false;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _isNavigating = false;
  }

  static bool get isNavigating => _isNavigating;
  static void setNavigating(bool value) => _isNavigating = value;
}
