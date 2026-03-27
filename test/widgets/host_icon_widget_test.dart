import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/host_device_theme.dart';
import 'package:flutter_host_device/src/painters/host_icon_painter.dart';
import 'package:flutter_host_device/src/widgets/host_icon_widget.dart';

void main() {
  const dark = HostDeviceTheme.dark();
  const light = HostDeviceTheme.light();

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('HostIconWidget', () {
    testWidgets('renders at plain size (48px width)', (tester) async {
      await tester.pumpWidget(
        wrap(const HostIconWidget(size: 48, theme: dark)),
      );
      expect(find.byType(HostIconWidget), findsOneWidget);

      final box = tester.renderObject<RenderBox>(find.byType(HostIconWidget));
      expect(box.size.width, 48);
      expect(box.size.height, closeTo(57.6, 0.1)); // 48 * 1.2
    });

    testWidgets('renders at compact size (30px width)', (tester) async {
      await tester.pumpWidget(
        wrap(const HostIconWidget(size: 30, theme: dark)),
      );
      expect(find.byType(HostIconWidget), findsOneWidget);

      final box = tester.renderObject<RenderBox>(find.byType(HostIconWidget));
      expect(box.size.width, 30);
      expect(box.size.height, closeTo(36, 0.1)); // 30 * 1.2
    });

    testWidgets('renders with light theme', (tester) async {
      await tester.pumpWidget(
        wrap(const HostIconWidget(size: 40, theme: light)),
      );
      expect(find.byType(HostIconWidget), findsOneWidget);
    });

    testWidgets('renders with custom elevation', (tester) async {
      await tester.pumpWidget(
        wrap(const HostIconWidget(size: 48, elevation: 10, theme: dark)),
      );
      final shape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(shape.elevation, 10);
    });

    testWidgets('uses default elevation of 5', (tester) async {
      await tester.pumpWidget(
        wrap(const HostIconWidget(size: 48, theme: dark)),
      );
      final shape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(shape.elevation, 5);
    });

    testWidgets('auto-detects dark theme from context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: HostIconWidget(size: 48)),
        ),
      );
      expect(find.byType(HostIconWidget), findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(HostIconWidget),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = customPaint.painter! as HostIconPainter;
      expect(painter.theme, const HostDeviceTheme.dark());
    });

    testWidgets('auto-detects light theme from context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: HostIconWidget(size: 48)),
        ),
      );
      expect(find.byType(HostIconWidget), findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(HostIconWidget),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = customPaint.painter! as HostIconPainter;
      expect(painter.theme, const HostDeviceTheme.light());
    });
  });
}
