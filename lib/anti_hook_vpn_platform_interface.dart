import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'anti_hook_vpn_method_channel.dart';

abstract class AntiHookVpnPlatform extends PlatformInterface {
  /// Constructs a AntiHookVpnPlatform.
  AntiHookVpnPlatform() : super(token: _token);

  static final Object _token = Object();

  static AntiHookVpnPlatform _instance = MethodChannelAntiHookVpn();

  /// The default instance of [AntiHookVpnPlatform] to use.
  ///
  /// Defaults to [MethodChannelAntiHookVpn].
  static AntiHookVpnPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AntiHookVpnPlatform] when
  /// they register themselves.
  static set instance(AntiHookVpnPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
