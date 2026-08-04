package dev.flutterquill.quill_native_bridge

import android.app.Application
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.verifyNoMoreInteractions
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class QuillNativeBridgePluginTest {
    private lateinit var mockApplication: Application
    private lateinit var mockFlutterPluginBinding: FlutterPluginBinding
    private lateinit var mockBinaryMessenger: BinaryMessenger

    private lateinit var plugin: QuillNativeBridgePlugin

    @BeforeTest
    fun setup() {
        mockApplication = mock()
        mockBinaryMessenger = mock()
        mockFlutterPluginBinding =
            mock {
                on { applicationContext }.thenReturn(mockApplication)
                on { binaryMessenger }.thenReturn(mockBinaryMessenger)
            }
        plugin = QuillNativeBridgePlugin()
    }

    @Test
    fun `The log tag is correct`() {
        assertEquals("QuillNativeBridgePlugin", QuillNativeBridgePlugin.TAG)
    }

    @Test
    fun `onAttachedToEngine sets up the plugin API`() {
        assertNull(plugin.pluginApi, "The plugin API is null initially")

        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        verify(mockFlutterPluginBinding).binaryMessenger
        verify(mockFlutterPluginBinding).applicationContext
        verifyNoMoreInteractions(mockFlutterPluginBinding)

        assertNotNull(plugin.pluginApi, "The plugin API should be not null after the attach")
    }

    @Test
    fun `onDetachedFromEngine tears down the plugin API`() {
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onDetachedFromEngine(mockFlutterPluginBinding)

        verify(mockFlutterPluginBinding, times(2)).binaryMessenger
        verify(mockFlutterPluginBinding).applicationContext
        verifyNoMoreInteractions(mockFlutterPluginBinding)

        assertNull(plugin.pluginApi, "The plugin API should be null after the detach")
    }
}