package com.example.flutter_media_writer

import android.media.MediaCodec
import android.media.MediaCodec.CodecException
import android.media.MediaFormat
import android.media.MediaMuxer
import android.util.Log
import java.io.IOException
import java.nio.BufferOverflowException
import java.nio.ByteBuffer
import java.util.concurrent.LinkedBlockingQueue
import android.os.Environment
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class VideoEncoderManager : MediaCodec.Callback() {
    private val inputBuffersQueue = LinkedBlockingQueue<Int>(
        10
    )
    private var mediaCodec: MediaCodec? = null
    private var mediaMuxer: MediaMuxer? = null
    private var outputVideoIndex = 0
    private var videoPath: String? = null
    private var framePresentationTime: Long = 0
    private var isMediaCodectted = false
    private var width = 0
    private var height = 0

    fun getGalleryPath(): String? {
        val externalStoragePublicDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val currentDate = LocalDate.now()
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        val dateString = currentDate.format(formatter)
        return "${externalStoragePublicDirectory?.absolutePath}/$dateString.mp4"
    }
    fun prepare(videoSize: Size, colorFormat: Int) {
        try {
            videoPath = getGalleryPath();
            Log.d(
                TAG,
                String.format(
                    "startEncoder. Status: completed. Video path: %s",
                    this.videoPath
                )
            )
            width = videoSize.width
            height = videoSize.height
            val format = createOutputFormat(videoSize, colorFormat)
            mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC) //h.264
            mediaCodec!!.setCallback(this)
            mediaCodec!!.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            framePresentationTime = 0
            mediaCodec!!.start()
            isMediaCodecStarted = true
            Log.d(
                TAG,
                String.format(
                    "startEncoder. Status: completed. Video path: %s",
                    this.videoPath
                )
            )
        } catch (e: IOException) {
            Log.d(
                TAG,
                String.format("startEncoder. Status: error. Message: %s", e.message)
            )
        } catch (e: Exception) {
            Log.d(
                TAG,
                String.format(
                    "startEncoder. Status: error. Exception message: %s",
                    e.message
                )
            )
        }
    }




    fun encode(frameData: ByteArray?) {
        Log.d(
            TAG,
            "encode. Status: started. Message: Frame encoding started."
        )
        if (frameData == null) {
            Log.d(
                TAG,
                "encode. Status: null frame."
            )
            return
        }
        queueInputBuffer(frameData)

    }

    override fun onInputBufferAvailable(mediaCodec: MediaCodec, inputBufferIndex: Int) {
        Log.d(TAG, "onInputBufferAvailable: $inputBufferIndex")
        while (!inputBuffersQueue.offer(inputBufferIndex)) {
            inputBuffersQueue.poll()
        }
    }

    override fun onOutputBufferAvailable(
        mediaCodec: MediaCodec,
        outputBufferIndex: Int,
        bufferInfo: MediaCodec.BufferInfo
    ) {
        Log.d(TAG, "onOutputBufferAvailable: $outputBufferIndex")
        dequeueInputBuffer(mediaCodec, outputBufferIndex, bufferInfo)
    }

    override fun onError(mediaCodec: MediaCodec, e: CodecException) {
        Log.d(
            TAG,
            String.format("onError. Message: Error thrown from MediaCodec. Error: %s", e.message)
        )
    }

    override fun onOutputFormatChanged(mediaCodec: MediaCodec, mediaFormat: MediaFormat) {
        Log.d(TAG, "onOutputFormatChanged")
    }

    /**
     * Send the frame data to codec in order to be encoded to H.264 format.
     */
    private fun queueInputBuffer(frameData: ByteArray) {
        val index: Int = try {
            Log.d(
                TAG,
                String.format("queueInputBuffer.1 ")
            )
            inputBuffersQueue.take() //it waits until an element becomes available
        } catch (e: InterruptedException) {
            Log.d(
                TAG,
                String.format("queueInputBuffer. Status: error. Exception message: %s", e.message)
            )
            return
        }
        val inputBuffer: ByteBuffer? = try {
            Log.d(
                TAG,
                String.format("queueInputBuffer.2 ")
            )
            mediaCodec!!.getInputBuffer(index)
        } catch (e: IllegalStateException) {
            Log.d(TAG, "queueInputBuffer. Status: error. Message: Couldn't retrieve input buffer.")
            return
        }
        if (inputBuffer == null) {
            Log.d(
                TAG,
                "queueInputBuffer. Status: error. Message: Frame data available but input buffer is null."
            )
            return
        }
        try {
            Log.d(
                TAG,
                String.format("queueInputBuffer.2 ")
            )
            inputBuffer.put(frameData, 0, frameData.size)
            mediaCodec!!.queueInputBuffer(index, 0, frameData.size, framePresentationTime, 0)
            updatePresentationTime()
            Log.d(
                TAG,
                "queueInputBuffer. Status: success. Message: Frame data available and queued as input buffer."
            )
        } catch (e: BufferOverflowException) {
            if (isMediaCodecStarted) {
                Log.d(
                    TAG,
                    "queueInputBuffer. Status: error. Message: Frame data available but failed to queued as input buffer. Error: " + e.javaClass.simpleName
                )
            }
        } catch (e: IllegalStateException) {
            if (isMediaCodecStarted) {
                Log.d(
                    TAG,
                    "queueInputBuffer. Status: error. Message: Frame data available but failed to queued as input buffer. Error: " + e.javaClass.simpleName
                )
            }
        }
    }

    private fun dequeueInputBuffer(
        mediaCodec: MediaCodec,
        index: Int,
        bufferInfo: MediaCodec.BufferInfo
    ) {
        val outputBuffer: ByteBuffer?
        outputBuffer = try {
            mediaCodec.getOutputBuffer(index)
        } catch (e: IllegalStateException) {
            Log.d(TAG, "dequeueInputBuffer. Status: error. Message: Couldn't retrieve outputBuffer")
            return
        }
        if (outputBuffer == null) {
            Log.d(TAG, "dequeueInputBuffer. Message: Output buffer is null.")
            return
        }
        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
            Log.d(TAG, "dequeueInputBuffer. Message: Release output buffer.")
            mediaCodec.releaseOutputBuffer(index, false)
            return
        }
        if (bufferInfo.size != 0) {
            if (mediaMuxer == null && !initMediaMuxer(mediaCodec)) {
                return
            }
            mediaMuxer!!.writeSampleData(outputVideoIndex, outputBuffer, bufferInfo)
            Log.d(
                TAG,
                "dequeueInputBuffer. Message: Write input buffer(H264) to mp4 file with MediaMuxer."
            )
        }
        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
            mediaMuxer!!.stop()
            mediaMuxer!!.release()
        }
        try {
            mediaCodec.releaseOutputBuffer(index, false)
        } catch (e: IllegalStateException) {
            Log.e(
                TAG,
                "dequeueInputBuffer. Status: error. Message: Failed to release output buffer. " + e.message
            )
        }
    }

    /**
     * Initializes the media muxer which is responsible to write the frame buffer into an mp4 file.
     * @param mediaCodec the frame encoder
     * @return `true` if the initialization was successful, `false` otherwise.
     */
    private fun initMediaMuxer(mediaCodec: MediaCodec): Boolean {
        try {
            mediaMuxer = MediaMuxer(videoPath!!, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            Log.d(TAG, "initMediaMuxer. Status: success. Message: MediaMuxer was initialized.")
        } catch (e: IOException) {
            Log.d(
                TAG,
                String.format(
                    "initMediaMuxer. Status: error. Message: MediaMuxer initialization error. Error msg: %s",
                    e.message
                )
            )
            return false
        }
        Log.d(
            TAG,
            String.format(
                "initMediaMuxer. Message: Create video index with MediaFormat. Output video index: %s",
                outputVideoIndex
            )
        )
        outputVideoIndex = mediaMuxer!!.addTrack(mediaCodec.outputFormat)
        mediaMuxer!!.start()
        return true
    }

    fun stop() {
        Log.d(TAG, "stopEncoder")
        outputVideoIndex = 0
        if (mediaCodec != null && isMediaCodecStarted) {
            try {
                mediaCodec!!.stop()
                mediaCodec!!.release()
            } catch (e: IllegalStateException) {
                Log.d(TAG, "stopEncoder. Status:error. Message: Couldn't stop the codec.")
            }
            mediaCodec = null
            isMediaCodecStarted = false
        }
        if (mediaMuxer != null) {
            mediaMuxer!!.stop()
            mediaMuxer!!.release()
            mediaMuxer = null
        }
        inputBuffersQueue.clear()
    }



    /**
     * Creates the output format for the [.mediaCodec].
     */
    private fun createOutputFormat(videoSize: Size, colorFormat: Int): MediaFormat {
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
                videoSize.height,
            )
        )
        Log.d(TAG, String.format("createOutputFormat. Color format: %s ", colorFormat))
        result.setInteger(MediaFormat.KEY_COLOR_FORMAT, colorFormat)

        val videoBitRate = videoSize.width * videoSize.height * BITRATE_MULTIPLIER

        result.setInteger(MediaFormat.KEY_BIT_RATE, videoBitRate)
        Log.d(TAG, String.format("createOutputFormat. Video bit rate: %s ", videoBitRate))
        Log.d(TAG, String.format("createOutputFormat. Video frame rate: %s ", VIDEO_FRAME_RATE))

        result.setInteger(MediaFormat.KEY_FRAME_RATE, VIDEO_FRAME_RATE)
        Log.d(
            TAG,
            "createOutputFormat. Status: success. Message: Output format available for encoder."
        )
        return result
    }

    /**
     * Update the presentation time for the next encoded frame.
     */
    private fun updatePresentationTime() {
        framePresentationTime += FRAME_PRESENTATION_INTERVAL
    }



    companion object {
        private val TAG = VideoEncoderManager::class.java.simpleName

        /**
         * Number of photos in a second
         */
        private const val VIDEO_FRAME_RATE = 1

        /**
         * Number of pixels kept from a photo
         */
        private const val BITRATE_MULTIPLIER = 3

        /**
         * The interval between photos in microseconds
         */
        private const val FRAME_PRESENTATION_INTERVAL = 1000000

    }
}