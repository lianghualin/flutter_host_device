import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/host_device_theme.dart';
import 'package:flutter_host_device/src/painters/host_body_painter.dart';

void main() {
  const dark = HostDeviceTheme.dark();
  const light = HostDeviceTheme.light();

  group('HostBodyWidget', () {
    testWidgets('renders with dark theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 240,
              child: HostBodyWidget(theme: dark),
            ),
          ),
        ),
      );
      expect(find.byType(HostBodyWidget), findsOneWidget);
    });

    testWidgets('renders with light theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 240,
              child: HostBodyWidget(theme: light),
            ),
          ),
        ),
      );
      expect(find.byType(HostBodyWidget), findsOneWidget);
    });

    testWidgets('renders with custom elevation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 240,
              child: HostBodyWidget(theme: dark, elevation: 10),
            ),
          ),
        ),
      );
      final shape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(shape.elevation, 10);
    });
  });

  group('HostBodyPainter', () {
    test('shouldRepaint returns true when theme changes', () {
      final a = HostBodyPainter(theme: dark);
      final b = HostBodyPainter(theme: light);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when theme is same', () {
      final a = HostBodyPainter(theme: dark);
      final b = HostBodyPainter(theme: dark);
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
