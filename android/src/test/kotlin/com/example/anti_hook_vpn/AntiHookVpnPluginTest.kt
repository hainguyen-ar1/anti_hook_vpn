package com.example.anti_hook_vpn

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class AntiHookVpnPluginTest {
    @Test
    fun onMethodCall_checkSecurity_returnsExpectedValue() {
        val plugin = AntiHookVpnPlugin()

        val call = MethodCall("checkSecurity", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        // Context is null at this point so we expect an error response
        Mockito.verify(mockResult).error("NO_CONTEXT", "Application context not available", null)
    }
}
