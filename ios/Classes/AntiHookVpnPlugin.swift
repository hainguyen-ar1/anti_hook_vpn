import Flutter
import UIKit

/// Flutter plugin entry point for iOS.
///
/// Handles the `anti_hook_vpn` MethodChannel and delegates detection logic
/// to [SecurityDetector].
public class AntiHookVpnPlugin: NSObject, FlutterPlugin {

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "anti_hook_vpn",
            binaryMessenger: registrar.messenger()
        )
        let instance = AntiHookVpnPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method Handling

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkSecurity":
            let isFrida = SecurityDetector.isFridaDetected()
            let isProxyOrVpn = SecurityDetector.isProxyOrVpnDetected()
            result([
                "isFridaDetected": isFrida,
                "isProxyOrVpnDetected": isProxyOrVpn,
            ])
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
