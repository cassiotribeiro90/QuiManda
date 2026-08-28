import 'package:flutter/material.dart';

class OsmWebWidget extends StatelessWidget {
  const OsmWebWidget({
    super.key,
    required double latitude,
    required double longitude,
    double zoom = 15,
    String? title,
    Function(double, double)? onTap,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
