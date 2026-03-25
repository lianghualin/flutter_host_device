import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_host_device/flutter_host_device.dart';

void main() {
  test('public API exports are accessible', () {
    expect(PortStatus.up, isNotNull);
    expect(const HostDeviceTheme.dark(), isA<HostDeviceTheme>());
    expect(const HostDeviceTheme.light(), isA<HostDeviceTheme>());
    // Widget exports are accessible
    expect(HostDeviceView.new, isA<Function>());
    expect(HostIconWidget.new, isA<Function>());
    expect(HostIconPainter.new, isA<Function>());
    expect(HostBodyPainter.new, isA<Function>());
  });
}
