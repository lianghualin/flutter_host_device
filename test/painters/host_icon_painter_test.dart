import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/host_device_theme.dart';
import 'package:flutter_host_device/src/painters/host_icon_painter.dart';

void main() {
  const dark = HostDeviceTheme.dark();
  const light = HostDeviceTheme.light();

  group('HostIconPainter', () {
    test('shouldRepaint returns true when theme changes', () {
      final a = HostIconPainter(theme: dark);
      final b = HostIconPainter(theme: light);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when theme is same', () {
      final a = HostIconPainter(theme: dark);
      final b = HostIconPainter(theme: dark);
      expect(a.shouldRepaint(b), isFalse);
    });

    test('can paint without errors at 48x58 (plain size)', () {
      final painter = HostIconPainter(theme: dark);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(48, 57.6)); // 48 * 1.2
      recorder.endRecording();
    });

    test('can paint without errors at 30x36 (compact size)', () {
      final painter = HostIconPainter(theme: dark);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(30, 36)); // 30 * 1.2
      recorder.endRecording();
    });

    test('can paint with light theme', () {
      final painter = HostIconPainter(theme: light);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(48, 57.6));
      recorder.endRecording();
    });

    test('heightRatio is 1.2', () {
      expect(HostIconPainter.heightRatio, 1.2);
    });
  });
}
