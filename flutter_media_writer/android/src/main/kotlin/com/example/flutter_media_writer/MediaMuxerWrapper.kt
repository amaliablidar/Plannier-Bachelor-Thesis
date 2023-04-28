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


class MediaMuxerWrapper {
    private var encoder: VideoEncoderManager = VideoEncoderManager()


    @Throws(IOException::class)
    fun prepare(outputPath: String, width:Int, height:Int) {
        encoder.startEncoder(outputPath, Size(width, height),MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar)
    }

    fun encode(frame: ByteArray) {
        encoder.encode(frame)
    }

    fun stop() {
        encoder.stopEncoder()
    }

}
