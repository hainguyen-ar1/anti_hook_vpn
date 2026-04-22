## 1.0.0

* Initial release.
* Detect Frida hooking framework via TCP port scan  and `/proc/self/maps` inspection (Android) or dylib scan (iOS).
* Detect active VPN connections using `NetworkCapabilities.TRANSPORT_VPN` (Android) and `CFNetworkCopySystemProxySettings __SCOPED__` keys (iOS).
* Detect system-level HTTP/HTTPS proxy set by tools such as HTTP Toolkit or Charles Proxy.
* `AntiHookVpn.checkSecurity()` — returns a `SecurityStatus` with individual flags for Frida and VPN/Proxy.
* `AntiHookVpn.checkAndBlockIfNeeded()` — shows an un-dismissible blocking dialog and forces app exit when a threat is detected.
* Supports Android (minSdk 24+) and iOS (13.0+).
