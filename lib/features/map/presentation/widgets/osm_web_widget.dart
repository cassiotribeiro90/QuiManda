
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web_pkg;

import '../../../../app/core/webview/osm_html_builder.dart';

class OsmWebWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? title;
  final Function(double, double)? onTap;

  const OsmWebWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.title,
    this.onTap,
  });

  @override
  State<OsmWebWidget> createState() => _OsmWebWidgetState();
}

class _OsmWebWidgetState extends State<OsmWebWidget> {
  late String _viewId;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'osm-map-${widget.latitude}-${widget.longitude}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
    
    // Escutar mensagens do iframe
    web_pkg.window.onMessage.listen((event) {
      // final data = event.data;
    });
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = web_pkg.HTMLIFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      
      // 🔥 Usando setAttribute para evitar erro de tipo JSAny/String
      iframe.setAttribute('srcdoc', OsmHtmlBuilder.build(
        initialLat: widget.latitude,
        initialLng: widget.longitude,
        initialZoom: widget.zoom,
        markerTitle: widget.title,
      ));

      iframe.onLoad.listen((_) {
        if (mounted) setState(() => _isReady = true);
      });
        
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: _viewId),
        if (!_isReady)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
