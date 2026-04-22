import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'anti_hook_vpn_method_channel.dart';
import 'security_status.dart';

/// Platform interface cho [AntiHookVpn].
abstract class AntiHookVpnPlatform extends PlatformInterface {
  AntiHookVpnPlatform() : super(token: _token);

  static final Object _token = Object();

  static AntiHookVpnPlatform _instance = MethodChannelAntiHookVpn();

  /// Instance mặc định, sử dụng [MethodChannelAntiHookVpn].
  static AntiHookVpnPlatform get instance => _instance;

  static set instance(AntiHookVpnPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gọi native để kiểm tra Frida và VPN/Proxy.
  Future<SecurityStatus> checkSecurity() {
    throw UnimplementedError('checkSecurity() has not been implemented.');
  }
}
