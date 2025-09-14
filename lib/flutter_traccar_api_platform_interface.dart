import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_traccar_api_method_channel.dart';

abstract class FlutterTraccarApiPlatform extends PlatformInterface {
  /// Constructs a FlutterTraccarApiPlatform.
  FlutterTraccarApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTraccarApiPlatform _instance = MethodChannelFlutterTraccarApi();

  /// The default instance of [FlutterTraccarApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTraccarApi].
  static FlutterTraccarApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTraccarApiPlatform] when
  /// they register themselves.
  static set instance(FlutterTraccarApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
