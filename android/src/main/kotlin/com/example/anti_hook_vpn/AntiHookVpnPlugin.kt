package com.example.anti_hook_vpn

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/// Flutter plugin entry point cho Android.
///
/// Implements [ActivityAware] để có thể lấy [Context] cần thiết cho
/// [SecurityDetector.isVpnActive] (dùng [ConnectivityManager]).
class AntiHookVpnPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null

    // ─── FlutterPlugin ───────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "anti_hook_vpn")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
    }

    // ─── MethodCallHandler ───────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkSecurity" -> {
                val ctx = applicationContext
                if (ctx == null) {
                    result.error("NO_CONTEXT", "Application context not available", null)
                    return
                }
                val isFrida = SecurityDetector.isFridaDetected()
                val isProxyVpn = SecurityDetector.isProxyOrVpnDetected(ctx)
                result.success(
                    mapOf(
                        "isFridaDetected" to isFrida,
                        "isProxyOrVpnDetected" to isProxyVpn,
                    )
                )
            }
            else -> result.notImplemented()
        }
    }

    // ─── ActivityAware ───────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        applicationContext = binding.activity.applicationContext
    }

    override fun onDetachedFromActivityForConfigChanges() = Unit

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        applicationContext = binding.activity.applicationContext
    }

    override fun onDetachedFromActivity() {
        applicationContext = null
    }
}
