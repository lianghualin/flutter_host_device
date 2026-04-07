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

enum _Scenario { host, agent }

class _DemoPageState extends State<DemoPage> {
  _Scenario _scenario = _Scenario.host;
  int _selectedPortCount = 5;
  Map<int, PortStatus> _portStatuses = {};
  bool _isConfig = false;
  bool _useCustomLabels = false;
  final List<String> _eventLog = [];
  int? _selectedPort;
  bool _spotlightMode = false;
  bool _enableHoverAnimation = true;
  bool _showPortIconText = true;
  bool _showPortLabels = true;

  static const _hostPortCounts = [1, 2, 3, 4, 5, 6];
  static const _agentPortCounts = [1, 2];

  static const _hostLabels = {
    1: 'eth0',
    2: 'eth1',
    3: 'MGMT',
    4: 'HA',
    5: 'iLO',
    6: 'SAN',
  };

  static const _agentLabels = {1: 'NETA', 2: 'NETB'};

  List<int> get _portCounts =>
      _scenario == _Scenario.host ? _hostPortCounts : _agentPortCounts;

  Map<int, String> get _customLabels =>
      _scenario == _Scenario.host ? _hostLabels : _agentLabels;

  TopoDeviceType get _deviceType =>
      _scenario == _Scenario.host ? TopoDeviceType.host : TopoDeviceType.agent;

  String get _centerLabel =>
      _scenario == _Scenario.host ? 'Host-Server-01' : 'Agent-DPU-01';

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
                SegmentedButton<_Scenario>(
                  segments: const [
                    ButtonSegment(value: _Scenario.host, label: Text('Host')),
                    ButtonSegment(value: _Scenario.agent, label: Text('Agent')),
                  ],
                  selected: {_scenario},
                  onSelectionChanged: (s) => _switchScenario(s.first),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedPortCount,
                  items: _portCounts
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c, child: Text('$c ports')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedPortCount = v!;
                    _portStatuses = {};
                    _selectedPort = null;
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hover anim'),
                    Switch(
                      value: _enableHoverAnimation,
                      onChanged: (v) =>
                          setState(() => _enableHoverAnimation = v),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Icon text'),
                    Switch(
                      value: _showPortIconText,
                      onChanged: (v) => setState(() => _showPortIconText = v),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Port labels'),
                    Switch(
                      value: _showPortLabels,
                      onChanged: (v) => setState(() => _showPortLabels = v),
                    ),
                  ],
                ),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                  ],
                  selected: {widget.themeMode},
                  onSelectionChanged: (s) => widget.onThemeModeChanged(s.first),
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
                    deviceType: _deviceType,
                    portCount: _selectedPortCount,
                    portStatuses: _portStatuses,
                    portLabels: _useCustomLabels ? _customLabels : const {},
                    isConfig: _isConfig,
                    centerLabel: _centerLabel,
                    selectedPortNumbers: _selectedPort != null
                        ? {_selectedPort!}
                        : const {},
                    unselectedPortOpacity:
                        _spotlightMode && _selectedPort != null ? 0.15 : 1.0,
                    enablePortHoverAnimation: _enableHoverAnimation,
                    showPortIconText: _showPortIconText,
                    showPortLabels: _showPortLabels,
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
                const Text(
                  'Event Log',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView(
                    children: _eventLog
                        .map(
                          (e) => Text(
                            e,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        )
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
