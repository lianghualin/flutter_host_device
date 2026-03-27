import 'package:flutter/material.dart';

import 'port_status.dart';

/// Color theme for [HostDeviceView].
///
/// Provides two built-in themes via [HostDeviceTheme.dark] and
/// [HostDeviceTheme.light]. Custom themes can be created by passing
/// values to the default constructor.
///
/// Duplicates the switch theme's body/LED colors for visual consistency
/// across the device family, and adds host-specific screen colors.
@immutable
class HostDeviceTheme {
  const HostDeviceTheme({
    required this.bodyGradientStart,
    required this.bodyGradientEnd,
    required this.portUp,
    required this.portDown,
    required this.portUnknown,
    required this.portLabelOnLight,
    required this.portLabelOnDark,
    required this.activeColor,
    required this.ledGreen,
    required this.ledYellow,
    required this.ledInactive,
    required this.shadowOpacity,
    required this.screenGradientStart,
    required this.screenGradientEnd,
    required this.screenBorderColor,
  });

  /// Dark theme — matches the switch device dark theme colors.
  const HostDeviceTheme.dark()
    : bodyGradientStart = const Color(0xFF5A5A6E),
      bodyGradientEnd = const Color(0xFF44445A),
      portUp = const Color(0xFF2CC339),
      portDown = const Color(0xFF9E9E9E),
      portUnknown = const Color(0xFF333333),
      portLabelOnLight = const Color(0xFFFFFFFF),
      portLabelOnDark = const Color(0xFFFFFFFF),
      activeColor = const Color(0xFF2CC339),
      ledGreen = const Color(0xFF49B87D),
      ledYellow = const Color(0xFFF0CC18),
      ledInactive = const Color(0xFF414142),
      shadowOpacity = 0.4,
      screenGradientStart = const Color(0xFFE2E2E2),
      screenGradientEnd = const Color(0xFFD0D0D0),
      screenBorderColor = const Color(0x1A000000);

  /// Light theme — lighter body, same port colors as dark for consistency.
  const HostDeviceTheme.light()
    : bodyGradientStart = const Color(0xFFD8DAE0),
      bodyGradientEnd = const Color(0xFFC2C4CC),
      portUp = const Color(0xFF2CC339),
      portDown = const Color(0xFF9E9E9E),
      portUnknown = const Color(0xFF333333),
      portLabelOnLight = const Color(0xFF444444),
      portLabelOnDark = const Color(0xFFFFFFFF),
      activeColor = const Color(0xFF2CC339),
      ledGreen = const Color(0xFF34A853),
      ledYellow = const Color(0xFFE8A317),
      ledInactive = const Color(0xFFB0B2BA),
      shadowOpacity = 0.12,
      screenGradientStart = const Color(0xFFF0F0F0),
      screenGradientEnd = const Color(0xFFE8E8E8),
      screenBorderColor = const Color(0x0D000000);

  final Color bodyGradientStart;
  final Color bodyGradientEnd;
  final Color portUp;
  final Color portDown;
  final Color portUnknown;

  /// Label text color used on light-colored ports.
  final Color portLabelOnLight;

  /// Label text color used on dark-colored ports.
  final Color portLabelOnDark;

  final Color activeColor;
  final Color ledGreen;
  final Color ledYellow;
  final Color ledInactive;
  final double shadowOpacity;

  /// Screen gradient start color (top of screen area).
  final Color screenGradientStart;

  /// Screen gradient end color (bottom of screen area).
  final Color screenGradientEnd;

  /// Border color for the screen area.
  final Color screenBorderColor;

  /// Returns the appropriate label color for a port with the given [portColor].
  Color labelColorFor(Color portColor) {
    return portColor.computeLuminance() > 0.5
        ? portLabelOnLight
        : portLabelOnDark;
  }

  /// Returns the port color for the given status, respecting config/invalid flags.
  Color portColorForStatus(
    PortStatus status, {
    bool isConfig = false,
    bool isInvalid = false,
  }) {
    if (isConfig) return portDown;
    if (isInvalid) return portUnknown;
    return switch (status) {
      PortStatus.up => portUp,
      PortStatus.down => portDown,
      PortStatus.unknown => portUnknown,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostDeviceTheme &&
          bodyGradientStart == other.bodyGradientStart &&
          bodyGradientEnd == other.bodyGradientEnd &&
          portUp == other.portUp &&
          portDown == other.portDown &&
          portUnknown == other.portUnknown &&
          portLabelOnLight == other.portLabelOnLight &&
          portLabelOnDark == other.portLabelOnDark &&
          activeColor == other.activeColor &&
          ledGreen == other.ledGreen &&
          ledYellow == other.ledYellow &&
          ledInactive == other.ledInactive &&
          shadowOpacity == other.shadowOpacity &&
          screenGradientStart == other.screenGradientStart &&
          screenGradientEnd == other.screenGradientEnd &&
          screenBorderColor == other.screenBorderColor;

  @override
  int get hashCode => Object.hash(
    bodyGradientStart,
    bodyGradientEnd,
    portUp,
    portDown,
    portUnknown,
    portLabelOnLight,
    portLabelOnDark,
    activeColor,
    ledGreen,
    ledYellow,
    ledInactive,
    shadowOpacity,
    screenGradientStart,
    screenGradientEnd,
    screenBorderColor,
  );
}
