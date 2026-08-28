import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/core/webview/osm_html_builder.dart';

class OsmMobileWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? title;
  final Function(double, double)? onTap;

  const OsmMobileWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.title,
    this.onTap,
  });

  @override
  State<OsmMobileWidget> createState() => _OsmMobileWidgetState();
}

class _OsmMobileWidgetState extends State<OsmMobileWidget> {
  late final WebViewController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          final data = jsonDecode(message.message);
          if (data['type'] == 'ready') {
            setState(() => _isReady = true);
          } else if (data['type'] == 'tap' && widget.onTap != null) {
            widget.onTap!(data['lat'], data['lng']);
          }
        },
      )
      ..loadHtmlString(OsmHtmlBuilder.build(
        initialLat: widget.latitude,
        initialLng: widget.longitude,
        initialZoom: widget.zoom,
        markerTitle: widget.title,
      ));
  }

  @override
  void didUpdateWidget(OsmMobileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude || oldWidget.zoom != widget.zoom) {
      _controller.runJavaScript('window.setLocation(${widget.latitude}, ${widget.longitude}, ${widget.zoom})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (!_isReady)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
