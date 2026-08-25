import 'package:flutter/material.dart';
import '../../routes/app_router.dart';

class NavigationService {
  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  static BuildContext? get context => navigatorKey.currentContext;
}
