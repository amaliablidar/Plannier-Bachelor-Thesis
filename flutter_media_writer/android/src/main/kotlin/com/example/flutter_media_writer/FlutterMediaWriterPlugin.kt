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
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mediaMuxerWrapper: MediaMuxerWrapper

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_media_writer")
        channel.setMethodCallHandler(this)
        mediaMuxerWrapper = MediaMuxerWrapper();
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        print("onMethodCall ${call.method}")
        if (call.method.equals("prepare")) {
            val outputPath = call.argument<String>("outputPath")
            android.util.Log.d(TAG, "onMethodCall: $outputPath")
            mediaMuxerWrapper.prepare(outputPath!!)
        } else if (call.method.equals("start")) {
            mediaMuxerWrapper.start()
        } else if (call.method.equals("encode")) {
            print("BYTE 1")
            val byteBuf = call.argument<ByteArray>("byteBuf") as ByteArray
            mediaMuxerWrapper.encode(
                byteBuf
            )
        } else if (call.method.equals("addTrack")) {
            val sampleRate = call.argument<Int>("sample-rate")
            val channelCount = call.argument<Int>("channel-count")
            val maxInputSize = call.argument<Int>("max-input-size")
            val bitRate = call.argument<Int>("bitrate")

            val mediaFormat = MediaFormat()
            mediaFormat.setInteger(MediaFormat.KEY_SAMPLE_RATE, sampleRate!!)
            mediaFormat.setInteger(MediaFormat.KEY_CHANNEL_COUNT, channelCount!!)
            mediaFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, maxInputSize!!)
            mediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, bitRate!!)
            mediaMuxerWrapper.addTrack(mediaFormat)

        } else if (call.method.equals("writeSampleData")) {
            val trackIndex = call.argument<Int>("trackIndex")
            val byteBuf = call.argument<ByteArray>("byteBuf")
            val bufferInfo = call.argument<String>("bufferInfo")
            mediaMuxerWrapper.writeSampleData(trackIndex!!, byteBuf!!, bufferInfo!!)

        } else if (call.method.equals("getEncoderCount")) {
            mediaMuxerWrapper.getEncoderCount()

        } else if (call.method.equals("setOrientationHint")) {
            val degrees = call.argument<Int>("degrees")
            mediaMuxerWrapper.setOrientationHint(degrees!!)

        } else if (call.method.equals("setLocation")) {
            val latitude = call.argument<Float>("latitude")
            val longitude = call.argument<Float>("longitude")
            mediaMuxerWrapper.setLocation(latitude!!, longitude!!)

        } else if (call.method.equals("stop")) {
            mediaMuxerWrapper.stop()
        } else if (call.method.equals("release")) {
            mediaMuxerWrapper.release()

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
