import 'dart:math';
import 'dart:ui';

/// Pure-calculation layout engine for host device port positions.
///
/// Arranges ports in a semi-elliptical arc above the center host device.
class HostLayout {
  HostLayout._();

  /// Fixed port size in logical pixels.
  static const double portSize = 45.0;

  /// Returns port center positions in viewport coordinates.
  ///
  /// Ports are arranged in a semi-elliptical arc above the host center.
  /// Arc range: 30 deg to 150 deg (math convention, Y inverted for screen).
  static Map<int, Offset> computePortCenters(
    int portCount,
    Size viewportSize, {
    double centerYFactor = 0.6,
  }) {
    if (portCount <= 0) return {};

    final centerSize = min(viewportSize.width, viewportSize.height) * 0.3;
    final hostCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height * centerYFactor,
    );

    final radiusX = centerSize * 1.2 * 1.2; // radiusFactor * ellipseRatio
    final radiusY = centerSize * 1.2;

    final map = <int, Offset>{};

    for (int i = 1; i <= portCount; i++) {
      final double angleDeg;
      if (portCount == 1) {
        angleDeg = 90.0;
      } else {
        // Distribute from 30 deg to 150 deg
        angleDeg = 30.0 + (150.0 - 30.0) * (i - 1) / (portCount - 1);
      }
      final angleRad = angleDeg * pi / 180.0;

      final portX = hostCenter.dx + radiusX * cos(angleRad);
      final portY = hostCenter.dy - radiusY * sin(angleRad);

      map[i] = Offset(portX, portY);
    }

    return map;
  }

  /// Returns the center size used for the host body.
  static double computeCenterSize(Size viewportSize) {
    return min(viewportSize.width, viewportSize.height) * 0.3;
  }

  /// Returns the host center position.
  static Offset computeHostCenter(
    Size viewportSize, {
    double centerYFactor = 0.6,
  }) {
    return Offset(viewportSize.width / 2, viewportSize.height * centerYFactor);
  }
}
