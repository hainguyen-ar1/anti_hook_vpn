import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'anti_hook_vpn_platform_interface.dart';

/// An implementation of [AntiHookVpnPlatform] that uses method channels.
class MethodChannelAntiHookVpn extends AntiHookVpnPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('anti_hook_vpn');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
