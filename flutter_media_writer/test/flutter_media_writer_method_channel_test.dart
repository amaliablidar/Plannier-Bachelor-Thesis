import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_media_writer/flutter_media_writer_method_channel.dart';

void main() {
  MethodChannelFlutterMediaWriter platform = MethodChannelFlutterMediaWriter();
  const MethodChannel channel = MethodChannel('flutter_media_writer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
