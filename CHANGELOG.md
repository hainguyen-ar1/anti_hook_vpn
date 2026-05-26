## 1.0.3

* Translate all documentation, comments, and UI strings to English for broader international adoption.
* Lower minimum SDK constraint from Dart 3.5.0 to Dart 2.18.0 (Flutter 3.3.0+) for wider project compatibility.
* Replace `PopScope` with `WillPopScope` to support older Flutter versions.
* Replace `context.mounted` check with try-catch for backward compatibility with Flutter < 3.7.

## 1.0.0

* Initial release.
* Detect Frida hooking framework via TCP port scan  and `/proc/self/maps` inspection (Android) or dylib scan (iOS).
* Detect active VPN connections using `NetworkCapabilities.TRANSPORT_VPN` (Android) and `CFNetworkCopySystemProxySettings __SCOPED__` keys (iOS).
* Detect system-level HTTP/HTTPS proxy set by tools such as HTTP Toolkit or Charles Proxy.
* `AntiHookVpn.checkSecurity()` — returns a `SecurityStatus` with individual flags for Frida and VPN/Proxy.
* `AntiHookVpn.checkAndBlockIfNeeded()` — shows an un-dismissible blocking dialog and forces app exit when a threat is detected.
* Supports Android (minSdk 24+) and iOS (13.0+).
