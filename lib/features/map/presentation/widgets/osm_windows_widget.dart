import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart' as win;
import '../../../../app/core/webview/osm_html_builder.dart';

class OsmWindowsWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? title;
  final Function(double, double)? onTap;

  const OsmWindowsWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.title,
    this.onTap,
  });

  @override
  State<OsmWindowsWidget> createState() => _OsmWindowsWidgetState();
}

class _OsmWindowsWidgetState extends State<OsmWindowsWidget> {
  final win.WebviewController _controller = win.WebviewController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initWindows();
  }

  Future<void> _initWindows() async {
    try {
      await _controller.initialize();
      
      final html = OsmHtmlBuilder.build(
        initialLat: widget.latitude,
        initialLng: widget.longitude,
        initialZoom: widget.zoom,
        markerTitle: widget.title,
      );

      // 🔥 Em webview_windows 0.4.0 usamos Data URI com Base64
      final String contentBase64 = base64Encode(utf8.encode(html));
      final String dataUrl = 'data:text/html;base64,$contentBase64';
      
      await _controller.loadUrl(dataUrl);

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Erro no WebView Windows: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return win.Webview(_controller);
  }
}
