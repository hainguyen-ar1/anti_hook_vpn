import 'package:flutter_test/flutter_test.dart';
import 'package:anti_hook_vpn/anti_hook_vpn.dart';
import 'package:anti_hook_vpn/anti_hook_vpn_platform_interface.dart';
import 'package:anti_hook_vpn/anti_hook_vpn_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAntiHookVpnPlatform
    with MockPlatformInterfaceMixin
    implements AntiHookVpnPlatform {
  @override
  Future<SecurityStatus> checkSecurity() async => SecurityStatus.safe;
}

void main() {
  final AntiHookVpnPlatform initialPlatform = AntiHookVpnPlatform.instance;

  test('$MethodChannelAntiHookVpn is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAntiHookVpn>());
  });

  test('checkSecurity returns SecurityStatus', () async {
    final MockAntiHookVpnPlatform fakePlatform = MockAntiHookVpnPlatform();
    AntiHookVpnPlatform.instance = fakePlatform;

    final status = await AntiHookVpn.checkSecurity();
    expect(status.isFridaDetected, false);
    expect(status.isProxyOrVpnDetected, false);
    expect(status.isAttacked, false);
  });
}
