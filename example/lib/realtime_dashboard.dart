import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_traccar_api/flutter_traccar_api.dart';

/// Real-time dashboard that demonstrates WebSocket functionality
/// 
/// This screen shows live updates for devices, positions, and events
/// using WebSocket connections to the Traccar server.
class RealtimeDashboard extends StatefulWidget {
  final FlutterTraccarApi api;

  const RealtimeDashboard({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<RealtimeDashboard> createState() => _RealtimeDashboardState();
}

class _RealtimeDashboardState extends State<RealtimeDashboard>
    with TickerProviderStateMixin {
  
  // Data lists
  List<Device> _devices = [];
  List<Position> _positions = [];
  List<Event> _events = [];
  
  // Connection state
  WebSocketStatus _connectionStatus = WebSocketStatus.disconnected;
  bool _isLoading = true;
  String? _error;
  
  // Stream subscriptions
  StreamSubscription<List<Device>>? _devicesSubscription;
  StreamSubscription<List<Position>>? _positionsSubscription;
  StreamSubscription<List<Event>>? _eventsSubscription;
  StreamSubscription<WebSocketStatus>? _statusSubscription;
  
  // Tab controller
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeRealtime();
  }

  Future<void> _initializeRealtime() async {
    try {
      // Load initial data
      final devices = await widget.api.getDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      }

      // Connect to WebSocket
      await _connectWebSocket();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to initialize: $e';
        });
        _showError('Failed to initialize: $e');
      }
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      // Subscribe to streams before connecting
      _devicesSubscription = widget.api.deviceUpdatesStream.listen(
        (devices) {
          if (mounted) {
            setState(() => _devices = devices);
          }
        },
        onError: (error) => _showError('Device stream error: $error'),
      );

      _positionsSubscription = widget.api.positionUpdatesStream.listen(
        (positions) {
          if (mounted) {
            setState(() {
              _positions = positions;
              // Note: Device updates will come through the device stream
              // so we don't need to manually update devices here
            });
          }
        },
        onError: (error) => _showError('Position stream error: $error'),
      );

      _eventsSubscription = widget.api.eventUpdatesStream.listen(
        (events) {
          if (mounted) {
            setState(() => _events = [...events, ..._events].take(50).toList());
          }
        },
        onError: (error) => _showError('Event stream error: $error'),
      );

      _statusSubscription = widget.api.webSocketStatusStream.listen(
        (status) {
          if (mounted) {
            setState(() => _connectionStatus = status);
          }
        },
      );

      // Connect to WebSocket
      final connected = await widget.api.connectWebSocket();
      if (!connected) {
        _showError('Failed to connect to WebSocket');
      }
    } catch (e) {
      _showError('WebSocket connection error: $e');
    }
  }

  Future<void> _disconnectWebSocket() async {
    await _devicesSubscription?.cancel();
    await _positionsSubscription?.cancel();
    await _eventsSubscription?.cancel();
    await _statusSubscription?.cancel();
    
    await widget.api.disconnectWebSocket();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _disconnectWebSocket();
    await widget.api.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Real-time Dashboard - ${widget.api.currentUsername ?? 'User'}'),
            const SizedBox(width: 8),
            _buildConnectionIndicator(),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_connectionStatus == WebSocketStatus.connected
                ? Icons.wifi_off
                : Icons.wifi),
            onPressed: _connectionStatus == WebSocketStatus.connected
                ? _disconnectWebSocket
                : _connectWebSocket,
            tooltip: _connectionStatus == WebSocketStatus.connected
                ? 'Disconnect'
                : 'Connect',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.devices), text: 'Devices'),
            Tab(icon: Icon(Icons.location_on), text: 'Positions'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.info), text: 'Status'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDevicesTab(),
                _buildPositionsTab(),
                _buildEventsTab(),
                _buildStatusTab(),
              ],
            ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color color;
    IconData icon;
    String tooltip;

    switch (_connectionStatus) {
      case WebSocketStatus.connected:
        color = Colors.green;
        icon = Icons.circle;
        tooltip = 'Connected';
        break;
      case WebSocketStatus.connecting:
        color = Colors.orange;
        icon = Icons.circle;
        tooltip = 'Connecting...';
        break;
      case WebSocketStatus.reconnecting:
        color = Colors.yellow;
        icon = Icons.circle;
        tooltip = 'Reconnecting...';
        break;
      case WebSocketStatus.error:
        color = Colors.red;
        icon = Icons.error;
        tooltip = 'Connection Error';
        break;
      case WebSocketStatus.disconnected:
      default:
        color = Colors.grey;
        icon = Icons.circle;
        tooltip = 'Disconnected';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 12),
    );
  }

  Widget _buildDevicesTab() {
    if (_devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No devices found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: device.status == 'online'
                  ? Colors.green
                  : Colors.grey,
              child: const Icon(Icons.device_hub, color: Colors.white),
            ),
            title: Text(device.name ?? 'Unknown Device'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${device.status ?? 'Unknown'}'),
                if (device.lastUpdate != null)
                  Text('Last Update: ${_formatDateTime(device.lastUpdate!)}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show device details in a dialog
              _showDeviceDetails(device);
            },
          ),
        );
      },
    );
  }

  Widget _buildPositionsTab() {
    if (_positions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No position updates yet'),
            SizedBox(height: 8),
            Text(
              'Position updates will appear here in real-time',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final position = _positions[index];
        final device = _devices.firstWhere(
          (d) => d.id == position.deviceId,
          orElse: () => Device(name: 'Unknown Device'),
        );

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.location_on, color: Colors.white),
            ),
            title: Text(device.name ?? 'Unknown Device'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lat: ${position.latitude?.toStringAsFixed(6) ?? 'N/A'}'),
                Text('Lng: ${position.longitude?.toStringAsFixed(6) ?? 'N/A'}'),
                if (position.speed != null)
                  Text('Speed: ${position.speed!.toStringAsFixed(1)} km/h'),
                if (position.deviceTime != null)
                  Text('Time: ${position.deviceTime}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No events yet'),
            SizedBox(height: 8),
            Text(
              'Events will appear here in real-time',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final device = _devices.firstWhere(
          (d) => d.id == event.deviceId,
          orElse: () => Device(name: 'Unknown Device'),
        );

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEventColor(event.type),
              child: const Icon(Icons.event, color: Colors.white),
            ),
            title: Text(event.type ?? 'Unknown Event'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device: ${device.name ?? 'Unknown'}'),
                if (event.eventTime != null)
                  Text('Time: ${event.eventTime}'),
                if (event.attributes != null)
                  Text('Attributes: ${event.attributes?.toJson()}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow('WebSocket Status', _connectionStatus.name),
                  _buildStatusRow('Connected', widget.api.isWebSocketConnected.toString()),
                   _buildStatusRow('Username', widget.api.currentUsername ?? 'Not logged in'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-time Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow('Devices', _devices.length.toString()),
                  _buildStatusRow('Recent Positions', _positions.length.toString()),
                  _buildStatusRow('Recent Events', _events.length.toString()),
                  _buildStatusRow('Online Devices', 
                    _devices.where((d) => d.status == 'online').length.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name ?? 'Unknown Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.id ?? 'N/A'}'),
            Text('Unique ID: ${device.uniqueId ?? 'N/A'}'),
            Text('Status: ${device.status ?? 'N/A'}'),
            if (device.lastUpdate != null)
              Text('Last Update: ${_formatDateTime(device.lastUpdate!)}'),
            if (device.phone != null)
              Text('Phone: ${device.phone}'),
            if (device.model != null)
              Text('Model: ${device.model}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'deviceonline':
        return Colors.green;
      case 'deviceoffline':
        return Colors.red;
      case 'devicemoving':
        return Colors.blue;
      case 'devicestopped':
        return Colors.orange;
      case 'alarm':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _tabController.dispose();
    super.dispose();
  }
}