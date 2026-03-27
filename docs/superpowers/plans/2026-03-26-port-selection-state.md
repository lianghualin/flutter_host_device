# Port Selection State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add port selection state to HostDeviceView — selected ports keep their hover animation forward, unselected ports dim via configurable opacity.

**Architecture:** Two new parameters on `HostDeviceView` (`selectedPortNumbers`, `unselectedPortOpacity`) flow down to `PortWidget` as `isSelected` and `opacity`. PortWidget holds its animation forward when selected (regardless of hover state) and wraps its content in `Opacity`. All selection toggle logic stays in the consumer.

**Tech Stack:** Flutter widgets, AnimationController

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/src/widgets/port_widget.dart` | Modify | Add `isSelected` + `opacity` params, hold animation forward when selected |
| `lib/src/widgets/host_device_view.dart` | Modify | Add `selectedPortNumbers` + `unselectedPortOpacity`, compute per-port props |
| `test/widgets/port_widget_test.dart` | Modify | Tests for isSelected animation hold + opacity dimming |
| `test/widgets/host_device_view_test.dart` | Modify | Tests for selection state flowing to ports |
| `example/lib/main.dart` | Modify | Add spotlight mode toggle to demo |

---

### Task 1: PortWidget — isSelected holds animation forward

**Files:**
- Modify: `test/widgets/port_widget_test.dart`
- Modify: `lib/src/widgets/port_widget.dart`

- [ ] **Step 1: Write failing test — selected port animation is forward**

Add to `test/widgets/port_widget_test.dart`, inside the existing `group('PortWidget', ...)`:

```dart
testWidgets('holds float animation forward when isSelected is true',
    (tester) async {
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      isSelected: true,
    ),
  ));
  // Let animation complete
  await tester.pumpAndSettle();

  // The Transform.translate should have the float offset applied (-3)
  final transform = tester.widget<Transform>(find.byType(Transform));
  expect(transform.transform.getTranslation().y, -3.0);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/port_widget_test.dart --name "holds float animation forward"`
Expected: FAIL — `isSelected` parameter doesn't exist yet.

- [ ] **Step 3: Write failing test — unselected port stays at rest**

Add to `test/widgets/port_widget_test.dart`:

```dart
testWidgets('animation stays at rest when isSelected is false',
    (tester) async {
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      isSelected: false,
    ),
  ));
  await tester.pumpAndSettle();

  final transform = tester.widget<Transform>(find.byType(Transform));
  expect(transform.transform.getTranslation().y, 0.0);
});
```

- [ ] **Step 4: Write failing test — selection change drives animation**

Add to `test/widgets/port_widget_test.dart`:

```dart
testWidgets('toggling isSelected drives animation forward and back',
    (tester) async {
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      isSelected: false,
    ),
  ));
  await tester.pumpAndSettle();

  // Verify at rest
  var transform = tester.widget<Transform>(find.byType(Transform));
  expect(transform.transform.getTranslation().y, 0.0);

  // Select the port
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      isSelected: true,
    ),
  ));
  await tester.pumpAndSettle();

  transform = tester.widget<Transform>(find.byType(Transform));
  expect(transform.transform.getTranslation().y, -3.0);

  // Deselect the port
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      isSelected: false,
    ),
  ));
  await tester.pumpAndSettle();

  transform = tester.widget<Transform>(find.byType(Transform));
  expect(transform.transform.getTranslation().y, 0.0);
});
```

- [ ] **Step 5: Implement isSelected on PortWidget**

Modify `lib/src/widgets/port_widget.dart`:

Add `isSelected` parameter to constructor and field:

```dart
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
    this.onHover,
    this.onHoverExit,
    this.onTap,
  });

  // ... existing fields ...

  /// When true, the hover float animation is held at the forward position
  /// regardless of mouse hover state.
  final bool isSelected;

  // ... rest unchanged ...
}
```

Add `didUpdateWidget` to `_PortWidgetState` to drive animation on selection change:

```dart
@override
void didUpdateWidget(covariant PortWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.isSelected != oldWidget.isSelected) {
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}
```

Update `initState` to respect initial isSelected state:

```dart
@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _floatOffset = Tween<double>(begin: 0, end: -3).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  if (widget.isSelected) {
    _controller.forward();
  }
}
```

Update `onExit` in the `MouseRegion` to not reverse when selected:

```dart
onExit: (_) {
  if (!widget.isSelected) {
    _controller.reverse();
  }
  widget.onHoverExit?.call();
},
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/port_widget_test.dart -v`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add lib/src/widgets/port_widget.dart test/widgets/port_widget_test.dart
git commit -m "feat: add isSelected param to PortWidget for persistent float animation"
```

---

### Task 2: PortWidget — opacity dimming

**Files:**
- Modify: `test/widgets/port_widget_test.dart`
- Modify: `lib/src/widgets/port_widget.dart`

- [ ] **Step 1: Write failing test — opacity applies to port**

Add to `test/widgets/port_widget_test.dart`:

