# flutter_host_device

A Flutter widget that renders host and agent (DPU) devices with ports arranged in a semi-elliptical arc. Fully programmatic — no SVG assets required. Uses [topology_view_icons](https://pub.dev/packages/topology_view_icons) for device and port rendering.

## Features

- Programmatic host/agent device rendering with configurable device type icons
- Interactive RJ45 port icons (LNM hardware style) with hover animation and status LED (link up / down / disabled)
- Semi-elliptical port arc layout (dynamic port count, no presets needed)
- On-body port placement via `portPositionOverride` for devices with built-in ports
- Configurable port size for different device form factors
- Dark and light theme support with auto-detection
- Custom port labels and replaceable center device
- Port selection state with spotlight mode — selected ports stay visually active, unselected ports dim
- `getPortPositions()` API for consumers drawing connection lines
- Supports all device types: host, agent, router, server, switch, firewall, etc.

## Getting started

Add the dependency:

```yaml
dependencies:
  flutter_host_device: ^0.3.0
```

## Usage

### Host device

```dart
import 'package:flutter_host_device/flutter_host_device.dart';

HostDeviceView(
  size: Size(800, 400),
  portCount: 6,
  portStatuses: {1: PortStatus.up, 2: PortStatus.down, 3: PortStatus.up},
  centerLabel: 'Host-Server-01',
  onPortTap: (portNum) => print('Tapped port $portNum'),
)
```

### Agent (DPU) device

```dart
HostDeviceView(
  size: Size(800, 400),
  deviceType: TopoDeviceType.agent,
  portCount: 2,
  portLabels: {1: 'NETA', 2: 'NETB'},
  centerLabel: 'Agent-DPU-01',
  onPortTap: (portNum) => print('Tapped port $portNum'),
)
```

### Custom port labels

```dart
HostDeviceView(
  portCount: 4,
  portLabels: {1: 'eth0', 2: 'eth1', 3: 'MGMT', 4: 'iLO'},
  // ...
)
```

### Different device type icons

```dart
HostDeviceView(
  deviceType: TopoDeviceType.router,  // or .server, .switch_, .firewall, etc.
  // ...
)
```

### Custom center device

```dart
HostDeviceView(
  centerDeviceBuilder: (context, size, theme) {
    return Image.asset('assets/my_custom_host.png', fit: BoxFit.contain);
  },
  // ...
)
```

### On-body port placement

For devices where ports are physically on the device body (e.g., agent/DPU):

```dart
HostDeviceView(
  deviceType: TopoDeviceType.agent,
  portCount: 2,
  portSize: 18,
  portPositionOverride: {
    1: Offset(0.39, 0.67),  // NETA position (normalized)
    2: Offset(0.39, 0.77),  // NETB position (normalized)
  },
  portLabels: {1: 'NETA', 2: 'NETB'},
  // ...
)
```

### Port selection / spotlight mode

Tap a port to select it — the selected port stays visually active while others dim:

```dart
// In a StatefulWidget:
int? _selectedPort;

HostDeviceView(
  size: Size(800, 400),
  portCount: 6,
  selectedPortNumbers: _selectedPort != null ? {_selectedPort!} : {},
  unselectedPortOpacity: _selectedPort != null ? 0.15 : 1.0,
  onPortTap: (port) => setState(() {
    _selectedPort = _selectedPort == port ? null : port;
  }),
)
```

### Get port positions for drawing connection lines

```dart
final positions = HostDeviceView.getPortPositions(6, Size(800, 400));
// {1: Offset(x, y), 2: Offset(x, y), ...}
```

## Additional information

- [GitHub Repository](https://github.com/lianghualin/flutter_host_device)
- [Issue Tracker](https://github.com/lianghualin/flutter_host_device/issues)
- Part of the device topology view family: [flutter_switch_device](https://pub.dev/packages/flutter_switch_device), [topology_view_icons](https://pub.dev/packages/topology_view_icons)
