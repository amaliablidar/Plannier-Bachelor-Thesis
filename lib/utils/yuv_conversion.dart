import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_media_writer/flutter_media_writer.dart';
import 'package:image/image.dart';

class YuvConversion {
  static Future<Uint8List?> jpgToRGB() async {
    final Uint8List inputImg =
        (await rootBundle.load("assets/event_placeholder.jpg"))
            .buffer
            .asUint8List();
    final decoder = JpegDecoder();
    final decodedImage = decoder.decodeImage(inputImg);
    final decodedBytes = decodedImage?.getBytes(format: Format.rgb);
    if (decodedImage != null && decodedBytes != null) {
      final rgbaList = Uint8List(decodedImage.height * decodedImage.width + 4);

      for (var i = 0; i < decodedImage.height * decodedImage.width; i++) {
        final rgbOffset = i * 3;
        final rgbaOffset = i * 4;
        rgbaList[rgbaOffset] = decodedBytes[rgbOffset]; // red
        rgbaList[rgbaOffset + 1] = decodedBytes[rgbOffset + 1]; // green
        rgbaList[rgbaOffset + 2] = decodedBytes[rgbOffset + 2]; // blue
        rgbaList[rgbaOffset + 3] = 255; // a
      }
    }
    return decodedBytes;
  }

  static void jpgToYuv(Uint8List jpegData, String path) async {
    print("PATH $path");
    // Decode the JPEG data into a List of pixel values
    final decoder = JpegDecoder();

    var decoded = decoder.decodeImage(jpegData);
    if (decoded != null) {
      // Get the width and height of the image
      int width = decoded.width;
      int height = decoded.height;

      // Get the pixel values as a List of integers in RGB format
      var pixels = decoded.getBytes(format: Format.rgb);
      var length = pixels.length;
      print("isEqual ${length == width * height * 3}");
      print("width $width");
      print("height $height");
      print("length ${pixels.length}");

      // Allocate memory for the YUV image data
      var yuv420 = convertRgbToYuv(pixels, width, height);

      // var yuv420 = convertYUV444toYUV420(yuvData, width, height);
      // print("length yuv ${yuvData.length}");
      // print(
      //     "isEqual yuv  ${yuvData.length}  - ${width * height + width * height ~/ 2}");

      // Iterate over the pixels and convert each one to YUV format

      String direPath = "/data/data/com.example.event_app";
      String filePath = "$direPath/0.mp4";
      var videoFile = File(filePath);
      FlutterMediaWriter mediaWriter = FlutterMediaWriter();
      mediaWriter.prepare(videoFile.path);
      await Future.delayed(const Duration(seconds: 10));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.encode(yuv420);
      await Future.delayed(const Duration(seconds: 2));
      mediaWriter.stop();
    }
  }

  // static Uint8List convertRgbToYuv(Uint8List pixels, int width, int height) {
  //   final int ySize = width * height;
  //   final Uint8List yuv = Uint8List(ySize * 3);
  //
  //   int index = 0;
  //   for (int y = 0; y < height; y++) {
  //     for (int x = 0; x < width; x++) {
  //       int r = pixels[y * width * 3 + x * 3];
  //       int g = pixels[y * width * 3 + x * 3 + 1];
  //       int b = pixels[y * width * 3 + x * 3 + 2];
  //
  //
  //       final int yValue = (0.299 * r + 0.587 * g + 0.114 * b).round();
  //       yuv[index++] = yValue.clamp(0, 255);
  //
  //       int uValue = (-0.147 * r - 0.289 * g + 0.436 * b).round();
  //       yuv[index++] = uValue.clamp(0, 255);
  //
  //       int vValue = (0.615 * r - 0.515 * g - 0.100 * b).round();
  //       yuv[index++] = vValue.clamp(0, 255);
  //     }
  //   }
  //
  //   return yuv;
  // }
  static Uint8List convertRgbToYuv(Uint8List pixels, int width, int height) {
    final int ySize = width * height;
    final Uint8List yuv = Uint8List(ySize * 3);
    final Uint8List yuvy = Uint8List(ySize);
    final Uint8List yuvu = Uint8List(ySize);
    final Uint8List yuvv = Uint8List(ySize);

    int index = 0;
    int index1 = 0;
    for (int i = 0; i < pixels.length; i = i + 3) {
      int r = pixels[i];
      int g = pixels[i + 1];
      int b = pixels[i + 2];

      final int yValue = (0.299 * r + 0.587 * g + 0.114 * b).round();
      yuv[index++] = yValue.clamp(0, 255);
      yuvy[index1] = yValue.clamp(0, 255);

      int uValue = (-0.147 * r - 0.289 * g + 0.436 * b).round();
      yuv[index++] = uValue.clamp(0, 255);
      yuvu[index1] = uValue.clamp(0, 255);

      int vValue = (0.615 * r - 0.515 * g - 0.100 * b).round();
      yuv[index++] = vValue.clamp(0, 255);
      yuvv[index1] = vValue.clamp(0, 255);
      index1++;
    }
    int sum = 0;
    for (int i = 0; i < yuv.length; i++) {
      if (yuv[i] == 0) {
        sum++;
      }
    }
    print("sum of 0 is $sum");
    var yuv1 = convertYUV444toYUV420(yuvy, yuvu, yuvv, width, height);
    return yuv1;
  }

