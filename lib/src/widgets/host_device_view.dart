import 'dart:math';

import 'package:flutter/material.dart';
import 'package:topology_view_icons/topology_view_icons.dart';

import '../layout/host_layout.dart';
import '../models/host_device_theme.dart';
import '../models/port_status.dart';
import 'port_widget.dart';

/// Renders a host device with interactive ports arranged in a semi-elliptical
/// arc above the center device.
///
/// When [theme] is null, the widget auto-detects from [Theme.of(context).brightness].
class HostDeviceView extends StatelessWidget {
  const HostDeviceView({
    super.key,
    required this.size,
    required this.portCount,
    this.portStatuses = const {},
    this.portLabels = const {},
    this.deviceType = TopoDeviceType.host,
    this.isConfig = false,
    this.centerLabel,
    this.centerYFactor = 0.6,
    this.centerDeviceBuilder,
    this.portPositionOverride,
    this.portSize,
    this.onPortHover,
    this.onPortHoverExit,
    this.onPortTap,
    this.onHostHover,
    this.onHostHoverExit,
    this.theme,
  });

  final Size size;
  final int portCount;
  final Map<int, PortStatus> portStatuses;

  /// Custom labels for ports. When a port has no entry, its number is shown.
  final Map<int, String> portLabels;

  /// The device type icon to display at center. Defaults to [TopoDeviceType.host].
  final TopoDeviceType deviceType;

  final bool isConfig;

  /// Hostname label displayed below the base.
  final String? centerLabel;

  /// Vertical center position factor (0.0 = top, 1.0 = bottom). Defaults to 0.6.
  final double centerYFactor;

  /// Optional builder to replace the default host body with a custom widget.
  /// Receives the available size and resolved theme.
  /// When null, the built-in [HostBodyWidget] is used.
  final Widget Function(BuildContext context, Size bodySize, HostDeviceTheme theme)? centerDeviceBuilder;

  /// Normalized port positions (0.0–1.0) relative to the center device body.
  /// When provided, ports are placed on the body instead of the semi-elliptical arc.
  /// Key is port number (1-based), value is Offset(x%, y%) within the body bounds.
  final Map<int, Offset>? portPositionOverride;

  /// Port icon size in logical pixels. Defaults to [HostLayout.portSize] (45).
  final double? portSize;

  final ValueChanged<int>? onPortHover;
  final VoidCallback? onPortHoverExit;
  final ValueChanged<int>? onPortTap;
  final VoidCallback? onHostHover;
  final VoidCallback? onHostHoverExit;

  /// Optional theme override. When null, auto-detects from app brightness.
  final HostDeviceTheme? theme;

  /// Returns port center positions for the given port count and viewport size.
  ///
  /// Synchronous and deterministic. Returns the **center** position of each port.
  static Map<int, Offset> getPortPositions(
    int portCount,
    Size viewportSize, {
    double centerYFactor = 0.6,
  }) {
    return HostLayout.computePortCenters(
      portCount,
      viewportSize,
      centerYFactor: centerYFactor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? const HostDeviceTheme.dark()
            : const HostDeviceTheme.light());

    final resolvedPortSize = portSize ?? HostLayout.portSize;

    final centerSize = HostLayout.computeCenterSize(size);
    final hostCenter = HostLayout.computeHostCenter(
      size,
      centerYFactor: centerYFactor,
    );
    final portCenters = HostLayout.computePortCenters(
      portCount,
      size,
      centerYFactor: centerYFactor,
    );

    // Host body dimensions — monitor aspect ratio ~4:3, total with stand
    final monitorWidth = centerSize;
    final totalHeight = centerSize * 1.2; // monitor + neck + base
    final bodyLeft = hostCenter.dx - monitorWidth / 2;
    final bodyTop = hostCenter.dy - totalHeight * 0.45; // shift up slightly

    // Label font size
    final labelFontSize = max(16.0, min(18.0, centerSize / 12));

    return MouseRegion(
      onEnter: (_) => onHostHover?.call(),
      onExit: (_) => onHostHoverExit?.call(),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Host body
            Positioned(
              left: bodyLeft,
              top: bodyTop,
              width: monitorWidth,
              height: totalHeight,
              child: centerDeviceBuilder != null
                  ? centerDeviceBuilder!(context, Size(monitorWidth, totalHeight), resolvedTheme)
                  : CustomPaint(
                      painter: TopoIconPainter(
                        deviceType: deviceType,
                        style: TopoIconStyle.lnm,
                      ),
                      child: const SizedBox.expand(),
                    ),
            ),

            // Label below the base
            if (centerLabel != null)
              Positioned(
                left: bodyLeft - monitorWidth * 0.25,
                top: bodyTop + totalHeight + 6,
                width: monitorWidth * 1.5,
                child: Tooltip(
                  message: centerLabel!,
                  child: Text(
                    centerLabel!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),

            // Ports — use override positions if provided, otherwise arc layout
            if (portPositionOverride != null)
              for (final entry in portPositionOverride!.entries)
                PortWidget(
                  portNumber: entry.key,
                  label: portLabels[entry.key],
                  position: Offset(
                    bodyLeft + entry.value.dx * monitorWidth - resolvedPortSize / 2,
                    bodyTop + entry.value.dy * totalHeight - resolvedPortSize / 2,
                  ),
                  size: resolvedPortSize,
                  status: isConfig
                      ? PortStatus.down
                      : (portStatuses[entry.key] ?? PortStatus.unknown),
                  theme: resolvedTheme,
                  isConfig: isConfig,
                  onHover: () => onPortHover?.call(entry.key),
                  onHoverExit: onPortHoverExit,
                  onTap: () => onPortTap?.call(entry.key),
                )
            else
              for (final entry in portCenters.entries)
                PortWidget(
                  portNumber: entry.key,
                  label: portLabels[entry.key],
                  position: Offset(
                    entry.value.dx - resolvedPortSize / 2,
                    entry.value.dy - resolvedPortSize / 2,
                  ),
                  size: resolvedPortSize,
                  status: isConfig
                      ? PortStatus.down
                      : (portStatuses[entry.key] ?? PortStatus.unknown),
                  theme: resolvedTheme,
                  isConfig: isConfig,
                  onHover: () => onPortHover?.call(entry.key),
                  onHoverExit: onPortHoverExit,
                  onTap: () => onPortTap?.call(entry.key),
                ),
          ],
        ),
      ),
    );
  }
}
