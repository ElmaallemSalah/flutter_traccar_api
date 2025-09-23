# 🚗 Flutter Traccar API

<div align="center">

[![pub package](https://img.shields.io/pub/v/flutter_traccar_api.svg?style=for-the-badge&color=blue)](https://pub.dev/packages/flutter_traccar_api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg?style=for-the-badge&logo=dart)](https://dart.dev)

**A powerful, feature-rich Flutter package for seamless integration with Traccar GPS tracking servers**

[📖 Documentation](#-documentation) • [🚀 Quick Start](#-quick-start) • [💡 Examples](#-examples) • [🤝 Contributing](#-contributing)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔐 **Authentication & Security**
- ✅ Secure login/logout with credential caching
- ✅ Encrypted storage using `flutter_secure_storage`
- ✅ Automatic session management
- ✅ Token-based authentication

### 📱 **Device Management**
- ✅ Retrieve and manage GPS tracking devices
- ✅ Real-time device status monitoring
- ✅ Device configuration and settings
- ✅ Bulk device operations

</td>
<td width="50%">

### 📍 **Position Tracking**
- ✅ Real-time position updates
- ✅ Historical position data
- ✅ Geofence monitoring
- ✅ Route optimization

### 📊 **Advanced Reporting**
- ✅ Trip analysis and reports
- ✅ Stop detection and analysis
- ✅ Summary statistics
- ✅ Distance calculations

</td>
</tr>
</table>

### 🚀 **Performance & Optimization**

| Feature | Description | Benefits |
|---------|-------------|----------|
| 🧠 **Intelligent Caching** | Smart cache management with TTL | Faster responses, offline support |
| ⚡ **Rate Limiting** | Built-in API rate limiting | Prevents server overload |
| 🔄 **Request Batching** | Automatic request optimization | Improved performance |
| 📦 **Offline Mode** | Cache-based offline functionality | Works without internet |
| 🏗️ **Type Safety** | Full OpenAPI-generated models | Compile-time error checking |

---

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_traccar_api: ^1.0.0
  # Required for secure storage
  flutter_secure_storage: ^9.0.0
  # Required for caching
  shared_preferences: ^2.2.0
```

Then run:

```bash
flutter pub get
```

### 🔧 Platform Setup

<details>
<summary><b>📱 Android Setup</b></summary>

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

</details>

<details>
<summary><b>🍎 iOS Setup</b></summary>

No additional setup required for iOS.

</details>

<details>
<summary><b>🌐 Web Setup</b></summary>

Ensure your Traccar server supports CORS for web applications.

</details>

---

## 🚀 Quick Start

### 1️⃣ Initialize the API

```dart
import 'package:flutter_traccar_api/flutter_traccar_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🎯 Basic initialization
  await FlutterTraccarApi.initialize('https://your-traccar-server.com');
  
  // 🚀 Advanced initialization with performance features
  await FlutterTraccarApi.initialize(
    'https://your-traccar-server.com',
    config: HttpClientConfig(
      enableCaching: true,
      enableRateLimiting: true,
      enableBatching: true,
      enableOfflineMode: true,
      cacheConfig: CacheConfig(
        maxCacheSize: 50 * 1024 * 1024, // 50MB
        defaultTtl: Duration(minutes: 15),
        enableCompression: true,
      ),
      rateLimitConfig: RateLimitConfig(
        requestsPerSecond: 10,
        burstSize: 20,
        enableBackoff: true,
      ),
    ),
  );
  
  runApp(MyApp());
}
```

### 2️⃣ Authentication

```dart
class AuthService {
  final api = FlutterTraccarApi.instance;

  Future<bool> login(String username, String password) async {
    try {
      final user = await api.login(username, password);
      print('✅ Logged in as: ${user.name}');
      return true;
    } on TraccarApiException catch (e) {
      print('❌ Login failed: ${e.message}');
      return false;
    }
  }

  Future<void> logout() async {
    await api.logout();
    print('👋 Logged out successfully');
  }

  Future<bool> isLoggedIn() async {
    return await api.isAuthenticated();
  }
}
```

### 3️⃣ Device Management

```dart
class DeviceService {
  final api = FlutterTraccarApi.instance;

  Future<List<Device>> getAllDevices() async {
    try {
      final devices = await api.getDevices();
      print('📱 Found ${devices.length} devices');
      return devices;
    } catch (e) {
      print('❌ Error fetching devices: $e');
      return [];
    }
  }

  Future<Device?> getDeviceById(int deviceId) async {
    try {
      return await api.getDevice(deviceId);
    } catch (e) {
      print('❌ Device not found: $e');
      return null;
    }
  }
}
```

### 4️⃣ Position Tracking

```dart
class PositionService {
  final api = FlutterTraccarApi.instance;

  Future<List<Position>> getRecentPositions(int deviceId) async {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    
    return await api.getPositions(
      deviceId: deviceId,
      from: yesterday,
      to: now,
    );
  }

  Future<Position?> getLatestPosition(int deviceId) async {
    final positions = await getRecentPositions(deviceId);
    return positions.isNotEmpty ? positions.first : null;
  }
}
```

---

## 💡 Examples

### 🎯 Complete Flutter App Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_traccar_api/flutter_traccar_api.dart';

class TraccarDashboard extends StatefulWidget {
  @override
  _TraccarDashboardState createState() => _TraccarDashboardState();
}

class _TraccarDashboardState extends State<TraccarDashboard> {
  final api = FlutterTraccarApi.instance;
  List<Device> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final fetchedDevices = await api.getDevices();
      setState(() {
        devices = fetchedDevices;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load devices: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🚗 Traccar Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No devices found'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return DeviceCard(device: device);
                  },
                ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.status == 'online' ? Colors.green : Colors.red,
          child: Icon(Icons.gps_fixed, color: Colors.white),
        ),
        title: Text(device.name ?? 'Unknown Device'),
        subtitle: Text('ID: ${device.id} • Status: ${device.status}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailPage(device: device),
            ),
          );
        },
      ),
    );
  }
}
```

### 📊 Advanced Reporting Example

```dart
class ReportService {
  final api = FlutterTraccarApi.instance;

  Future<Map<String, dynamic>> generateComprehensiveReport(
    List<int> deviceIds,
    DateTime from,
    DateTime to,
  ) async {
    try {
      // 🚗 Get trip reports
      final trips = await api.getTripReports(
        deviceIds: deviceIds,
        from: from,
        to: to,
      );

      // 📊 Get summary reports
      final summaries = await api.getSummaryReports(
        deviceIds: deviceIds,
        from: from,
        to: to,
      );

      // 🛑 Get stop reports
      final stops = await api.getStopReports(
        deviceIds: deviceIds,
        from: from,
        to: to,
      );

      return {
        'trips': trips,
        'summaries': summaries,
        'stops': stops,
        'totalDistance': summaries.fold<double>(
          0,
          (sum, summary) => sum + (summary.distance ?? 0),
        ),
        'totalDuration': trips.fold<Duration>(
          Duration.zero,
          (sum, trip) => sum + (trip.duration ?? Duration.zero),
        ),
      };
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }
}
```

### 🔄 Real-time Position Tracking

```dart
class RealTimeTracker {
  final api = FlutterTraccarApi.instance;
  Timer? _timer;
  final StreamController<List<Position>> _positionController = 
      StreamController<List<Position>>.broadcast();

  Stream<List<Position>> get positionStream => _positionController.stream;

  void startTracking(List<int> deviceIds, {Duration interval = const Duration(seconds: 30)}) {
    _timer = Timer.periodic(interval, (_) async {
      try {
        final positions = await api.getPositions(
          deviceIds: deviceIds,
          from: DateTime.now().subtract(Duration(minutes: 5)),
          to: DateTime.now(),
        );
        _positionController.add(positions);
      } catch (e) {
        print('❌ Error fetching positions: $e');
      }
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
```

---

## 🎛️ Advanced Configuration

### 🧠 Cache Management

```dart
// Get cache statistics
final stats = await api.getCacheStats();
print('📊 Cache Stats:');
print('  Size: ${(stats.totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
print('  Hit Rate: ${stats.hitRate.toStringAsFixed(1)}%');
print('  Entries: ${stats.entryCount}');

// Clear specific caches
await api.invalidateDeviceCache();
await api.invalidatePositionCache();

// Clear all cache
await api.clearCache();
```

### ⚡ Rate Limiting

```dart
// Check rate limit status
final status = api.getRateLimitStatus();
if (status != null) {
  print('⚡ Rate Limit Status:');
  print('  Remaining: ${status.remainingRequests}');
  print('  Reset: ${status.resetTime}');
  print('  Limit: ${status.requestLimit}');
}

// Reset rate limiter
api.resetRateLimit();
```

### 🔄 Request Batching

```dart
// Get batching statistics
final batchStats = api.getBatchingStats();
if (batchStats != null) {
  print('🔄 Batch Stats:');
  print('  Total Batches: ${batchStats.totalBatches}');
  print('  Avg Size: ${batchStats.averageBatchSize.toStringAsFixed(1)}');
  print('  Pending: ${batchStats.pendingRequests}');
}

// Flush pending batches
await api.flushAllBatches();
```

---

## 🛠️ API Reference

<details>
<summary><b>🔐 Authentication Methods</b></summary>

```dart
// Login with credentials
Future<User> login(String email, String password);

// Logout and clear session
Future<void> logout();

// Check authentication status
Future<bool> isAuthenticated();

// Get current username
Future<String?> currentUsername();

// Check for cached credentials
Future<bool> hasCachedCredentials();
```

</details>

<details>
<summary><b>📱 Device Management</b></summary>

```dart
// Get all devices
Future<List<Device>> getDevices();

// Get specific device
Future<Device> getDevice(int deviceId);

// Get device with caching
Future<List<Device>> getDevicesCached();
```

</details>

<details>
<summary><b>📍 Position Tracking</b></summary>

```dart
// Get positions with filters
Future<List<Position>> getPositions({
  int? deviceId,
  List<int>? deviceIds,
  DateTime? from,
  DateTime? to,
});

// Get latest positions
Future<List<Position>> getLatestPositions(List<int> deviceIds);
```

</details>

<details>
<summary><b>📊 Reporting</b></summary>

```dart
// Trip reports
Future<List<TripReport>> getTripReports({
  required List<int> deviceIds,
  required DateTime from,
  required DateTime to,
});

// Summary reports
Future<List<SummaryReport>> getSummaryReports({
  required List<int> deviceIds,
  required DateTime from,
  required DateTime to,
});

// Stop reports
Future<List<StopReport>> getStopReports({
  required List<int> deviceIds,
  required DateTime from,
  required DateTime to,
});

// Distance reports
Future<List<ReportDistance>> getDistanceReports({
  required List<int> deviceIds,
  required DateTime from,
  required DateTime to,
});
```

</details>

---

## 🏗️ Architecture

```
flutter_traccar_api/
├── 📁 lib/
│   ├── 📄 flutter_traccar_api.dart          # Public API
│   └── 📁 src/
│       ├── 📁 models/                       # Data models
│       │   ├── 📄 device.dart
│       │   ├── 📄 position.dart
│       │   ├── 📄 user.dart
│       │   └── 📄 ...
│       ├── 📁 services/                     # Core services
│       │   ├── 📄 auth_manager.dart         # Authentication
│       │   ├── 📄 http_service.dart         # HTTP client
│       │   ├── 📄 cache_manager.dart        # Caching
│       │   ├── 📄 rate_limiter.dart         # Rate limiting
│       │   └── 📄 request_batcher.dart      # Request batching
│       ├── 📁 exceptions/                   # Error handling
│       └── 📁 utils/                        # Utilities
├── 📁 example/                              # Example app
└── 📁 test/                                 # Unit tests
```

---

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/auth_manager_test.dart
```

### 🎯 Test Coverage

- ✅ Authentication flows
- ✅ Device management
- ✅ Position tracking
- ✅ Report generation
- ✅ Error handling
- ✅ Cache management
- ✅ Rate limiting
- ✅ Request batching

---

## 📋 Requirements

| Component | Version |
|-----------|---------|
| 🎯 Dart SDK | `>=3.0.0 <4.0.0` |
| 📱 Flutter | `>=3.0.0` |
| 🖥️ Traccar Server | `>=5.0` |

### 📦 Dependencies

```yaml
dependencies:
  dio: ^5.3.0                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Secure storage
  shared_preferences: ^2.2.0     # Local storage
  crypto: ^3.0.3                 # Cryptographic functions
  intl: ^0.18.0                  # Internationalization
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🚀 Getting Started

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/yourusername/flutter_traccar_api.git`
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes
5. **Test** your changes: `flutter test`
6. **Commit** your changes: `git commit -m 'Add amazing feature'`
7. **Push** to the branch: `git push origin feature/amazing-feature`
8. **Open** a Pull Request

### 📝 Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Write tests for new features
- Update documentation for API changes
- Use conventional commit messages

### 🐛 Reporting Issues

Found a bug? Please [open an issue](https://github.com/yourusername/flutter_traccar_api/issues) with:

- 📱 Flutter version
- 📦 Package version
- 🔍 Steps to reproduce
- 📋 Expected vs actual behavior

---

## 📚 Documentation

- 📖 [API Documentation](https://pub.dev/documentation/flutter_traccar_api)
- 🎯 [Traccar API Reference](https://www.traccar.org/api-reference/)
- 📱 [Flutter Documentation](https://flutter.dev/docs)

---

## 🆘 Support

Need help? We're here for you!

- 💬 [GitHub Discussions](https://github.com/yourusername/flutter_traccar_api/discussions)
- 🐛 [Issue Tracker](https://github.com/yourusername/flutter_traccar_api/issues)
- 📧 [Email Support](mailto:support@yourcompany.com)
- 💬 [Discord Community](https://discord.gg/your-invite)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- 🚗 [Traccar](https://www.traccar.org/) - Open source GPS tracking system
- 📱 [Flutter Team](https://flutter.dev/) - Amazing cross-platform framework
- 🎯 [Dart Team](https://dart.dev/) - Powerful programming language
- 🤝 All our [contributors](https://github.com/yourusername/flutter_traccar_api/graphs/contributors)

---

<div align="center">

**Made with ❤️ by the Flutter community**

⭐ **Star this repo if it helped you!** ⭐

</div>
