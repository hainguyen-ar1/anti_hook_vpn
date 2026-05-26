import Foundation
import Darwin
import MachO
import CFNetwork
import SystemConfiguration

/// Detects Frida and VPN/Proxy on iOS.
///
/// Equivalent to `SecurityDetector.kt` on Android with iOS-specific mechanisms:
/// - Frida: port check + dylib scan (uses `_dyld_image` APIs instead of `/proc/self/maps`)
/// - VPN: `CFNetworkCopySystemProxySettings` checking `__SCOPED__` keys
/// - Proxy: `CFNetworkCopySystemProxySettings` checking `HTTPEnable` / `HTTPSEnable`
enum SecurityDetector {

    // MARK: - Frida Detection

    /// Returns `true` if Frida is detected via port check or dylib scan.
    static func isFridaDetected() -> Bool {
        return checkFridaPort() || checkFridaInDylibs()
    }

    /// Connects to the default Frida port using a TCP socket.
    ///
    /// On localhost, `connect()` returns immediately:
    /// - `0` if a server is listening → Frida detected
    /// - `-1` (ECONNREFUSED) if no service → normal
    private static func checkFridaPort() -> Bool {
        let fridaPorts: [UInt16] = [27042, 27043]
        return fridaPorts.contains { isPortOpen(port: $0) }
    }

    private static func isPortOpen(port: UInt16) -> Bool {
        let sockFd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        guard sockFd >= 0 else { return false }
        defer { close(sockFd) }

        var addr = sockaddr_in()
        memset(&addr, 0, MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(sockFd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        return result == 0
    }

    /// Scans the list of dylibs loaded into the current process.
    ///
    /// This is the iOS equivalent of reading `/proc/self/maps` on Android/Linux.
    /// Frida injects `FridaGadget.dylib` or `frida-agent.dylib` when hooking.
    private static func checkFridaInDylibs() -> Bool {
        let fridaPatterns = ["frida", "frida-agent", "libfrida", "frida-gadget", "re.frida"]
        let imageCount = _dyld_image_count()
        for i in 0..<imageCount {
            guard let namePtr = _dyld_get_image_name(i) else { continue }
            let name = String(cString: namePtr).lowercased()
            if fridaPatterns.contains(where: { name.contains($0) }) {
                return true
            }
        }
        return false
    }

    // MARK: - VPN / Proxy Detection

    /// Returns `true` if a system proxy or VPN is active.
    static func isProxyOrVpnDetected() -> Bool {
        return isSystemProxySet() || isVpnActive()
    }

    /// Checks whether a system proxy is enabled (e.g. HTTP Toolkit, Charles Proxy).
    ///
    /// Uses `CFNetworkCopySystemProxySettings()` — equivalent to
    /// `System.getProperty("http.proxyHost")` on Android.
    private static func isSystemProxySet() -> Bool {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue()
                as? [String: Any] else { return false }

        let httpEnabled = (proxySettings["HTTPEnable"] as? Int) == 1
        let httpsEnabled = (proxySettings["HTTPSEnable"] as? Int) == 1
        let httpProxy = proxySettings["HTTPProxy"] as? String
        let httpsProxy = proxySettings["HTTPSProxy"] as? String

        if httpEnabled && !(httpProxy?.isEmpty ?? true) { return true }
        if httpsEnabled && !(httpsProxy?.isEmpty ?? true) { return true }
        return false
    }

    /// Checks for an active VPN via `CFNetworkCopySystemProxySettings`.
    ///
    /// All VPN connections on iOS create a network interface under `__SCOPED__`
    /// with prefixes like `tun`, `tap`, `ppp`, `ipsec`, or `utun`.
    private static func isVpnActive() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let scopedDict = nsDict["__SCOPED__"] as? NSDictionary else { return false }

        let vpnPrefixes = ["tun", "tap", "ppp", "ipsec", "utun"]
        for key in scopedDict.allKeys {
            if let keyString = key as? String,
               vpnPrefixes.contains(where: { keyString.hasPrefix($0) }) {
                return true
            }
        }
        return false
    }
}
