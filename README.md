# anti_hook_vpn

[![pub package](https://img.shields.io/pub/v/anti_hook_vpn.svg)](https://pub.dev/packages/anti_hook_vpn)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Flutter plugin phát hiện **VPN**, **Proxy** và **Frida** hook framework đang hoạt động trên thiết bị Android và iOS — giúp bảo vệ ứng dụng khỏi các công cụ tấn công và phân tích runtime.

---

## Tính năng

| Tính năng | Android | iOS |
|---|:---:|:---:|
| Phát hiện Frida (port scan) | ✅ | ✅ |
| Phát hiện Frida (process/dylib injection) | ✅ | ✅ |
| Phát hiện VPN đang hoạt động | ✅ | ✅ |
| Phát hiện HTTP/HTTPS Proxy hệ thống | ✅ | ✅ |
| Dialog chặn không tắt được khi bị tấn công | ✅ | ✅ |

---

## Yêu cầu hệ thống

- **Android**: minSdk ≥ 24
- **iOS**: iOS ≥ 13.0
- **Flutter**: ≥ 3.3.0
- **Dart**: ≥ 3.0.0

---

## Cài đặt

```yaml
dependencies:
  anti_hook_vpn: ^1.0.0
```

Sau đó chạy:

```bash
flutter pub get
```

### Quyền Android

Thêm vào `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Sử dụng

### 1. Kiểm tra bảo mật và tự xử lý kết quả

```dart
import 'package:anti_hook_vpn/anti_hook_vpn.dart';

Future<void> checkSecurity() async {
  final SecurityStatus status = await AntiHookVpn.checkSecurity();

  if (status.isFridaDetected) {
    print('⚠️ Phát hiện Frida đang chạy!');
  }

  if (status.isProxyOrVpnDetected) {
    print('⚠️ Phát hiện VPN hoặc Proxy!');
  }

  if (status.isAttacked) {
    print('🚨 Thiết bị đang bị tấn công!');
  } else {
    print('✅ Thiết bị an toàn.');
  }
}
```

### 2. Tự động hiện dialog chặn khi phát hiện tấn công

Plugin có sẵn một dialog **không thể tắt** (dùng `PopScope(canPop: false)`), buộc người dùng phải thoát ứng dụng khi phát hiện mối đe dọa.

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
    // Kiểm tra lại mỗi khi app được resume
    if (state == AppLifecycleState.resumed) {
      _runSecurityCheck();
    }
  }

  Future<void> _runSecurityCheck() async {
    await AntiHookVpn.checkAndBlockIfNeeded(
      context,
      onAttacked: (status) {
        // Callback tuỳ chọn — ví dụ: gửi log lên server
        print('Bị tấn công: $status');
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

Gọi native để kiểm tra Frida và VPN/Proxy. Ném `PlatformException` nếu không thể gọi native.

---

### `AntiHookVpn.checkAndBlockIfNeeded()`

```dart
static Future<void> checkAndBlockIfNeeded(
  BuildContext context, {
  void Function(SecurityStatus status)? onAttacked,
})
```

Kiểm tra bảo mật và tự động hiện dialog chặn toàn bộ tương tác nếu phát hiện mối đe dọa. Người dùng chỉ có thể bấm "Thoát Ứng Dụng".

---

### `SecurityStatus`

```dart
class SecurityStatus {
  final bool isFridaDetected;       // true nếu Frida đang hook
  final bool isProxyOrVpnDetected;  // true nếu có Proxy hoặc VPN
  bool get isAttacked;              // true nếu bất kỳ mối đe dọa nào được phát hiện
}
```

---

## Cơ chế phát hiện

### Frida

| Kỹ thuật | Android | iOS |
|---|:---:|:---:|
| Kết nối TCP tới port | ✅ | ✅ |
| Quét `/proc/self/maps` tìm `frida-agent` | ✅ | — |
| Quét danh sách dylib nạp vào process | — | ✅ |

### VPN

| Kỹ thuật | Android | iOS |
|---|:---:|:---:|
| `NetworkCapabilities.TRANSPORT_VPN` | ✅ | — |
| `CFNetworkCopySystemProxySettings __SCOPED__` | — | ✅ |

### Proxy

| Kỹ thuật | Android | iOS |
|---|:---:|:---:|
| `System.getProperty("http.proxyHost")` | ✅ | — |
| `CFNetworkCopySystemProxySettings HTTPEnable/HTTPSEnable` | — | ✅ |

---

## Ví dụ

Xem thư mục [`example/`](https://github.com/hainguyen-ar1/anti_hook_vpn/tree/master/example) để chạy app demo đầy đủ với Security Scanner UI.

---

## Đóng góp

Pull requests luôn được chào đón. Vui lòng mở Issue trước khi thực hiện thay đổi lớn.

## License

[MIT](LICENSE)
