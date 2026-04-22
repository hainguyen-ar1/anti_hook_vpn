import Foundation
import Darwin
import MachO
import CFNetwork
import SystemConfiguration

/// Phát hiện Frida và VPN/Proxy trên iOS.
///
/// Tương đương `SecurityDetector.kt` trên Android với các cơ chế phù hợp iOS:
/// - Frida: port check + dylib scan (thay `/proc/self/maps` bằng `_dyld_image` APIs)
/// - VPN: `CFNetworkCopySystemProxySettings` kiểm tra `__SCOPED__` keys
/// - Proxy: `CFNetworkCopySystemProxySettings` kiểm tra `HTTPEnable` / `HTTPSEnable`
enum SecurityDetector {

    // MARK: - Frida Detection

    /// Trả về `true` nếu Frida được phát hiện qua port check hoặc dylib scan.
    static func isFridaDetected() -> Bool {
        return checkFridaPort() || checkFridaInDylibs()
    }

    /// Kết nối tới port Frida mặc định bằng TCP socket.
    ///
    /// Trên localhost, `connect()` trả về ngay lập tức:
    /// - `0` nếu server đang lắng nghe → Frida detected
    /// - `-1` (ECONNREFUSED) nếu không có service → bình thường
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

    /// Quét danh sách dylib đã được nạp vào process hiện tại.
    ///
    /// Đây là cách tương đương đọc `/proc/self/maps` trên Android/Linux.
    /// Frida inject `FridaGadget.dylib` hoặc `frida-agent.dylib` khi hook.
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

    /// Trả về `true` nếu system proxy hoặc VPN đang hoạt động.
    static func isProxyOrVpnDetected() -> Bool {
        return isSystemProxySet() || isVpnActive()
    }

    /// Kiểm tra system proxy đang được bật (HTTP Toolkit, Charles Proxy).
    ///
    /// Sử dụng `CFNetworkCopySystemProxySettings()` — tương đương
    /// `System.getProperty("http.proxyHost")` trên Android.
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

    /// Kiểm tra VPN đang hoạt động thông qua `CFNetworkCopySystemProxySettings`.
    ///
    /// Mọi kết nối VPN trên iOS đều tạo network interface trong `__SCOPED__`
    /// với prefix `tun`, `tap`, `ppp`, `ipsec`, hoặc `utun`.
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
