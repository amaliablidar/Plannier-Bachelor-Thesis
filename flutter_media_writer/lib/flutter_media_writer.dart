import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'flutter_media_writer_platform_interface.dart';
import 'media_format.dart';

class FlutterMediaWriter {
  final _methodChannel = const MethodChannel('flutter_media_writer');

  Future<String?> getPlatformVersion() {
    return FlutterMediaWriterPlatform.instance.getPlatformVersion();
  }

  void prepare(String outputPath) async {
    final args = <String, dynamic>{
      'outputPath': outputPath,
    };
    await _methodChannel.invokeMethod('prepare', args);
  }

  void start() async {
    await _methodChannel.invokeMethod('start');
  }

  void encode(Uint8List byteBuf) async {
    final args = <String, dynamic>{
      'byteBuf': byteBuf,
    };
    print("BYTE 0");
    await _methodChannel.invokeMethod('encode', args);
  }

  Future<int> addTrack(MediaFormat format) async {
    final args = <String, dynamic>{
      'sample-rate': format.sampleRate,
      'channel-count': format.channel,
      'max-input-size': format.maxInputSize,
      'bitrate': format.bitRate,
    };
    return await _methodChannel.invokeMethod('addTrack', args);
  }

  void writeSampleData(
      int trackIndex, Uint8List byteBuf, String bufferInfo) async {
    final args = <String, dynamic>{
      'trackIndex': trackIndex,
      'byteBuf': byteBuf,
      'bufferInfo': bufferInfo
    };
    await _methodChannel.invokeMethod('writeSampleData', args);
  }

  Future<int> getEncoderCount() async {
    return await _methodChannel.invokeMethod('getEncoderCount');
  }

  void setOrientationHint(int degrees) async {
    final args = <String, dynamic>{
      'degrees': degrees,
    };
    return await _methodChannel.invokeMethod('setOrientationHint', args);
  }

  void setLocation(double latitude, double longitude) async {
    final args = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    return await _methodChannel.invokeMethod('setLocation', args);
  }

  void stop() async {
    return await _methodChannel.invokeMethod('stop');
  }

  void release() async {
    return await _methodChannel.invokeMethod('release');
  }
}
