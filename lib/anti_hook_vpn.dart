
import 'anti_hook_vpn_platform_interface.dart';

class AntiHookVpn {
  Future<String?> getPlatformVersion() {
    return AntiHookVpnPlatform.instance.getPlatformVersion();
  }
}
