import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_media_writer/flutter_media_writer.dart';
import 'package:flutter_media_writer/flutter_media_writer_platform_interface.dart';
import 'package:flutter_media_writer/flutter_media_writer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMediaWriterPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterMediaWriterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMediaWriterPlatform initialPlatform = FlutterMediaWriterPlatform.instance;

  test('$MethodChannelFlutterMediaWriter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMediaWriter>());
  });

  test('getPlatformVersion', () async {
    FlutterMediaWriter flutterMediaWriterPlugin = FlutterMediaWriter();
    MockFlutterMediaWriterPlatform fakePlatform = MockFlutterMediaWriterPlatform();
    FlutterMediaWriterPlatform.instance = fakePlatform;
  
    expect(await flutterMediaWriterPlugin.getPlatformVersion(), '42');
  });
}
