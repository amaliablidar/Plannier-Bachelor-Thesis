package com.example.flutter_media_writer

import android.media.MediaCodec
import android.media.MediaCodec.*
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.util.Log
import java.io.IOException
import java.nio.BufferOverflowException
import java.nio.ByteBuffer
import java.util.concurrent.LinkedBlockingQueue


class MediaMuxerWrapper : Callback() {
    private var mediaMuxer: MediaMuxer? = null
    private var mediaCodec: MediaCodec? = null
    private var encoder: VideoEncoderManager = VideoEncoderManager()
    private var encoderCount = 0
    private var startCounter = 0
    private var isStarted = false
    private var outputVideoIndex = 0
    private var framePresentationTime: Long = 0
    private val inputBuffersQueue = LinkedBlockingQueue<Int>(
        10
    )


    @Throws(IOException::class)
    fun prepare(outputPath: String) {
        Log.d(TAG, "prepare: Prepare muxer $mediaMuxer")
        val width = 1200
        val height = 2000
        encoder.startEncoder(outputPath, Size(width, height),MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar)
    }

    fun encode(frame: ByteArray) {
        encoder.encode(frame)
    }

    fun start() {
        if (mediaMuxer == null) {
            throw IllegalStateException("Media muxer not prepared");
        }
        encoderCount = 0
        startCounter = 0
        framePresentationTime = 0
        mediaCodec?.start()
        mediaMuxer?.start()
        isStarted = true
    }

    fun addTrack(format: MediaFormat): Int {
        if (mediaMuxer == null || isStarted) {
            throw IllegalStateException("Media muxer not prepared");
        }
        encoderCount++
        Log.d(TAG, "addTrack: $mediaMuxer")
        outputVideoIndex = mediaMuxer!!.addTrack(mediaCodec!!.outputFormat)
        Log.d(TAG, "addTrack: $outputVideoIndex")
        return outputVideoIndex; }

    fun writeSampleData(trackIndex: Int, byteBuf: ByteArray, bufferInfo: String) {
        if (mediaMuxer == null) {
            throw IllegalStateException("Media muxer not prepared");
        }
        if (isStarted) {
            mediaMuxer?.writeSampleData(trackIndex, ByteBuffer.wrap(byteBuf), BufferInfo())
        }
    }

    fun getEncoderCount(): Int {
        return encoderCount
    }

    fun setOrientationHint(degrees: Int) {
        mediaMuxer?.setOrientationHint(degrees);
    }

    fun setLocation(latitude: Float, longitude: Float) {
        mediaMuxer?.setLocation(latitude, longitude)
    }

    fun stop() {
        encoder.stopEncoder()
    }

    fun release() {
        mediaMuxer?.release()
        mediaMuxer = null

    }

    private fun createOutputFormat(
        videoSize: Size,
        colorFormat: Int
    ): MediaFormat {
        val result = MediaFormat.createVideoFormat(
            MediaFormat.MIMETYPE_VIDEO_AVC,
            videoSize.width,
            videoSize.height
        )
        Log.d(
            TAG,
            java.lang.String.format(
                "createOutputFormat. Video width x height: %s x %s ",
                videoSize.width,
                videoSize.height
            )
        )
        Log.d(TAG, String.format("createOutputFormat. Color format: %s ", colorFormat))
        result.setInteger(MediaFormat.KEY_COLOR_FORMAT, colorFormat)
        //this value for video bit rate was chosen after testing multiple values, in order to maintain a smaller video size.
        val videoBitRate = videoSize.width * videoSize.height * 3
        result.setInteger(MediaFormat.KEY_BIT_RATE, videoBitRate)
        Log.d(TAG, String.format("createOutputFormat. Video bit rate: %s ", videoBitRate))
        Log.d(
            TAG,
            java.lang.String.format("createOutputFormat. Video frame rate: %s ", 5)
        )
        Log.d(
            TAG,
            java.lang.String.format(
                "createOutputFormat. Video I frame interval: %s ",
                5
            )
        )
        result.setInteger(MediaFormat.KEY_FRAME_RATE, 5)
        result.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 5)
        Log.d(
            TAG,
            "createOutputFormat. Status: success. Message: Output format available for encoder."
        )
        return result
    }

    companion object {
        private const val TAG = "MediaMuxerWrapper"
    }

    override fun onInputBufferAvailable(mediaCodec: MediaCodec, inputBufferIndex: Int) {
        Log.d(TAG, "onInputBufferAvailable: $inputBufferIndex")
        while (!inputBuffersQueue.offer(inputBufferIndex)) {
            inputBuffersQueue.poll()
        }
    }

    override fun onOutputBufferAvailable(
        mediaCodec: MediaCodec,
        inputBufferIndex: Int,
        bufferInfo: BufferInfo
    ) {
        val outputBuffer = try {
            mediaCodec.getOutputBuffer(inputBufferIndex)
        } catch (e: java.lang.IllegalStateException) {
            Log.d(
                TAG,
                "onOutputBufferAvailable. Status: error prepare output buffer. Message: ${e.message}"
            )
            return
        }
        if (outputBuffer == null) {
            Log.d(TAG, "onOutputBufferAvailable. Message: Output buffer is null.")
            return
        }
        if (bufferInfo.flags and BUFFER_FLAG_CODEC_CONFIG != 0) {
            Log.d(TAG, "onOutputBufferAvailable. Message: Release output buffer.")
            mediaCodec.releaseOutputBuffer(inputBufferIndex, false)
            return
        }
        if (bufferInfo.size != 0) {
            mediaMuxer!!.writeSampleData(outputVideoIndex, outputBuffer, bufferInfo)
            Log.d(
                TAG,
                "onOutputBufferAvailable. Message: Write image to video file."
            )
        }
        if (bufferInfo.flags and BUFFER_FLAG_END_OF_STREAM != 0) {
            mediaMuxer!!.stop()
            mediaMuxer!!.release()
        }
        try {
            mediaCodec.releaseOutputBuffer(inputBufferIndex, false)
        } catch (e: IllegalStateException) {
            Log.e(
                TAG,
                "onOutputBufferAvailable. Status: error release output buffer. Message: " + e.message
            )
        }

    }

    override fun onError(mediaCodec: MediaCodec, e: CodecException) {
        Log.d(
            TAG,
            String.format("onError. Error: %s", e.message)
        )
    }

    override fun onOutputFormatChanged(mediaCodec: MediaCodec, format: MediaFormat) {
        Log.d(TAG, "onOutputFormatChanged")
    }
}