```dart
testWidgets('applies opacity when provided', (tester) async {
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
      opacity: 0.15,
    ),
  ));

  final opacity = tester.widget<Opacity>(find.byType(Opacity));
  expect(opacity.opacity, 0.15);
});
```

- [ ] **Step 2: Write failing test — default opacity is 1.0 (no Opacity widget)**

```dart
testWidgets('does not wrap in Opacity when opacity is 1.0', (tester) async {
  await tester.pumpWidget(wrapInApp(
    PortWidget(
      portNumber: 1,
      position: const Offset(100, 100),
      size: 30,
      status: PortStatus.up,
      theme: theme,
    ),
  ));

  expect(find.byType(Opacity), findsNothing);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/port_widget_test.dart --name "opacity"`
Expected: FAIL — `opacity` parameter doesn't exist yet.

- [ ] **Step 4: Implement opacity on PortWidget**

Add `opacity` parameter to PortWidget constructor and field:

```dart
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
    this.opacity = 1.0,
    this.onHover,
    this.onHoverExit,
    this.onTap,
  });

  // ... existing fields ...

  /// Opacity for the entire port widget. Defaults to 1.0 (fully opaque).
  /// Use values < 1.0 to dim unselected ports in spotlight mode.
  final double opacity;

  // ... rest unchanged ...
}
```

In the `build` method, wrap the `MouseRegion` child of `Positioned` conditionally:

```dart
return Positioned(
  left: widget.position.dx,
  top: widget.position.dy,
  child: _maybeWrapOpacity(
    child: MouseRegion(
      // ... existing code unchanged ...
    ),
  ),
);
```

Add the helper method to `_PortWidgetState`:

```dart
Widget _maybeWrapOpacity({required Widget child}) {
  if (widget.opacity >= 1.0) return child;
  return Opacity(opacity: widget.opacity, child: child);
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/port_widget_test.dart -v`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
git add lib/src/widgets/port_widget.dart test/widgets/port_widget_test.dart
git commit -m "feat: add opacity param to PortWidget for spotlight dimming"
```

---

### Task 3: HostDeviceView — selectedPortNumbers and unselectedPortOpacity

**Files:**
- Modify: `test/widgets/host_device_view_test.dart`
- Modify: `lib/src/widgets/host_device_view.dart`

- [ ] **Step 1: Write failing test — selected port gets isSelected=true**

Add to `test/widgets/host_device_view_test.dart`, inside existing `group('HostDeviceView', ...)`:

```dart
testWidgets('passes isSelected=true to selected ports', (tester) async {
  await tester.pumpWidget(wrapInApp(
    HostDeviceView(
      size: const Size(800, 400),
      portCount: 3,
      selectedPortNumbers: const {2},
    ),
  ));

  final portWidgets = tester.widgetList<PortWidget>(find.byType(PortWidget));
  final port2 = portWidgets.firstWhere((p) => p.portNumber == 2);
  final port1 = portWidgets.firstWhere((p) => p.portNumber == 1);
  expect(port2.isSelected, isTrue);
  expect(port1.isSelected, isFalse);
});
```

You'll need to add this import at the top of the test file:

```dart
import 'package:flutter_host_device/src/widgets/port_widget.dart';
```

- [ ] **Step 2: Write failing test — unselected ports get dimmed opacity**

```dart
testWidgets('dims unselected ports when selection is active',
    (tester) async {
  await tester.pumpWidget(wrapInApp(
    HostDeviceView(
      size: const Size(800, 400),
      portCount: 3,
      selectedPortNumbers: const {2},
      unselectedPortOpacity: 0.15,
    ),
  ));

  final portWidgets = tester.widgetList<PortWidget>(find.byType(PortWidget));
  final port2 = portWidgets.firstWhere((p) => p.portNumber == 2);
  final port1 = portWidgets.firstWhere((p) => p.portNumber == 1);
  expect(port2.opacity, 1.0);
  expect(port1.opacity, 0.15);
});
```

- [ ] **Step 3: Write failing test — no dimming when no selection**

```dart
testWidgets('all ports full opacity when no selection', (tester) async {
  await tester.pumpWidget(wrapInApp(
    HostDeviceView(
      size: const Size(800, 400),
      portCount: 3,
      unselectedPortOpacity: 0.15,
    ),
  ));

  final portWidgets = tester.widgetList<PortWidget>(find.byType(PortWidget));
  for (final port in portWidgets) {
    expect(port.opacity, 1.0);
  }
});
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/host_device_view_test.dart --name "selected|dims|full opacity"`
Expected: FAIL — parameters don't exist.

- [ ] **Step 5: Implement selectedPortNumbers and unselectedPortOpacity on HostDeviceView**

Modify `lib/src/widgets/host_device_view.dart`:

Add to constructor parameters (after `onHostHoverExit`):

```dart
this.selectedPortNumbers = const {},
this.unselectedPortOpacity = 1.0,
```

Add fields:

```dart
/// Port numbers that are currently selected. Selected ports keep their
/// hover float animation at the forward position.
/// Empty set means no selection (all ports at full opacity).
final Set<int> selectedPortNumbers;

