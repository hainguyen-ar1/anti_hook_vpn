import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:anti_hook_vpn/anti_hook_vpn.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkSecurity returns a SecurityStatus', (WidgetTester tester) async {
    final status = await AntiHookVpn.checkSecurity();
    // Result is always a valid bool — no exception thrown
    expect(status.isFridaDetected, isA<bool>());
    expect(status.isProxyOrVpnDetected, isA<bool>());
  });
}
