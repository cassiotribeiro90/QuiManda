import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'osm_mobile_widget.dart';
import 'osm_windows_widget.dart';
import 'osm_web_stub.dart' if (dart.library.js_interop) 'osm_web_widget.dart';

class OpenStreetMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? title;
  final Function(double, double)? onTap;

  const OpenStreetMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Web
    if (kIsWeb) {
      return OsmWebWidget(
        latitude: latitude,
        longitude: longitude,
        zoom: zoom,
        title: title,
        onTap: onTap,
      );
    }

    // 🔥 Windows
    if (Platform.isWindows) {
      return OsmWindowsWidget(
        latitude: latitude,
        longitude: longitude,
        zoom: zoom,
        title: title,
        onTap: onTap,
      );
    }

    // 🔥 Mobile (Android/iOS)
    return OsmMobileWidget(
      latitude: latitude,
      longitude: longitude,
      zoom: zoom,
      title: title,
      onTap: onTap,
    );
  }
}
