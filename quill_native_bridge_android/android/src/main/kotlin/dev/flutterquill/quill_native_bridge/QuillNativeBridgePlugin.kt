package dev.flutterquill.quill_native_bridge

import android.util.Log
import dev.flutterquill.quill_native_bridge.generated.QuillNativeBridgeApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

class QuillNativeBridgePlugin : FlutterPlugin {
    companion object {
        const val TAG = "QuillNativeBridgePlugin"
    }

    var pluginApi: QuillNativeBridgeImpl? = null
        private set

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val pluginApi = QuillNativeBridgeImpl(binding.applicationContext)
        this.pluginApi = pluginApi
        QuillNativeBridgeApi.setUp(binding.binaryMessenger, pluginApi)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (pluginApi == null) {
            Log.wtf(TAG, "Already detached from the Flutter engine.")
            return
        }

        QuillNativeBridgeApi.setUp(binding.binaryMessenger, null)
        pluginApi = null
    }
}