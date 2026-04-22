import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anti_hook_vpn/anti_hook_vpn_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelAntiHookVpn platform = MethodChannelAntiHookVpn();
  const MethodChannel channel = MethodChannel('anti_hook_vpn');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkSecurity') {
        return <String, bool>{
          'isFridaDetected': false,
          'isProxyOrVpnDetected': false,
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('checkSecurity returns safe status', () async {
    final status = await platform.checkSecurity();
    expect(status.isFridaDetected, false);
    expect(status.isProxyOrVpnDetected, false);
    expect(status.isAttacked, false);
  });
}
