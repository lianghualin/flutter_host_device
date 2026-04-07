## 0.3.2

- **Breaking:** Split label controls into `showPortIconText` (tight text on/near port icon) and `showPortLabels` (external label below port with background pill)
- External port labels rendered as separate positioned widgets with semi-transparent background pill for improved readability in topology layouts
- Add `showPortIconText` parameter to independently hide illegible icon text at small port sizes
- Add icon text toggle to example app

## 0.3.1

- Add `enablePortHoverAnimation` parameter to disable port hover float animation
- Add `portLabelStyle` parameter for custom port label text styling
- Add `portLabelBackgroundDecoration` parameter to customize the label background pill
- Add semi-transparent background pill behind port labels for improved readability
- Add hover animation and port label toggles to example app

## 0.3.0

- Add `selectedPortNumbers` parameter for port selection state
- Add `unselectedPortOpacity` parameter for spotlight dimming of unselected ports
- Selected ports keep hover float animation at the forward position
- Add `isSelected` and `opacity` parameters to `PortWidget`
- Add spotlight mode demo to example app
- 75 tests

## 0.2.0

- Add Agent (DPU) scenario support with `TopoDeviceType.agent`
- Add `portPositionOverride` parameter for on-body port placement
- Add `portSize` parameter for custom port icon sizing
- Add Host/Agent scenario toggle in example app
- Agent uses NETA/NETB port labels with semi-elliptical arc layout
- Upgrade `topology_view_icons` to 1.2.1 (adds `TopoPortPainter`)
- Replace custom `PortPainter` with `TopoPortPainter` (LNM style RJ45 icons)
- Increase default port size from 30px to 45px for better RJ45 icon readability
- Move port labels below icon instead of overlapping
- Re-export `TopoPortPainter` from barrel file

## 0.1.0

- Initial release
- Host device view with semi-elliptical port arc layout
- Center device rendering using topology_view_icons (LNM style)
- RJ45 port icons with link up/down/disabled states
- Dark and light theme support with auto-detection
- Host floating icon widget (monitor + neck + base silhouette)
- Custom port labels and replaceable center device builder
- Static `getPortPositions()` API for connection line drawing
- Configurable `deviceType` parameter (host, router, server, etc.)
- 66 tests
