package com.example.flutter_media_writer

import android.media.MediaFormat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.ByteBuffer


/** FlutterMediaWriterPlugin */
class FlutterMediaWriterPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var mediaMuxerWrapper: MediaMuxerWrapper

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_media_writer")
        channel.setMethodCallHandler(this)
        mediaMuxerWrapper = MediaMuxerWrapper();
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method.equals("prepare")) {
            val outputPath = call.argument<String>("outputPath")
            val width = call.argument<Int>("width")
            val height = call.argument<Int>("height")
            android.util.Log.d(TAG, "onMethodCall: $outputPath")
            mediaMuxerWrapper.prepare(outputPath!!, width!!, height!!)
        } else if (call.method.equals("encode")) {
            val byteBuf = call.argument<ByteArray>("byteBuf") as ByteArray
            mediaMuxerWrapper.encode(
                byteBuf
            )
        } else if (call.method.equals("stop")) {
            mediaMuxerWrapper.stop()
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "MediaWriter"
    }
}
