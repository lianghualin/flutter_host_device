import 'package:flutter/material.dart';

import '../models/host_device_theme.dart';
import '../painters/host_icon_painter.dart';

/// A compact host device icon for use in topology views and device lists.
///
/// Renders a miniaturized desktop: monitor + neck + base.
/// Width is set by [size]; height is derived from a 1:1.2 aspect ratio
/// (height = size * 1.2).
///
/// If [theme] is omitted, the widget auto-detects from the ambient
/// [Theme.brightness].
class HostIconWidget extends StatelessWidget {
  const HostIconWidget({
    super.key,
    required this.size,
    this.elevation = 5,
    this.theme,
  });

  /// Icon width (monitor width) in logical pixels. Height = size * 1.2.
  final double size;

  /// Material elevation for the PhysicalShape shadow.
  final double elevation;

  /// Color theme. If null, auto-detected from [Theme.of(context).brightness].
  final HostDeviceTheme? theme;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? const HostDeviceTheme.dark()
            : const HostDeviceTheme.light());

    final height = size * HostIconPainter.heightRatio;

    return SizedBox(
      width: size,
      height: height,
      child: PhysicalShape(
        clipper: _HostIconClipper(),
        color: resolvedTheme.bodyGradientEnd,
        elevation: elevation,
        shadowColor:
            Colors.black.withValues(alpha: resolvedTheme.shadowOpacity),
        child: CustomPaint(
          painter: HostIconPainter(theme: resolvedTheme),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _HostIconClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final monitorH = h * 0.75;
    final neckH = h * 0.08;
    final baseH = h * 0.12;
    final neckW = w * 0.15;
    final baseW = w * 0.45;
    final cornerR = w * 0.08;

    final path = Path();

    // Monitor
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, monitorH),
      Radius.circular(cornerR),
    ));

    // Neck
    final neckLeft = (w - neckW) / 2;
    path.addRect(Rect.fromLTRB(
      neckLeft,
      monitorH,
      neckLeft + neckW,
      monitorH + neckH,
    ));

    // Base
    final baseLeft = (w - baseW) / 2;
    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(baseLeft, monitorH + neckH, baseW, baseH),
      topLeft: const Radius.circular(1.5),
      topRight: const Radius.circular(1.5),
      bottomLeft: const Radius.circular(3.0),
      bottomRight: const Radius.circular(3.0),
    ));

    return path;
  }

  @override
  bool shouldReclip(_HostIconClipper old) => false;
}
