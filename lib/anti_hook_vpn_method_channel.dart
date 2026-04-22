import 'package:flutter/services.dart';

import 'anti_hook_vpn_platform_interface.dart';
import 'security_status.dart';

/// Implementation của [AntiHookVpnPlatform] dùng [MethodChannel].
class MethodChannelAntiHookVpn extends AntiHookVpnPlatform {
  final MethodChannel methodChannel = const MethodChannel('anti_hook_vpn');

  @override
  Future<SecurityStatus> checkSecurity() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'checkSecurity',
    );
    if (result == null) return SecurityStatus.safe;
    return SecurityStatus.fromMap(result);
  }
}
