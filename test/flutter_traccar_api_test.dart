import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_traccar_api/flutter_traccar_api.dart';
import 'package:flutter_traccar_api/flutter_traccar_api_platform_interface.dart';
import 'package:flutter_traccar_api/flutter_traccar_api_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTraccarApiPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTraccarApiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterTraccarApiPlatform initialPlatform = FlutterTraccarApiPlatform.instance;

  test('$MethodChannelFlutterTraccarApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTraccarApi>());
  });

  test('getPlatformVersion', () async {
    FlutterTraccarApi flutterTraccarApiPlugin = FlutterTraccarApi();
    MockFlutterTraccarApiPlatform fakePlatform = MockFlutterTraccarApiPlatform();
    FlutterTraccarApiPlatform.instance = fakePlatform;

    expect(await flutterTraccarApiPlugin.getPlatformVersion(), '42');
  });
}
