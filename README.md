# anti_hook_vpn

[![pub package](https://img.shields.io/pub/v/anti_hook_vpn.svg)](https://pub.dev/packages/anti_hook_vpn)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin that detects **VPN**, **Proxy**, and **Frida** hook framework activity on Android and iOS devices — protecting your app from runtime attack and analysis tools.

---

## Features

| Feature | Android | iOS |
|---|:---:|:---:|
| Frida detection (port scan) | ✅ | ✅ |
| Frida detection (process/dylib injection) | ✅ | ✅ |
| Active VPN detection | ✅ | ✅ |
| System HTTP/HTTPS Proxy detection | ✅ | ✅ |
| Non-dismissible blocking dialog on threat | ✅ | ✅ |

---

## Requirements

- **Android**: minSdk ≥ 24
- **iOS**: iOS ≥ 13.0
- **Flutter**: ≥ 3.3.0
- **Dart**: ≥ 3.0.0

---

## Installation

```yaml
dependencies:
  anti_hook_vpn: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Usage

### 1. Check security and handle the result yourself

```dart
import 'package:anti_hook_vpn/anti_hook_vpn.dart';

Future<void> checkSecurity() async {
  final SecurityStatus status = await AntiHookVpn.checkSecurity();

  if (status.isFridaDetected) {
    print('⚠️ Frida detected!');
  }

  if (status.isProxyOrVpnDetected) {
    print('⚠️ VPN or Proxy detected!');
  }

  if (status.isAttacked) {
    print('🚨 Device is under attack!');
  } else {
    print('✅ Device is secure.');
  }
}
```

### 2. Automatically show a blocking dialog when a threat is detected

The plugin includes a built-in **non-dismissible** dialog (using `PopScope(canPop: false)`) that forces the user to exit the app when a threat is detected.

```dart
import 'package:anti_hook_vpn/anti_hook_vpn.dart';

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSecurityCheck());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check every time the app is resumed
    if (state == AppLifecycleState.resumed) {
      _runSecurityCheck();
    }
  }

  Future<void> _runSecurityCheck() async {
    await AntiHookVpn.checkAndBlockIfNeeded(
      context,
      onAttacked: (status) {
        // Optional callback — e.g. send logs to server
        print('Under attack: $status');
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

---

## API

### `AntiHookVpn.checkSecurity()`

```dart
static Future<SecurityStatus> checkSecurity()
```

Calls the native layer to check for Frida and VPN/Proxy. Throws `PlatformException` if the native call fails.

---

### `AntiHookVpn.checkAndBlockIfNeeded()`

```dart
static Future<void> checkAndBlockIfNeeded(
  BuildContext context, {
  void Function(SecurityStatus status)? onAttacked,
})
```

Performs a security check and automatically shows a non-dismissible blocking dialog if a threat is detected. The user can only tap "Exit App".

---

### `SecurityStatus`

```dart
class SecurityStatus {
  final bool isFridaDetected;       // true if Frida is hooking
  final bool isProxyOrVpnDetected;  // true if a Proxy or VPN is active
  bool get isAttacked;              // true if any threat is detected
}
```

---

## Detection Mechanisms

### Frida

| Technique | Android | iOS |
|---|:---:|:---:|
| TCP connection to known ports | ✅ | ✅ |
| Scan `/proc/self/maps` for `frida-agent` | ✅ | — |
| Scan loaded dylibs in process | — | ✅ |

### VPN

| Technique | Android | iOS |
|---|:---:|:---:|
| `NetworkCapabilities.TRANSPORT_VPN` | ✅ | — |
| `CFNetworkCopySystemProxySettings __SCOPED__` | — | ✅ |

### Proxy

| Technique | Android | iOS |
|---|:---:|:---:|
| `System.getProperty("http.proxyHost")` | ✅ | — |
| `CFNetworkCopySystemProxySettings HTTPEnable/HTTPSEnable` | — | ✅ |

---

## Example

See the [`example/`](https://github.com/hainguyen-ar1/anti_hook_vpn/tree/master/example) directory for a full demo app with a Security Scanner UI.

---

## Contributing

Pull requests are always welcome. Please open an Issue before making large changes.

## License

[MIT](LICENSE)
