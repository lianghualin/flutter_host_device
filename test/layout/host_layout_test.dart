import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/layout/host_layout.dart';

void main() {
  group('HostLayout.computePortCenters', () {
    test('returns empty map for zero ports', () {
      final positions = HostLayout.computePortCenters(
        0,
        const Size(800, 400),
      );
      expect(positions, isEmpty);
    });

    test('returns correct number of ports for 5 ports', () {
      final positions = HostLayout.computePortCenters(
        5,
        const Size(800, 400),
      );
      expect(positions.length, 5);
      expect(positions.keys, containsAll([1, 2, 3, 4, 5]));
    });

    test('returns correct number of ports for 12 ports', () {
      final positions = HostLayout.computePortCenters(
        12,
        const Size(800, 400),
      );
      expect(positions.length, 12);
    });

    test('single port is centered above host (90 degrees)', () {
      final positions = HostLayout.computePortCenters(
        1,
        const Size(800, 400),
      );
      final center = Offset(400, 400 * 0.6);
      // At 90 degrees, x should be near center, y should be above center
      expect(positions[1]!.dx, closeTo(center.dx, 1.0));
      expect(positions[1]!.dy, lessThan(center.dy));
    });

    test('ports are arranged above the host center', () {
      final size = const Size(800, 400);
      final positions = HostLayout.computePortCenters(5, size);
      final hostCenterY = size.height * 0.6;
      for (final pos in positions.values) {
        expect(pos.dy, lessThan(hostCenterY));
      }
    });

    test('first port is to the right, last port is to the left (30 to 150 deg)', () {
      final positions = HostLayout.computePortCenters(
        5,
        const Size(800, 400),
      );
      // Port 1 at 30 deg (rightmost), port 5 at 150 deg (leftmost)
      expect(positions[1]!.dx, greaterThan(positions[5]!.dx));
    });

    test('ports are evenly distributed along the arc', () {
      final positions = HostLayout.computePortCenters(
        5,
        const Size(800, 400),
      );
      // Check that spacing between consecutive ports is approximately equal
      final dxDeltas = <double>[];
      for (int i = 1; i < 5; i++) {
        final dx = positions[i]!.dx - positions[i + 1]!.dx;
        dxDeltas.add(dx);
      }
      // All dx deltas should be positive (decreasing x from right to left)
      for (final dx in dxDeltas) {
        expect(dx, greaterThan(0));
      }
    });

    test('all port positions are within viewport bounds', () {
      final size = const Size(800, 400);
      final positions = HostLayout.computePortCenters(8, size);
      for (final pos in positions.values) {
        expect(pos.dx, greaterThanOrEqualTo(0));
        expect(pos.dx, lessThanOrEqualTo(size.width));
        expect(pos.dy, greaterThanOrEqualTo(0));
        expect(pos.dy, lessThanOrEqualTo(size.height));
      }
    });

    test('centerYFactor shifts host center vertically', () {
      final size = const Size(800, 400);
      final positions06 = HostLayout.computePortCenters(3, size, centerYFactor: 0.6);
      final positions04 = HostLayout.computePortCenters(3, size, centerYFactor: 0.4);
      // Ports with lower centerYFactor should be higher (lower Y)
      expect(positions04[1]!.dy, lessThan(positions06[1]!.dy));
    });

    test('two ports are symmetric around center', () {
      final positions = HostLayout.computePortCenters(
        2,
        const Size(800, 400),
      );
      final centerX = 400.0;
      // Port 1 at 30 deg, port 2 at 150 deg — should be symmetric around center
      expect(
        (positions[1]!.dx - centerX).abs(),
        closeTo((positions[2]!.dx - centerX).abs(), 1.0),
      );
      expect(positions[1]!.dy, closeTo(positions[2]!.dy, 1.0));
    });
  });

  group('HostLayout.computeCenterSize', () {
    test('returns 30% of minimum dimension', () {
      expect(HostLayout.computeCenterSize(const Size(800, 400)), closeTo(120, 0.1));
      expect(HostLayout.computeCenterSize(const Size(400, 800)), closeTo(120, 0.1));
    });
  });

  group('HostLayout.computeHostCenter', () {
    test('returns center at default 0.6 factor', () {
      final center = HostLayout.computeHostCenter(const Size(800, 400));
      expect(center.dx, 400);
      expect(center.dy, 240);
    });

    test('respects custom centerYFactor', () {
      final center = HostLayout.computeHostCenter(
        const Size(800, 400),
        centerYFactor: 0.5,
      );
      expect(center.dy, 200);
    });
  });

  group('HostLayout.portSize', () {
    test('is 45 pixels', () {
      expect(HostLayout.portSize, 45.0);
    });
  });
}
