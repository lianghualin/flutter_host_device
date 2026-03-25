# flutter_host_device

A Flutter widget that renders host devices with ports arranged in a semi-elliptical arc. Fully programmatic — no SVG assets required. Uses [topology_view_icons](https://pub.dev/packages/topology_view_icons) for device and port rendering.

## Features

- Programmatic host device rendering with configurable device type icons
- Interactive RJ45 port icons with hover animation and status colors (link up / down / disabled)
- Semi-elliptical port arc layout (dynamic port count, no presets needed)
- Dark and light theme support with auto-detection
- Custom port labels and replaceable center device
- `getPortPositions()` API for consumers drawing connection lines
- Stacked switch, router, server, and other device types via `TopoDeviceType`

## Getting started

Add the dependency:

```yaml
dependencies:
  flutter_host_device: ^0.1.0
```

## Usage

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

### Get port positions for drawing connection lines

```dart
final positions = HostDeviceView.getPortPositions(6, Size(800, 400));
// {1: Offset(x, y), 2: Offset(x, y), ...}
```

## Additional information

- [GitHub Repository](https://github.com/lianghualin/flutter_host_device)
- [Issue Tracker](https://github.com/lianghualin/flutter_host_device/issues)
- Part of the device topology view family: [flutter_switch_device](https://pub.dev/packages/flutter_switch_device), [topology_view_icons](https://pub.dev/packages/topology_view_icons)
