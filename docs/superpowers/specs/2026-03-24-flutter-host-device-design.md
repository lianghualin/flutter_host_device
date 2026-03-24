# flutter_host_device — Design Spec

## Goal

A standalone Flutter package that renders host devices programmatically (no SVG assets). Follows the same pattern as `flutter_switch_device`. Designed for pub.dev publishing and to be consumed by `device_topology_view`.

## Package Scope

The package owns:
- Host center device painting (monitor + neck + base)
- Host floating icon painting (miniaturized desktop)
- Port arc layout engine (semi-elliptical arc above host)
- Port rendering (colored squares with labels)
- Port position API for consumers (`getPortPositions()`)

The package does NOT own:
- Radial ring layout (floating devices around the host)
- Connection lines
- Baseline/explore device positioning
- Spotlight/dim logic

## Dependencies

Flutter only. No external packages.

## Visual Design

### Style: A4 — Switch-Matching

Uses the same design language as `flutter_switch_device` for consistency across the device family.

### Center Device (HostBodyPainter)

**Monitor:**
- Gradient body: `#5a5a6e → #44445a` (same as switch)
- Rounded corners: ~8px radius
- Screen area: light grey gradient (`#E2E2E2 → #D0D0D0`), inset with 1px border
- Bottom bezel: thicker than sides, contains 2 LEDs
  - Green power LED with glow (`#49B87D`, `box-shadow: 0 0 3px`)
  - Yellow status LED with glow (`#F0CC18`, `box-shadow: 0 0 2px`)
- Top-edge highlight: subtle light reflection gradient (`rgba(255,255,255,0.12)`)
- Elevation shadow via PhysicalShape

**Neck:**
- Narrow rectangle connecting monitor to base
- Same gradient as body, darker shade

**Base:**
- Wider rounded rectangle below neck
- Same gradient as body
- Bottom corners more rounded than top

**Label:**
- Positioned below the base
- Dynamic font size: `max(16, min(18, size / 12))`
- FontWeight.w500, black, centered
- Single-line ellipsis overflow with tooltip

### Port Layout

Ports are arranged in a **semi-elliptical arc above** the center host device.

**Arc parameters:**
- Radius factor: `1.2 × centerSize`
- Ellipse ratio: 1.2 (wider than tall)
- Arc range: 30° to 150° measured counter-clockwise from the positive X-axis (standard math convention), with Y-axis inverted to place ports above the center. This fans ports from upper-right to upper-left.
- Special case: 1 port → directly above center (90°)
- 2+ ports → evenly distributed along arc

**Port appearance:**
- Size: 30×30px (fixed)
- Shape: Rounded square
- Colors (same as switch ports):
  - Up: Green (`#2CC339`)
  - Down: Grey (`#9E9E9E`)
  - Unknown: Black (`#333`)
  - Config mode: All grey
- Label: Port number displayed in white bold text, centered

**Dynamic port count:** No presets needed. The arc auto-arranges for any number of ports.

### Floating Icon (HostIconPainter)

**Style: I1 — Full Desktop Silhouette**

Miniaturized version of the center device: monitor + neck + base.

**Structure:**
- Monitor: gradient body with screen area, bottom bezel with power + status LEDs
- Neck: narrow connector
- Base: wider rounded stand
- Top-edge highlight
- Elevation via PhysicalShape

**Sizes:**

| Context | Monitor Width | Total Height | Halo Size |
|---------|-------------|-------------|-----------|
| Plain (48px) | 48px | ~58px | none |
| In status halo | 44px | ~53px | 80px circle |
| Small/compact | 30px | ~36px | 50px circle |

**Aspect ratio:** Total height = monitorWidth × 1.2 (monitor height including bezel, ~83% of total) + neckHeight (~7%) + baseHeight (~10%). Constant `_heightRatio = 1.2` — height is always 1.2× the width parameter.

**Usage context:**
- Compact: Icon only (outer ring / config devices)
- Full: Icon inside green/red circular status halo (inner ring / real devices)
- Elevation scales with hover: `2 + animationValue * 5`

## Public API

### Main Widget

```dart
HostDeviceView(
  size: Size(800, 400),
  portCount: 5,
  portStatuses: {1: PortStatus.up, 2: PortStatus.down, ...},
  isConfig: false,
  centerLabel: 'Host-Server-01',  // host-specific: displays hostname below base
  centerYFactor: 0.6,             // optional: vertical center position (default 0.6)
  onPortHover: (int portNum) {},
  onPortHoverExit: () {},
  onPortTap: (int portNum) {},
  onHostHover: () {},
  onHostHoverExit: () {},
  theme: null,  // auto-detects from Theme.of(context).brightness
)
```