/// Opacity applied to ports NOT in [selectedPortNumbers] when the selection
/// is non-empty. Defaults to 1.0 (no dimming). Use ~0.15 for spotlight mode.
final double unselectedPortOpacity;
```

Add a helper method to compute per-port opacity and isSelected. In the `build` method, before building port widgets, add:

```dart
final hasSelection = selectedPortNumbers.isNotEmpty;
```

Then update both port-building loops (override and arc) to pass the new params. For each `PortWidget(...)`:

```dart
PortWidget(
  // ... existing params ...
  isSelected: selectedPortNumbers.contains(entry.key),
  opacity: hasSelection && !selectedPortNumbers.contains(entry.key)
      ? unselectedPortOpacity
      : 1.0,
  // ... existing callbacks ...
)
```

This change applies to **both** the `portPositionOverride` loop and the `portCenters` loop.

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test test/widgets/host_device_view_test.dart -v`
Expected: ALL PASS

- [ ] **Step 7: Run full test suite**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test`
Expected: ALL PASS

- [ ] **Step 8: Commit**

```bash
git add lib/src/widgets/host_device_view.dart test/widgets/host_device_view_test.dart
git commit -m "feat: add selectedPortNumbers and unselectedPortOpacity to HostDeviceView"
```

---

### Task 4: Example app — spotlight mode demo

**Files:**
- Modify: `example/lib/main.dart`

- [ ] **Step 1: Add selection state and spotlight toggle to example**

In `_DemoPageState`, add these fields:

```dart
int? _selectedPort;
bool _spotlightMode = false;
```

- [ ] **Step 2: Add spotlight toggle control to the controls Wrap**

Add after the "Custom labels" Row in the Wrap children:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text('Spotlight'),
    Switch(
      value: _spotlightMode,
      onChanged: (v) => setState(() {
        _spotlightMode = v;
        if (!v) _selectedPort = null;
      }),
    ),
  ],
),
```

- [ ] **Step 3: Update HostDeviceView to use selection**

Update the `HostDeviceView` widget in the builder:

```dart
return HostDeviceView(
  size: viewSize,
  deviceType: _deviceType,
  portCount: _selectedPortCount,
  portStatuses: _portStatuses,
  portLabels: _useCustomLabels ? _customLabels : const {},
  isConfig: _isConfig,
  centerLabel: _centerLabel,
  selectedPortNumbers:
      _selectedPort != null ? {_selectedPort!} : const {},
  unselectedPortOpacity: _spotlightMode && _selectedPort != null ? 0.15 : 1.0,
  onPortHover: (port) => _log('Hover: port $port'),
  onPortHoverExit: () {},
  onPortTap: (port) {
    _log('Tap: port $port');
    if (_spotlightMode) {
      setState(() {
        _selectedPort = _selectedPort == port ? null : port;
      });
    }
  },
  onHostHover: () {},
  onHostHoverExit: () {},
);
```

- [ ] **Step 4: Clear selection when port count or scenario changes**

Update `_switchScenario` to also clear selection:

```dart
void _switchScenario(_Scenario scenario) {
  setState(() {
    _scenario = scenario;
    _selectedPortCount = _portCounts.contains(_selectedPortCount)
        ? _selectedPortCount
        : _portCounts.last;
    _portStatuses = {};
    _selectedPort = null;
  });
}
```

Update the port count dropdown `onChanged` similarly:

```dart
onChanged: (v) => setState(() {
  _selectedPortCount = v!;
  _portStatuses = {};
  _selectedPort = null;
}),
```

- [ ] **Step 5: Verify example runs**

Run: `cd /Users/hualinliang/Project/flutter_host_device/example && flutter run -d chrome --web-port=8080`
Manual check: Toggle "Spotlight" on, tap a port — it floats up persistently, other ports dim.

- [ ] **Step 6: Commit**

```bash
git add example/lib/main.dart
git commit -m "feat: add spotlight mode demo to example app"
```

---

### Task 5: Export verification and full test pass

**Files:**
- Read: `lib/flutter_host_device.dart`

- [ ] **Step 1: Verify no new exports needed**

The new parameters are on existing exported classes (`HostDeviceView`, `PortWidget`). No new files were created, so `lib/flutter_host_device.dart` needs no changes. Verify by reading the file.

- [ ] **Step 2: Run full test suite**

Run: `cd /Users/hualinliang/Project/flutter_host_device && flutter test`
Expected: ALL PASS

- [ ] **Step 3: Run dart analyze**

Run: `cd /Users/hualinliang/Project/flutter_host_device && dart analyze`
Expected: No issues found.

- [ ] **Step 4: Run dart format check**

Run: `cd /Users/hualinliang/Project/flutter_host_device && dart format --set-exit-if-changed .`
Expected: No formatting issues.

- [ ] **Step 5: Final commit if any fixes were needed**

Only if previous steps required changes:
```bash
git add -A
git commit -m "chore: fix lint/format issues from port selection feature"
```
