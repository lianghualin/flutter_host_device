import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/port_status.dart';
import 'package:flutter_host_device/src/widgets/host_device_view.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('HostDeviceView', () {
    testWidgets('renders without error for 5 ports', (tester) async {
      await tester.pumpWidget(
        wrapInApp(HostDeviceView(size: const Size(800, 400), portCount: 5)),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });

    testWidgets('renders without error for 1 port', (tester) async {
      await tester.pumpWidget(
        wrapInApp(HostDeviceView(size: const Size(800, 400), portCount: 1)),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });

    testWidgets('renders without error for 12 ports', (tester) async {
      await tester.pumpWidget(
        wrapInApp(HostDeviceView(size: const Size(800, 400), portCount: 12)),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });

    testWidgets('renders without error for 0 ports', (tester) async {
      await tester.pumpWidget(
        wrapInApp(HostDeviceView(size: const Size(800, 400), portCount: 0)),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });

    testWidgets('displays center label', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HostDeviceView(
            size: const Size(800, 400),
            portCount: 3,
            centerLabel: 'Host-Server-01',
          ),
        ),
      );
      expect(find.text('Host-Server-01'), findsOneWidget);
    });

    testWidgets('fires onPortTap callback', (tester) async {
      int? tappedPort;
      await tester.pumpWidget(
        wrapInApp(
          HostDeviceView(
            size: const Size(800, 400),
            portCount: 5,
            onPortTap: (port) => tappedPort = port,
          ),
        ),
      );
      await tester.tap(find.text('1'));
      expect(tappedPort, 1);
    });

    testWidgets('renders with config mode', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HostDeviceView(
            size: const Size(800, 400),
            portCount: 5,
            portStatuses: const {1: PortStatus.up, 2: PortStatus.up},
            isConfig: true,
          ),
        ),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });

    testWidgets('renders with custom centerYFactor', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          HostDeviceView(
            size: const Size(800, 400),
            portCount: 5,
            centerYFactor: 0.4,
          ),
        ),
      );
      expect(find.byType(HostDeviceView), findsOneWidget);
    });
  });

  group('HostDeviceView.getPortPositions', () {
    test('returns correct port count', () {
      final positions = HostDeviceView.getPortPositions(
        5,
        const Size(800, 400),
      );
      expect(positions.length, 5);
    });

    test('returns empty map for 0 ports', () {
      final positions = HostDeviceView.getPortPositions(
        0,
        const Size(800, 400),
      );
      expect(positions, isEmpty);
    });

    test('is deterministic — same inputs produce same outputs', () {
      const size = Size(800, 400);
      final a = HostDeviceView.getPortPositions(8, size);
      final b = HostDeviceView.getPortPositions(8, size);
      for (final key in a.keys) {
        expect(a[key], b[key]);
      }
    });

    test('respects centerYFactor parameter', () {
      const size = Size(800, 400);
      final a = HostDeviceView.getPortPositions(5, size, centerYFactor: 0.6);
      final b = HostDeviceView.getPortPositions(5, size, centerYFactor: 0.4);
      // Different centerYFactor should produce different Y positions
      expect(a[1]!.dy, isNot(b[1]!.dy));
    });
  });
}
