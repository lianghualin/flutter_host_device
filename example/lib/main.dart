import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_host_device/flutter_host_device.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_host_device demo',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: DemoPage(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _portCounts = [1, 2, 3, 4, 5, 6];

  int _selectedPortCount = 5;
  Map<int, PortStatus> _portStatuses = {};
  bool _isConfig = false;
  bool _useCustomLabels = false;
  final List<String> _eventLog = [];

  static const _customLabels = {
    1: 'eth0',
    2: 'eth1',
    3: 'MGMT',
    4: 'HA',
    5: 'iLO',
    6: 'SAN',
  };

  void _randomizeStatuses() {
    final rng = Random();
    final statuses = <int, PortStatus>{};
    for (int i = 1; i <= _selectedPortCount; i++) {
      statuses[i] = PortStatus.values[rng.nextInt(PortStatus.values.length)];
    }
    setState(() => _portStatuses = statuses);
  }

  void _log(String event) {
    setState(() {
      _eventLog.insert(0, event);
      if (_eventLog.length > 20) _eventLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_host_device demo')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedPortCount,
                  items: _portCounts
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('$c ports'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedPortCount = v!;
                    _portStatuses = {};
                  }),
                ),
                ElevatedButton(
                  onPressed: _randomizeStatuses,
                  child: const Text('Randomize statuses'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Config'),
                    Switch(
                      value: _isConfig,
                      onChanged: (v) => setState(() => _isConfig = v),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Custom labels'),
                    Switch(
                      value: _useCustomLabels,
                      onChanged: (v) => setState(() => _useCustomLabels = v),
                    ),
                  ],
                ),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('Auto')),
                  ],
                  selected: {widget.themeMode},
                  onSelectionChanged: (s) =>
                      widget.onThemeModeChanged(s.first),
                ),
              ],
            ),
          ),

          // Host device view
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewSize = Size(
                    constraints.maxWidth.clamp(400, 1200),
                    constraints.maxHeight.clamp(200, 800),
                  );
                  return HostDeviceView(
                    size: viewSize,
                    portCount: _selectedPortCount,
                    portStatuses: _portStatuses,
                    portLabels: _useCustomLabels ? _customLabels : const {},
                    isConfig: _isConfig,
                    centerLabel: 'Host-Server-01',
                    onPortHover: (port) => _log('Hover: port $port'),
                    onPortHoverExit: () {},
                    onPortTap: (port) => _log('Tap: port $port'),
                    onHostHover: () {},
                    onHostHoverExit: () {},
                  );
                },
              ),
            ),
          ),

          // Event log
          Container(
            height: 120,
            width: double.infinity,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade100,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event Log',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: _eventLog
                        .map((e) => Text(e,
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace')))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