### Port Position API

```dart
static Map<int, Offset> HostDeviceView.getPortPositions(
  int portCount,
  Size viewportSize, {
  double centerYFactor = 0.6,
});
```

Synchronous and deterministic — returns the **center** position of each port. Internal widget positioning adjusts to top-left by subtracting half the port size.

`centerYFactor` controls the vertical position of the host center (0.0 = top, 1.0 = bottom). Defaults to 0.6. The standalone package uses a fixed center position — the topology-level `deviceCount`-based adjustment is handled by `device_topology_view` which can pass a custom `centerYFactor`.

### Icon Widget

```dart
HostIconWidget(
  size: 48,           // monitor width; height auto-calculated
  elevation: 5,
  theme: null,        // auto-detects
)
```

### Models

```dart
// Reuse PortStatus from flutter_switch_device or define locally
enum PortStatus { up, down, unknown }
```

**Theme:** Define `HostDeviceTheme` as an independent theme class (packages must be independently publishable — no cross-dependency). It duplicates the switch theme's body/LED colors and adds host-specific screen colors:
- `screenGradientStart` (default `#E2E2E2` for dark, lighter for light theme)
- `screenGradientEnd` (default `#D0D0D0` for dark, lighter for light theme)
- `screenBorderColor` (default `rgba(0,0,0,0.1)`)
- All body/LED colors identical to `SwitchDeviceTheme` for visual consistency.

## Architecture

```
lib/
  flutter_host_device.dart              # barrel export
  src/
    models/
      port_status.dart                  # enum (or reuse from switch package)
      host_device_theme.dart            # theme class (same colors as switch)
    painters/
      host_body_painter.dart            # CustomPainter: monitor + neck + base
      host_icon_painter.dart            # CustomPainter: mini desktop
    widgets/
      host_device_view.dart             # main widget: body + ports in Stack
      host_icon_widget.dart             # icon widget with PhysicalShape
      port_widget.dart                  # single port with hover/tap animation
    layout/
      host_layout.dart                  # semi-elliptical arc calculation
```

### Component Boundaries

- **`host_layout.dart`** — Pure calculation. `portCount` + viewport `Size` → center device position + `Map<int, Offset>` port center positions. No widget dependencies.
- **`host_body_painter.dart`** — Draws monitor + neck + base. Parameterized by theme. No ports.
- **`host_icon_painter.dart`** — Draws miniaturized desktop. Same structure as body painter, scaled down.
- **`port_widget.dart`** — Single port square with hover animation (300ms easeInOut), tap handler, label overlay.
- **`host_device_view.dart`** — Composes body + ports + label in a Stack. Renders label as a `Text` widget positioned below the body. Owns hover/tap state, `getPortPositions()` static method.

### Layout Calculation

```
1. centerSize = min(viewportWidth, viewportHeight) * 0.3
2. hostCenter = (viewportWidth / 2, viewportHeight * centerYFactor)
   — centerYFactor defaults to 0.6; device_topology_view can override based on device count
3. For each port i (1 to portCount):
   — angle = lerp(30°, 150°, (i - 1) / (portCount - 1))
   — special case: portCount == 1 → angle = 90°
   — portX = hostCenter.x + radiusX * cos(angle)
   — portY = hostCenter.y - radiusY * sin(angle)
4. Return Map<int, Offset> of port centers
```

## Integration with device_topology_view

After `flutter_host_device` is complete, `device_topology_view` will:

1. Add `flutter_host_device` as a dependency
2. Replace SVG-based host rendering in `center_device_widget.dart` with `HostDeviceView`
3. Replace `SvgClip` in `host_dev_float.dart` with `HostIconWidget`
4. Call `HostDeviceView.getPortPositions()` for connection line endpoints
5. Remove `assets/images/host_center.svg`, `host_float.svg`, `host_abnormal.svg`, `host_2.svg`
6. Simplify `HostLayoutStrategy` (port positioning now delegated to package)
7. Translate `Map<String, PortStatus>` (topology view's format) to `Map<int, PortStatus>` (package's format) when calling `HostDeviceView`
8. Pass computed `centerYFactor` from `HostLayoutStrategy` (based on device count) to `HostDeviceView`

## Example App

- Dropdown for port count (1, 3, 5, 8, 12)
- Port status randomizer
- Config mode toggle
- Theme mode selector (Dark/Light/Auto)
- Event log showing port hover/tap callbacks
- Icon size showcase (48px, 40px, 30px in halos)
