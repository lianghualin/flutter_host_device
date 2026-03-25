import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/host_device_theme.dart';

/// Draws a compact host device icon: miniaturized monitor + neck + base.
///
/// Used as a small device indicator in topology views and device lists.
/// Width is the monitor width; total height is width * [_heightRatio].
///
/// All colors are sourced from [theme].
class HostIconPainter extends CustomPainter {
  HostIconPainter({required this.theme});

  final HostDeviceTheme theme;

  /// Total height = width * _heightRatio.
  static const double heightRatio = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Proportions matching the body painter
    final monitorH = h * 0.75;
    final neckH = h * 0.08;
    final baseH = h * 0.12;
    final monitorBottom = monitorH;
    final neckBottom = monitorBottom + neckH;

    _drawMonitor(canvas, w, monitorH);
    _drawNeck(canvas, w, monitorBottom, neckBottom);
    _drawBase(canvas, w, neckBottom, baseH);
    _drawEdgeHighlight(canvas, w);
  }

  void _drawMonitor(Canvas canvas, double w, double monitorH) {
    final cornerR = w * 0.08;
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

    // Screen area
    final bezelSide = w * 0.10;
    final bezelTop = monitorH * 0.10;
    final bezelBottom = monitorH * 0.22;
    final screenRect = Rect.fromLTRB(
      bezelSide,
      bezelTop,
      w - bezelSide,
      monitorH - bezelBottom,
    );
    final screenCornerR = w * 0.04;

    // Screen fill
    final screenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.screenGradientStart, theme.screenGradientEnd],
      ).createShader(screenRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(screenCornerR)),
      screenPaint,
    );

    // Screen border
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(screenCornerR)),
      Paint()
        ..color = theme.screenBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Bottom bezel LEDs
    final ledCenterY = monitorH - bezelBottom / 2;
    final ledRadius = bezelBottom * 0.12;

    // Green power LED with glow
    final greenLedX = w * 0.42;
    canvas.drawCircle(
      Offset(greenLedX, ledCenterY),
      ledRadius + 2.0,
      Paint()
        ..color = theme.ledGreen.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
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
      ledRadius + 1.5,
      Paint()
        ..color = theme.ledYellow.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawCircle(
      Offset(yellowLedX, ledCenterY),
      ledRadius,
      Paint()..color = theme.ledYellow,
    );
  }

  void _drawNeck(Canvas canvas, double w, double neckTop, double neckBottom) {
    final neckW = w * 0.15;
    final neckLeft = (w - neckW) / 2;
    final neckRect = Rect.fromLTRB(neckLeft, neckTop, neckLeft + neckW, neckBottom);

    canvas.drawRect(
      neckRect,
      Paint()..color = theme.bodyGradientEnd,
    );
  }

  void _drawBase(Canvas canvas, double w, double baseTop, double baseH) {
    final baseW = w * 0.45;
    final baseLeft = (w - baseW) / 2;
    final baseRect = Rect.fromLTWH(baseLeft, baseTop, baseW, baseH);

    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientStart, theme.bodyGradientEnd],
      ).createShader(baseRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        baseRect,
        topLeft: const Radius.circular(1.5),
        topRight: const Radius.circular(1.5),
        bottomLeft: const Radius.circular(3.0),
        bottomRight: const Radius.circular(3.0),
      ),
      basePaint,
    );
  }

  void _drawEdgeHighlight(Canvas canvas, double w) {
    final cornerR = w * 0.08;
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

    final path = Path()
      ..moveTo(cornerR, 0.5)
      ..lineTo(w - cornerR, 0.5);
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(HostIconPainter old) => old.theme != theme;
}
