import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/port_status.dart';
import 'package:flutter_host_device/src/models/host_device_theme.dart';
import 'package:flutter_host_device/src/widgets/port_widget.dart';

void main() {
  const theme = HostDeviceTheme.dark();

  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Stack(children: [child])),
    );
  }

  group('PortWidget', () {
    testWidgets('renders port number label', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 7,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
          ),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(PortWidget));
      expect(tapped, isTrue);
    });

    testWidgets('fires onHover callback on mouse enter', (tester) async {
      bool hovered = false;
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            onHover: () => hovered = true,
          ),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(PortWidget)));
      await tester.pump();
      expect(hovered, isTrue);
    });

    testWidgets('fires onHoverExit callback on mouse exit', (tester) async {
      bool exited = false;
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            onHoverExit: () => exited = true,
          ),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(PortWidget)));
      await tester.pump();
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(exited, isTrue);
    });

    testWidgets('renders with different port statuses', (tester) async {
      for (final status in PortStatus.values) {
        await tester.pumpWidget(
          wrapInApp(
            PortWidget(
              portNumber: 1,
              position: const Offset(100, 100),
              size: 30,
              status: status,
              theme: theme,
            ),
          ),
        );
        expect(find.byType(PortWidget), findsOneWidget);
      }
    });

    testWidgets('renders with config mode', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isConfig: true,
          ),
        ),
      );
      expect(find.byType(PortWidget), findsOneWidget);
    });

    testWidgets('holds float animation forward when isSelected is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isSelected: true,
          ),
        ),
      );
      // Let animation complete
      await tester.pumpAndSettle();

      // The Transform.translate should have the float offset applied (-3)
      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().y, -3.0);
    });

    testWidgets('animation stays at rest when isSelected is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().y, 0.0);
    });

    testWidgets('toggling isSelected drives animation forward and back', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify at rest
      var transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().y, 0.0);

      // Select the port
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isSelected: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().y, -3.0);

      // Deselect the port
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().y, 0.0);
    });

    testWidgets(
      'hover exit does not reverse animation when isSelected is true',
      (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            PortWidget(
              portNumber: 1,
              position: const Offset(100, 100),
              size: 30,
              status: PortStatus.up,
              theme: theme,
              isSelected: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        // Enter then exit
        await gesture.moveTo(tester.getCenter(find.byType(PortWidget)));
        await tester.pump();
        await gesture.moveTo(Offset.zero);
        await tester.pumpAndSettle();

        final transform = tester.widget<Transform>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Transform),
          ),
        );
        expect(transform.transform.getTranslation().y, -3.0);
      },
    );

    testWidgets('applies opacity when provided', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
            opacity: 0.15,
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.15);
    });

    testWidgets('does not wrap in Opacity when opacity is 1.0', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          PortWidget(
            portNumber: 1,
            position: const Offset(100, 100),
            size: 30,
            status: PortStatus.up,
            theme: theme,
          ),
        ),
      );

      expect(find.byType(Opacity), findsNothing);
    });
  });
}
