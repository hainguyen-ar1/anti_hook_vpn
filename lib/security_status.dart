/// Security check result returned from the native layer.
class SecurityStatus {
  const SecurityStatus({
    required this.isFridaDetected,
    required this.isProxyOrVpnDetected,
  });

  /// `true` if Frida or a similar hooking tool is running.
  final bool isFridaDetected;

  /// `true` if a system Proxy or VPN is active.
  final bool isProxyOrVpnDetected;

  /// `true` if any threat is detected.
  bool get isAttacked => isFridaDetected || isProxyOrVpnDetected;

  /// Creates an instance from the map returned via MethodChannel.
  factory SecurityStatus.fromMap(Map<dynamic, dynamic> map) => SecurityStatus(
        isFridaDetected: map['isFridaDetected'] == true,
        isProxyOrVpnDetected: map['isProxyOrVpnDetected'] == true,
      );

  /// Default safe status (no threats detected).
  static const SecurityStatus safe = SecurityStatus(
    isFridaDetected: false,
    isProxyOrVpnDetected: false,
  );

  @override
  String toString() =>
      'SecurityStatus(frida: $isFridaDetected, proxyOrVpn: $isProxyOrVpnDetected)';
}
