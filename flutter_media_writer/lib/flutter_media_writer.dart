import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'flutter_media_writer_platform_interface.dart';
import 'media_format.dart';

class FlutterMediaWriter  {
  final _methodChannel = const MethodChannel('flutter_media_writer');

  Future<String?> getPlatformVersion() {
    return FlutterMediaWriterPlatform.instance.getPlatformVersion();
  }

  Future<String> prepare(String outputPath, int width, int height) async {
    final args = <String, dynamic>{
      'outputPath': outputPath,
      'width': width,
      'height': height,
    };
    return await _methodChannel.invokeMethod('prepare', args);
  }

  Future<String> encode(Uint8List byteBuf) async {
    final args = <String, dynamic>{
      'byteBuf': byteBuf,
    };
    return await _methodChannel.invokeMethod('encode', args);
  }

  void stop() async {
    return await _methodChannel.invokeMethod('stop');
  }

}
