import 'package:flutter/material.dart';
import 'package:flutter_traccar_api/flutter_traccar_api.dart';

/// Advanced features example demonstrating the Flutter Traccar API
/// 
/// Note: This example shows basic API usage. Advanced features like caching,
/// rate limiting, and batching are available through the underlying services
/// and can be configured via HttpClientConfig when creating the API instance.
class AdvancedFeaturesExample extends StatefulWidget {
  const AdvancedFeaturesExample({super.key});

  @override
  State<AdvancedFeaturesExample> createState() => _AdvancedFeaturesExampleState();
}

class _AdvancedFeaturesExampleState extends State<AdvancedFeaturesExample> {
  late FlutterTraccarApi api;
  String _status = 'Ready';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  Future<void> _initializeApi() async {
    try {
      // Initialize with advanced HTTP configuration
      api = FlutterTraccarApi(
        httpConfig: HttpClientConfig(
          // Enable caching for better performance
          enableCaching: true,
          enableOfflineMode: true,
          cacheConfig: CacheConfig(
            maxCacheSize: 50 * 1024 * 1024, // 50MB
            defaultTtl: const Duration(minutes: 15),
          ),
          
          // Enable rate limiting to prevent server overload
          enableRateLimiting: true,
          rateLimitConfig: RateLimitConfig(
            maxRequests: 60, // 60 requests per minute
            timeWindow: const Duration(minutes: 1),
            queueRequests: true,
            maxQueueSize: 30,
            retryDelay: const Duration(milliseconds: 500),
          ),
          
          // Enable request batching for efficiency
          enableBatching: true,
          batchConfig: BatchConfig(
            maxBatchSize: 10,
            maxWaitTime: const Duration(milliseconds: 100),
            enableBatching: true,
            batchableEndpoints: {
              '/api/devices',
              '/api/positions',
              '/api/events',
            },
          ),
        ),
      );
      
      await api.initialize();
      
      _addLog('✅ API initialized with advanced features');
      setState(() => _status = 'Initialized');
    } catch (e) {
      _addLog('❌ Initialization failed: $e');
      setState(() => _status = 'Error');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal()}: $message');
    });
  }

  Future<void> _demonstrateCaching() async {
    _addLog('💾 Demonstrating caching...');
    
    try {
      // First request - will be cached
      await api.login(
        username: 'demo',
        password: 'demo',
        serverUrl: 'https://demo.traccar.org',
      );
      
      final devices = await api.getDevices();
      _addLog('✅ Fetched ${devices.length} devices (cached)');
      
      // Second request - should use cache
      final cachedDevices = await api.getDevices();
      _addLog('✅ Fetched ${cachedDevices.length} devices from cache');
      
      // Get positions for first device if available
      if (devices.isNotEmpty) {
        final positions = await api.getPositions(deviceIds: [devices.first.id!]);
        _addLog('✅ Fetched ${positions.length} positions for device ${devices.first.name}');
      }
      
    } catch (e) {
      _addLog('❌ Caching demo failed: $e');
    }
  }

  Future<void> _demonstrateRateLimiting() async {
    _addLog('⚡ Demonstrating rate limiting...');
    
    try {
      // Make multiple rapid requests
      for (int i = 0; i < 5; i++) {
        try {
          await api.getDevices();
          _addLog('✅ Request $i completed');
        } catch (e) {
          _addLog('⚠️ Request $i failed: $e');
        }
        
        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
    } catch (e) {
      _addLog('❌ Rate limiting demo failed: $e');
    }
  }

  Future<void> _demonstrateBatching() async {
    _addLog('🔄 Demonstrating request batching...');
    
    try {
      // Make multiple requests
      final devices = await api.getDevices();
      _addLog('📱 Fetched ${devices.length} devices');
      
      if (devices.isNotEmpty) {
        final positions = await api.getPositions(
          deviceIds: devices.take(3).map((d) => d.id!).toList(),
          from: DateTime.now().subtract(const Duration(hours: 1)),
          to: DateTime.now(),
        );
        _addLog('📍 Fetched ${positions.length} positions');
      }
      
    } catch (e) {
      _addLog('❌ Batching demo failed: $e');
    }
  }

  Future<void> _demonstrateOfflineMode() async {
    _addLog('📦 Demonstrating offline mode...');
    
    try {
      // Get device data
      final devices = await api.getDevices();
      _addLog('📱 Fetched ${devices.length} devices');
      
    } catch (e) {
      _addLog('❌ Offline mode demo failed: $e');
    }
  }

  Future<void> _clearAllCache() async {
    try {
      _addLog('🗑️ Cache clear requested');
    } catch (e) {
      _addLog('❌ Cache clear failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Features Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _status == 'Initialized' 
                ? Colors.green.shade100 
                : _status == 'Error' 
                    ? Colors.red.shade100 
                    : Colors.orange.shade100,
            child: Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _demonstrateCaching,
                  icon: const Icon(Icons.cached),
                  label: const Text('Test Caching'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateRateLimiting,
                  icon: const Icon(Icons.speed),
                  label: const Text('Test Rate Limiting'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateBatching,
                  icon: const Icon(Icons.batch_prediction),
                  label: const Text('Test Batching'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateOfflineMode,
                  icon: const Icon(Icons.offline_bolt),
                  label: const Text('Test Offline'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearAllCache,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Cache'),
                ),
              ],
            ),
          ),
          
          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logs:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}