import 'package:flutter_test/flutter_test.dart';
import 'package:anti_hook_vpn/anti_hook_vpn.dart';
import 'package:anti_hook_vpn/anti_hook_vpn_platform_interface.dart';
import 'package:anti_hook_vpn/anti_hook_vpn_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAntiHookVpnPlatform
    with MockPlatformInterfaceMixin
    implements AntiHookVpnPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AntiHookVpnPlatform initialPlatform = AntiHookVpnPlatform.instance;

  test('$MethodChannelAntiHookVpn is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAntiHookVpn>());
  });

  test('getPlatformVersion', () async {
    AntiHookVpn antiHookVpnPlugin = AntiHookVpn();
    MockAntiHookVpnPlatform fakePlatform = MockAntiHookVpnPlatform();
    AntiHookVpnPlatform.instance = fakePlatform;

    expect(await antiHookVpnPlugin.getPlatformVersion(), '42');
  });
}
