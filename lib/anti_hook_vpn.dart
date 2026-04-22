import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'anti_hook_vpn_platform_interface.dart';
import 'security_status.dart';

export 'security_status.dart';

/// Public API của plugin `anti_hook_vpn`.
///
/// Cung cấp hai cách sử dụng:
/// 1. [checkSecurity] — kiểm tra và trả về [SecurityStatus] để tự xử lý.
/// 2. [checkAndBlockIfNeeded] — kiểm tra và tự động hiện dialog block nếu bị tấn công.
class AntiHookVpn {
  AntiHookVpn._();

  static bool _isDialogShowing = false;

  /// Gọi native để kiểm tra Frida và VPN/Proxy.
  ///
  /// Throws [PlatformException] nếu không gọi được native.
  static Future<SecurityStatus> checkSecurity() =>
      AntiHookVpnPlatform.instance.checkSecurity();

  /// Kiểm tra bảo mật và hiện dialog không tắt được nếu phát hiện tấn công.
  ///
  /// Dialog chặn toàn bộ tương tác; người dùng chỉ có thể thoát app.
  /// Hàm này thường được gọi trong `initState` và khi app resume.
  ///
  /// [onAttacked] — callback tùy chọn, được gọi trước khi dialog hiện.
  static Future<void> checkAndBlockIfNeeded(
    BuildContext context, {
    void Function(SecurityStatus status)? onAttacked,
  }) async {
    try {
      final status = await checkSecurity();

      if (!status.isAttacked) {
        debugPrint('✅ AntiHookVpn: Security check passed.');
        return;
      }

      onAttacked?.call(status);

      if (!_isDialogShowing && context.mounted) {
        _isDialogShowing = true;
        _showBlockingDialog(context, _buildMessage(status));
      }
    } on PlatformException catch (e) {
      debugPrint('❌ AntiHookVpn: Native call failed — ${e.message}');
    }
  }

  // ─── Internals ────────────────────────────────────────────────────────────

  static String _buildMessage(SecurityStatus status) {
    if (status.isFridaDetected) {
      return 'Phát hiện phần mềm can thiệp hệ thống bộ nhớ runtime (Frida/Xposed). '
          'Vui lòng gỡ bỏ công cụ root/cheat!';
    }
    return 'Kết nối mạng không an toàn. '
        'Phát hiện thiết bị đang dùng Proxy hoặc VPN trung gian.';
  }

  static void _showBlockingDialog(BuildContext context, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Cảnh báo Bảo Mật',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => exit(0),
              child: const Text('Thoát Ứng Dụng'),
            ),
          ],
        ),
      ),
    );
  }
}
