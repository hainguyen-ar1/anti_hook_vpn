import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'anti_hook_vpn_platform_interface.dart';
import 'security_status.dart';

export 'security_status.dart';

/// Public API for the `anti_hook_vpn` plugin.
///
/// Provides two usage patterns:
/// 1. [checkSecurity] — check and return a [SecurityStatus] for custom handling.
/// 2. [checkAndBlockIfNeeded] — check and automatically show a blocking dialog if attacked.
class AntiHookVpn {
  AntiHookVpn._();

  static bool _isDialogShowing = false;

  /// Calls the native layer to check for Frida and VPN/Proxy.
  ///
  /// Throws [PlatformException] if the native call fails.
  static Future<SecurityStatus> checkSecurity() =>
      AntiHookVpnPlatform.instance.checkSecurity();

  /// Performs a security check and shows a non-dismissible dialog if a threat is detected.
  ///
  /// The dialog blocks all interaction; the user can only exit the app.
  /// Typically called in `initState` and when the app resumes.
  ///
  /// [onAttacked] — optional callback invoked before the dialog is shown.
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
      return 'Runtime memory hooking tool detected (Frida/Xposed). '
          'Please remove root/cheat tools from your device!';
    }
    return 'Insecure network connection detected. '
        'Your device is using an intercepting Proxy or VPN.';
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
                'Security Warning',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => exit(0),
              child: const Text('Exit App'),
            ),
          ],
        ),
      ),
    );
  }
}
