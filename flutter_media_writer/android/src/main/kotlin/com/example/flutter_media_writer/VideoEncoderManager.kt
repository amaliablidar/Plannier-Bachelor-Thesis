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

/**
 * The video encoder implementation which is responsible to encode multiple frames into a video file.
 */
class VideoEncoderManager : MediaCodec.Callback() {
    /**
     * The queue containing all the available input buffers for encoding operation.
     */
    private val inputBuffersQueue = LinkedBlockingQueue<Int>(
        INPUT_BUFFERS_QUEUE_CAPACITY
    )

    /**
     * The codec for encoding the frames in a H.264 format.
     */
    private var mediaCodec: MediaCodec? = null

    /**
     * The muxer for writing the H.264 frames into an mp4 video file.
     */
    private var mediaMuxer: MediaMuxer? = null

    /**
     * The index of the current video file to identify the file in order to write the frames to it.
     */
    private var outputVideoIndex = 0

    /**
     * The video path where to store the video file.
     */
    private var videoPath: String? = null

    /**
     * The presentation time for the current frame which is constantly increased with [.FRAME_PRESENTATION_INTERVAL].
     */
    private var framePresentationTime: Long = 0

    /**
     * A flag which is `true` when the encoding is started, `false` otherwise.
     */
    private var isMediaCodecStarted = false

    /**
     * The frame width which is the same as video width.
     */
    private var width = 0

    /**
     * The frame height which is the same as video height.
     */
    private var height = 0
    fun startEncoder(videoPath: String?, videoSize: Size, colorFormat: Int) {
        try {
            width = videoSize.width
            height = videoSize.height
            this.videoPath = videoPath
            val format = createOutputFormat(videoSize, colorFormat)
            mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
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

    fun stopEncoder() {
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
            inputBuffersQueue.take()
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

    /**
     * Receives the frame data from codec which is encoded as H.264 and writes the frames into an mp4 file.
     * @param mediaCodec the codec which handles the encoding operation.
     * @param index the index of the output buffer.
     * @param bufferInfo the information related to the current frame.
     */
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

    /**
     * Creates the output format for the [.mediaCodec].
     * @param videoSize the size of the video frames.
     * @param colorFormat the color format of the video frames to encode.
     * @return the format of the encoded video.
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
        //this value for video bit rate was chosen after testing multiple values, in order to maintain a smaller video size.
        val roundedMp=Math.round((width * height) / 1000000f)
        val videoBitRate = if (roundedMp >= FRAME_MP) {
            videoSize.width * videoSize.height * BITRATE_MULTIPLIER_HIGH_RESOLUTION
        } else {
            videoSize.width * videoSize.height * BITRATE_MULTIPLIER_LOW_RESOLUTION
        }
        result.setInteger(MediaFormat.KEY_BIT_RATE, videoBitRate)
        Log.d(TAG, String.format("createOutputFormat. Video bit rate: %s ", videoBitRate))
        Log.d(TAG, String.format("createOutputFormat. Video frame rate: %s ", VIDEO_FRAME_RATE))
        Log.d(
            TAG,
            String.format(
                "createOutputFormat. Video I frame interval: %s ",
                VIDEO_KEY_FRAME_INTERVAL
            )
        )
        result.setInteger(MediaFormat.KEY_FRAME_RATE, VIDEO_FRAME_RATE)
        result.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, VIDEO_KEY_FRAME_INTERVAL)
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
        // presentationTimeUs should be monotonic
        // otherwise muxer fail to write
        framePresentationTime += FRAME_PRESENTATION_INTERVAL
    }

    companion object {
        private val TAG = VideoEncoderManager::class.java.simpleName

        /**
         * The frame rate per second for encoding the frames.
         * For a frame rate of 5/second, a video having 10 seconds will contain 50 frames.
         */
        private const val VIDEO_FRAME_RATE = 5

        /**
         * The frame rate from which the bit rate should change.
         */
        private const val FRAME_MP = 5

        /**
         * The multiplier for bitrate when is a higher resolution for frame.
         */
        private const val BITRATE_MULTIPLIER_HIGH_RESOLUTION = 3

        /**
         * The multiplier for bitrate when is a lower resolution for frame.
         */
        private const val BITRATE_MULTIPLIER_LOW_RESOLUTION = 4

        /**
         * The interval in seconds for a video key frames.
         */
        private const val VIDEO_KEY_FRAME_INTERVAL = 5

        /**
         * The presentation interval between the video frames in microseconds .
         */
        private const val FRAME_PRESENTATION_INTERVAL = 200000

        /**
         * The maximum capacity for the input buffers queue.
         * The input buffers number is depending on the device type, therefore it will be used the highest value.
         */
        private const val INPUT_BUFFERS_QUEUE_CAPACITY = 10

        /**
         * The value used to double the value or to divided it in half.
         */
        private const val TWO_OPERATIONAL_VALUE = 2
    }
}