import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/host_device_theme.dart';

/// Draws a host device chassis: monitor + neck + base.
///
/// Visual structure (top to bottom):
/// - Monitor: gradient body with screen area, bottom bezel with LEDs
/// - Neck: narrow rectangle connecting monitor to base
/// - Base: wider rounded rectangle stand
///
/// All colors are sourced from [theme].
class HostBodyPainter extends CustomPainter {
  HostBodyPainter({required this.theme});

  final HostDeviceTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Proportions: monitor ~75%, neck ~8%, base ~12%, gap ~5%
    final monitorH = h * 0.75;
    final neckH = h * 0.08;
    final baseH = h * 0.12;
    final monitorBottom = monitorH;
    final neckTop = monitorBottom;
    final neckBottom = neckTop + neckH;
    final baseTop = neckBottom;

    _drawMonitor(canvas, w, monitorH);
    _drawNeck(canvas, w, neckTop, neckBottom);
    _drawBase(canvas, w, baseTop, baseH);
  }

  void _drawMonitor(Canvas canvas, double w, double monitorH) {
    final cornerR = 8.0;
    final monitorRect = Rect.fromLTWH(0, 0, w, monitorH);

    // Monitor body gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientStart, theme.bodyGradientEnd],
      ).createShader(monitorRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(monitorRect, Radius.circular(cornerR)),
      gradientPaint,
    );

    // Screen area (inset from monitor edges, leaving room for bezel)
    final bezelSide = w * 0.08;
    final bezelTop = monitorH * 0.08;
    final bezelBottom = monitorH * 0.22; // thicker bottom bezel for LEDs
    final screenRect = Rect.fromLTRB(
      bezelSide,
      bezelTop,
      w - bezelSide,
      monitorH - bezelBottom,
    );
    final screenCornerR = 4.0;

    // Screen border
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(screenCornerR)),
      Paint()
        ..color = theme.screenBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Screen gradient fill
    final screenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.screenGradientStart, theme.screenGradientEnd],
      ).createShader(screenRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        screenRect.deflate(0.5),
        Radius.circular(screenCornerR),
      ),
      screenPaint,
    );

    // Bottom bezel LEDs
    final ledCenterY = monitorH - bezelBottom / 2;
    final ledRadius = bezelBottom * 0.15;

    // Green power LED with glow
    final greenLedX = w * 0.42;
    canvas.drawCircle(
      Offset(greenLedX, ledCenterY),
      ledRadius + 3.0,
      Paint()
        ..color = theme.ledGreen.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );
    canvas.drawCircle(
      Offset(greenLedX, ledCenterY),
      ledRadius,
      Paint()..color = theme.ledGreen,
    );

    // Yellow status LED with glow
    final yellowLedX = w * 0.58;
    canvas.drawCircle(
      Offset(yellowLedX, ledCenterY),
      ledRadius + 2.0,
      Paint()
        ..color = theme.ledYellow.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );
    canvas.drawCircle(
      Offset(yellowLedX, ledCenterY),
      ledRadius,
      Paint()..color = theme.ledYellow,
    );

    // Top-edge highlight (subtle light reflection)
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.2, 0),
        Offset(w * 0.8, 0),
        [
          Colors.transparent,
          const Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final highlightPath = Path()
      ..moveTo(cornerR, 0.5)
      ..lineTo(w - cornerR, 0.5);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawNeck(Canvas canvas, double w, double neckTop, double neckBottom) {
    final neckW = w * 0.15;
    final neckLeft = (w - neckW) / 2;
    final neckRect = Rect.fromLTRB(neckLeft, neckTop, neckLeft + neckW, neckBottom);

    // Darker shade of body gradient
    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientEnd, theme.bodyGradientEnd],
      ).createShader(neckRect);
    canvas.drawRect(neckRect, neckPaint);
  }

  void _drawBase(Canvas canvas, double w, double baseTop, double baseH) {
    final baseW = w * 0.45;
    final baseLeft = (w - baseW) / 2;
    final baseRect = Rect.fromLTWH(baseLeft, baseTop, baseW, baseH);
    final baseCornerR = Radius.circular(4.0);
    final baseTopCornerR = Radius.circular(2.0);

    // Body gradient for base
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientStart, theme.bodyGradientEnd],
      ).createShader(baseRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        baseRect,
        topLeft: baseTopCornerR,
        topRight: baseTopCornerR,
        bottomLeft: baseCornerR,
        bottomRight: baseCornerR,
      ),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(HostBodyPainter old) => old.theme != theme;
}

/// Renders a host body inside a [PhysicalShape] for elevation & shadow.
class HostBodyWidget extends StatelessWidget {
  const HostBodyWidget({
    super.key,
    required this.theme,
    this.elevation = 5,
  });

  final double elevation;
  final HostDeviceTheme theme;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: _HostBodyClipper(),
      color: theme.bodyGradientEnd,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: theme.shadowOpacity),
      child: CustomPaint(
        painter: HostBodyPainter(theme: theme),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HostBodyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final monitorH = h * 0.75;
    final neckH = h * 0.08;
    final baseH = h * 0.12;
    final neckW = w * 0.15;
    final baseW = w * 0.45;
    final cornerR = 8.0;

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
      topLeft: const Radius.circular(2.0),
      topRight: const Radius.circular(2.0),
      bottomLeft: const Radius.circular(4.0),
      bottomRight: const Radius.circular(4.0),
    ));

    return path;
  }

  @override
  bool shouldReclip(_HostBodyClipper old) => false;
}
