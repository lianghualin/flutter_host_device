import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/src/models/port_status.dart';
import 'package:flutter_host_device/src/models/host_device_theme.dart';
import 'package:flutter_host_device/src/painters/port_painter.dart';

void main() {
  const dark = HostDeviceTheme.dark();
  const light = HostDeviceTheme.light();

  group('HostDeviceTheme.portColorForStatus', () {
    test('up returns green (dark)', () {
      expect(dark.portColorForStatus(PortStatus.up), const Color(0xFF2CC339));
    });

    test('down returns grey (dark)', () {
      expect(dark.portColorForStatus(PortStatus.down), const Color(0xFF9E9E9E));
    });

    test('unknown returns dark grey (dark)', () {
      expect(dark.portColorForStatus(PortStatus.unknown), const Color(0xFF333333));
    });

    test('config mode always returns down color', () {
      expect(
        dark.portColorForStatus(PortStatus.up, isConfig: true),
        const Color(0xFF9E9E9E),
      );
    });

    test('invalid port returns unknown color', () {
      expect(
        dark.portColorForStatus(PortStatus.up, isInvalid: true),
        const Color(0xFF333333),
      );
    });

    test('light theme uses same port colors as dark', () {
      expect(light.portColorForStatus(PortStatus.up), dark.portColorForStatus(PortStatus.up));
      expect(light.portColorForStatus(PortStatus.down), dark.portColorForStatus(PortStatus.down));
      expect(light.portColorForStatus(PortStatus.unknown), dark.portColorForStatus(PortStatus.unknown));
    });
  });

  group('HostDeviceTheme.labelColorFor', () {
    test('dark port gets light label', () {
      expect(dark.labelColorFor(const Color(0xFF333333)), const Color(0xFFFFFFFF));
    });

    test('light port gets dark label (light theme)', () {
      expect(light.labelColorFor(const Color(0xFFE0E0E0)), const Color(0xFF444444));
    });

    test('green port gets white label', () {
      expect(light.labelColorFor(const Color(0xFF34A853)), const Color(0xFFFFFFFF));
    });
  });

  group('HostDeviceTheme equality', () {
    test('same named constructors are equal', () {
      expect(const HostDeviceTheme.dark(), const HostDeviceTheme.dark());
    });

    test('dark and light are not equal', () {
      expect(const HostDeviceTheme.dark() == const HostDeviceTheme.light(), isFalse);
    });
  });

  group('HostDeviceTheme screen colors', () {
    test('dark theme has screen colors', () {
      expect(dark.screenGradientStart, const Color(0xFFE2E2E2));
      expect(dark.screenGradientEnd, const Color(0xFFD0D0D0));
      expect(dark.screenBorderColor, const Color(0x1A000000));
    });

    test('light theme has lighter screen colors', () {
      expect(light.screenGradientStart, const Color(0xFFF0F0F0));
      expect(light.screenGradientEnd, const Color(0xFFE8E8E8));
    });
  });

  group('PortPainter', () {
    test('shouldRepaint returns true when color changes', () {
      final a = PortPainter(color: Colors.green);
      final b = PortPainter(color: Colors.red);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when color is same', () {
      final a = PortPainter(color: Colors.green);
      final b = PortPainter(color: Colors.green);
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
