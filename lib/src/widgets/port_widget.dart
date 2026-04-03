import 'package:flutter/material.dart';
import 'package:topology_view_icons/topology_view_icons.dart';

import '../models/host_device_theme.dart';
import '../models/port_status.dart';

/// Renders a single port with hover float animation and tap handling.
class PortWidget extends StatefulWidget {
  const PortWidget({
    super.key,
    required this.portNumber,
    required this.position,
    required this.size,
    required this.status,
    required this.theme,
    this.label,
    this.isConfig = false,
    this.isSelected = false,
    this.enableHoverAnimation = true,
    this.opacity = 1.0,
    this.showLabel = true,
    this.labelStyle,
    this.labelBackgroundDecoration,
    this.onHover,
    this.onHoverExit,
    this.onTap,
  });

  final int portNumber;

  /// Custom label text. When null, displays the port number.
  final String? label;

  /// Top-left position within the parent Stack.
  final Offset position;

  /// Width and height of the port square.
  final double size;

  final PortStatus status;
  final HostDeviceTheme theme;
  final bool isConfig;

  /// When true, the hover float animation is held at the forward position
  /// regardless of mouse hover state.
  final bool isSelected;

  /// When false, the port hover float animation is disabled. Ports remain
  /// static on hover. Tap and status callbacks still fire normally.
  final bool enableHoverAnimation;

  /// Opacity for the entire port widget. Defaults to 1.0 (fully opaque).
  /// Use values < 1.0 to dim unselected ports in spotlight mode.
  final double opacity;

  /// When false, the port label text is hidden.
  final bool showLabel;

  /// Custom text style for the port label. When null, uses the default style.
  final TextStyle? labelStyle;

  /// Custom decoration for the port label background pill.
  /// When null, a default semi-transparent rounded background is used.
  /// Set to [BoxDecoration()] (empty) to disable the background pill.
  final BoxDecoration? labelBackgroundDecoration;

  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;
  final VoidCallback? onTap;

  @override
  State<PortWidget> createState() => _PortWidgetState();
}

class _PortWidgetState extends State<PortWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatOffset = Tween<double>(
      begin: 0,
      end: -3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.enableHoverAnimation && widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PortWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enableHoverAnimation) {
      _controller.value = 0;
      return;
    }
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _maybeWrapOpacity({required Widget child}) {
    if (widget.opacity >= 1.0) return child;
    return Opacity(opacity: widget.opacity, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final portColor = widget.theme.portColorForStatus(
      widget.status,
      isConfig: widget.isConfig,
    );
    final labelColor = widget.theme.labelColorFor(portColor);

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: _maybeWrapOpacity(
        child: MouseRegion(
          onEnter: (_) {
            if (widget.enableHoverAnimation) _controller.forward();
            widget.onHover?.call();
          },
          onExit: (_) {
            if (widget.enableHoverAnimation && !widget.isSelected) {
              _controller.reverse();
            }
            widget.onHoverExit?.call();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _floatOffset,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatOffset.value),
                child: child,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: TopoPortPainter(
                        isUp: widget.status == PortStatus.up,
                        isDisabled: widget.status == PortStatus.unknown,
                        style: TopoIconStyle.lnm,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  if (widget.showLabel)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration:
                          widget.labelBackgroundDecoration ??
                          BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                      child: Text(
                        widget.label ?? '${widget.portNumber}',
                        style:
                            widget.labelStyle ??
                            TextStyle(
                              color: labelColor,
                              fontSize: (widget.size * 0.28).clamp(8.0, 12.0),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
