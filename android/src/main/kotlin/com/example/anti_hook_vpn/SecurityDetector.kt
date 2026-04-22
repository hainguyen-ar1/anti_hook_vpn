package com.example.anti_hook_vpn

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.net.InetSocketAddress
import java.net.Socket

object SecurityDetector {

    @JvmStatic
    fun isFridaDetected(): Boolean {
        return checkFridaPort() || checkFridaInMaps()
    }

    /**
     * Kết nối tới port Frida mặc định bằng client Socket (không phải ServerSocket).
     * Nếu kết nối thành công → có service đang lắng nghe → Frida có thể đang chạy.
     * Dùng client Socket tránh false positive do SELinux chặn việc bind port.
     */
    private fun checkFridaPort(): Boolean {
        val fridaPorts = intArrayOf(27042, 27043)
        for (port in fridaPorts) {
            var socket: Socket? = null
            try {
                socket = Socket()
                socket.connect(InetSocketAddress("127.0.0.1", port), 100)
                // Kết nối thành công → có server đang lắng nghe trên port này
                android.util.Log.w("SecurityDetector", "⚠️ [FRIDA] Port $port is OPEN — something is listening!")
                return true
            } catch (e: Exception) {
                android.util.Log.d("SecurityDetector", "✅ Port $port closed (${e.javaClass.simpleName})")
            } finally {
                try {
                    socket?.close()
                } catch (e: Exception) {
                    // Bỏ qua lỗi đóng
                }
            }
        }
        return false
    }

    /**
     * Kiểm tra /proc/self/maps để phát hiện Frida được inject vào process.
     */
    private fun checkFridaInMaps(): Boolean {
        val fridaPatterns = listOf("frida", "frida-agent", "libfrida", "frida-gadget", "re.frida")
        try {
            val mapsFile = File("/proc/self/maps")
            if (mapsFile.exists()) {
                BufferedReader(FileReader(mapsFile)).use { reader ->
                    var line: String? = reader.readLine()
                    while (line != null) {
                        val lower = line.lowercase()
                        if (fridaPatterns.any { lower.contains(it) }) {
                            android.util.Log.w("SecurityDetector", "⚠️ [FRIDA] Suspicious maps entry: $line")
                            return true
                        }
                        line = reader.readLine()
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("SecurityDetector", "❌ Cannot read /proc/self/maps: ${e.message}")
        }
        return false
    }


    @JvmStatic
    fun isProxyOrVpnDetected(context: Context): Boolean {
        return isSystemProxySet() || isVpnActive(context)
    }

    /**
     * Kiểm tra proxy hệ thống (HTTP Toolkit, Charles Proxy thiết lập Proxy trên Android).
     */
    private fun isSystemProxySet(): Boolean {
        val proxyHost = System.getProperty("http.proxyHost")
        return !proxyHost.isNullOrEmpty()
    }

    /**
     * Kiểm tra VPN đang hoạt động qua NetworkCapabilities (API 24+, tương thích minSdkVersion).
     */
    private fun isVpnActive(context: Context): Boolean {
        return try {
            val connectivityManager =
                context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val activeNetwork = connectivityManager.activeNetwork ?: return false
            val networkCapabilities =
                connectivityManager.getNetworkCapabilities(activeNetwork) ?: return false
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
        } catch (e: Exception) {
            false
        }
    }
}