  static Uint8List convertYUV444toYUV4202(
      Uint8List yuv444, int width, int height) {
    final int ySize = width * height;
    final int uvSize = ySize ~/ 4;
    final Uint8List yuv420 = Uint8List(ySize + 2 * uvSize);

    int index = 0;
    Uint8List yValues = Uint8List(ySize);
    Uint8List uValues = Uint8List(uvSize);
    Uint8List vValues = Uint8List(uvSize);
    for (int i = 0; i < yuv444.length; i = i + 3) {
      yValues[index] = yuv444[i];
      index++;
    }

    index = 0;
    for (int i = 1; i < yuv444.length; i = i + 12) {
      int med =
          (yuv444[i] + yuv444[i + 3] + yuv444[i + 6] + yuv444[i + 9]) ~/ 4;
      uValues[index] = med;
      index++;
    }

    index = 0;
    for (int i = 2; i < yuv444.length; i = i + 12) {
      int med =
          (yuv444[i] + yuv444[i + 3] + yuv444[i + 6] + yuv444[i + 9]) ~/ 4;
      vValues[index] = med;
      index++;
    }

    index = 0;
    while (index < ySize + 2 * uvSize) {
      for (int yIndex = 0; yIndex < yValues.length; yIndex++) {
        yuv420[index] = yValues[yIndex];
        index++;
      }
      for (int uIndex = 0; uIndex < uValues.length; uIndex++) {
        yuv420[index] = uValues[uIndex];
        index++;
      }
      for (int vIndex = 0; vIndex < vValues.length; vIndex++) {
        yuv420[index] = vValues[vIndex];
        index++;
      }
    }
    return yuv420;
  }

  static Uint8List convertYUV444toYUV4203(
      Uint8List yuv444, int width, int height) {
    final int ySize = width * height;
    final int uvSize = ySize ~/ 4;
    final Uint8List yuv420 = Uint8List(ySize + 2 * uvSize);

    int index = 0;
    Uint8List yValues = Uint8List(ySize);
    Uint8List uValues = Uint8List(uvSize);
    Uint8List vValues = Uint8List(uvSize);
    for (int i = 0; i < yuv444.length; i = i + 3) {
      yValues[index] = yuv444[i];
      index++;
    }
    int ind = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        index = y * width + x;
        if (y % 2 == 0 && x % 2 == 0) {
          uValues[ind] = (yuv444[index]);
          vValues[ind] = (yuv444[index]);
          ind++;
        }
      }
    }
    index = 0;
    while (index < ySize + 2 * uvSize) {
      for (int yIndex = 0; yIndex < yValues.length; yIndex++) {
        yuv420[index] = yValues[yIndex];
        index++;
      }
      for (int uIndex = 0; uIndex < uValues.length; uIndex++) {
        yuv420[index] = uValues[uIndex];
        index++;
      }
      for (int vIndex = 0; vIndex < vValues.length; vIndex++) {
        yuv420[index] = vValues[vIndex];
        index++;
      }
    }

    return yuv420;
  }

  static Uint8List convertYUV444toYUV4205(
      Uint8List yuv444, int width, int height) {
    final int ySize = width * height;
    final int uvSize = ySize ~/ 4;
    final Uint8List yuv420 = Uint8List(ySize + 2 * uvSize);

    int index = 0;
    Uint8List yValues = Uint8List(ySize);
    Uint8List uValues = Uint8List(uvSize);
    Uint8List vValues = Uint8List(uvSize);
    for (int i = 0; i < yuv444.length; i = i + 3) {
      yValues[index] = yuv444[i];
      index++;
    }
    int uInd = 0;
    int vInd = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        index = y * width + x;
        if (y % 2 == 0 && x % 2 == 0) {
          uValues[uInd] = (yuv444[index]);
          uInd++;
        } else if (y % 1 != 0 && x % 2 == 0) {
          vValues[vInd] = (yuv444[index]);
          vInd++;
        }
      }
    }
    index = 0;
    while (index < ySize + 2 * uvSize) {
      for (int yIndex = 0; yIndex < yValues.length; yIndex++) {
        yuv420[index] = yValues[yIndex];
        index++;
      }
      for (int uIndex = 0; uIndex < uValues.length; uIndex++) {
        yuv420[index] = uValues[uIndex];
        index++;
      }
      for (int vIndex = 0; vIndex < vValues.length; vIndex++) {
        yuv420[index] = vValues[vIndex];
        index++;
      }
    }

    return yuv420;
  }

  static Uint8List convertYUV444toYUV420(Uint8List yData, Uint8List uData,
      Uint8List vData, int width, int height) {
    final yLength = width * height;
    final uvLength = yLength ~/ 4;
    var uIndex = width * height;
    var vIndex = yLength + uvLength;

    final yuv420 = Uint8List(yLength + 2 * uvLength);

    // Copy Y plane
    yuv420.setRange(0, yLength, yData);

    // for (var x = 0; x < width * height - 1; x += 2) {
    //   yuv420[uIndex++] = uData[x] +
    //       uData[x + 1] +
    //       uData[x + width] +
    //       uData[x + width + 1] ~/ 4;
    //   yuv420[vIndex++] = vData[x] +
    //       vData[x + 1] +
    //       vData[x + width] +
    //       vData[x + width + 1] ~/ 4;
    // }

    // Subsample U and V planes
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
