/// Kết quả kiểm tra bảo mật trả về từ native layer.
class SecurityStatus {
  const SecurityStatus({
    required this.isFridaDetected,
    required this.isProxyOrVpnDetected,
  });

  /// `true` nếu Frida hoặc công cụ hook tương tự đang chạy.
  final bool isFridaDetected;

  /// `true` nếu hệ thống đang có Proxy hoặc VPN hoạt động.
  final bool isProxyOrVpnDetected;

  /// `true` nếu bất kỳ mối đe dọa nào được phát hiện.
  bool get isAttacked => isFridaDetected || isProxyOrVpnDetected;

  /// Tạo từ map trả về qua MethodChannel.
  factory SecurityStatus.fromMap(Map<dynamic, dynamic> map) => SecurityStatus(
        isFridaDetected: map['isFridaDetected'] == true,
        isProxyOrVpnDetected: map['isProxyOrVpnDetected'] == true,
      );

  /// Trạng thái an toàn mặc định (không có mối đe dọa).
  static const SecurityStatus safe = SecurityStatus(
    isFridaDetected: false,
    isProxyOrVpnDetected: false,
  );

  @override
  String toString() =>
      'SecurityStatus(frida: $isFridaDetected, proxyOrVpn: $isProxyOrVpnDetected)';
}
