import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_media_writer/flutter_media_writer.dart';
import 'package:image/image.dart';

class YuvConversion {
  static Future<bool> jpgToYuv(List<Uint8List> jpegData) async {
    try {
      final decoder = JpegDecoder();
      Image? decoded;
      String direPath = "/data/data/com.example.event_app";
      String filePath = "$direPath/0.mp4";
      var videoFile = File(filePath);
      FlutterMediaWriter mediaWriter = FlutterMediaWriter();
      mediaWriter.prepare(videoFile.path, 1200, 2000);

      for (int i = 0; i < jpegData.length; i++) {
        decoded = decoder.decodeImage(jpegData[i]);
        if (decoded != null) {
          var imageResized = copyResize(decoded, width: 1200, height: 2000);

          await Future.delayed(const Duration(seconds: 10));
          var pixels = imageResized.getBytes();
          var yuv420 = convertRgbToYuv(pixels, 1200, 2000);
          await Future.delayed(const Duration(seconds: 5));

          mediaWriter.encode(yuv420);
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.stop();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Uint8List convertRgbToYuv(Uint8List pixels, int width, int height) {
    final int ySize = width * height;
    final Uint8List yuvy = Uint8List(ySize);
    final Uint8List yuvu = Uint8List(ySize);
    final Uint8List yuvv = Uint8List(ySize);

    int index = 0;
    for (int i = 0; i < pixels.length; i = i + 4) {
      int r = pixels[i + 0];
      int g = pixels[i + 1];
      int b = pixels[i + 2];

      final int yValue = (0.299 * r + 0.587 * g + 0.114 * b).round();
      yuvy[index] = yValue.clamp(0, 255);

      int uValue = (-0.147 * r - 0.289 * g + 0.436 * b + 128).round();
      yuvu[index] = uValue.clamp(0, 255);

      int vValue = (0.615 * r - 0.515 * g - 0.100 * b + 128).round();
      yuvv[index] = vValue.clamp(0, 255);
      index++;
    }
    var yuv1 = convertYUV444toYUV420(yuvy, yuvu, yuvv, width, height);
    return yuv1;
  }

  static Uint8List convertYUV444toYUV420(Uint8List yData, Uint8List uData,
      Uint8List vData, int width, int height) {
    final yLength = width * height;
    final uvLength = yLength ~/ 4;

    final yuv420 = Uint8List(yLength + 2 * uvLength);

    yuv420.setRange(0, yLength, yData);

    for (var y = 0; y < height; y += 2) {
      for (var x = 0; x < width; x += 2) {
        final uIndex = y ~/ 2 * width ~/ 2 + x ~/ 2 + yLength;
        final vIndex = uIndex + uvLength;
        yuv420[uIndex] = (uData[y * width + x] +
                uData[y * width + x + 1] +
                uData[(y + 1) * width + x] +
                uData[(y + 1) * width + x + 1]) ~/
            4;
        yuv420[vIndex] = (vData[y * width + x] +
                vData[y * width + x + 1] +
                vData[(y + 1) * width + x] +
                vData[(y + 1) * width + x + 1]) ~/
            4;
      }
    }

    return yuv420;
  }
}
