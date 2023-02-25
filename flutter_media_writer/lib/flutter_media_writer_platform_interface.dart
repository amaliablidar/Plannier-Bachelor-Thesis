import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_media_writer_method_channel.dart';

abstract class FlutterMediaWriterPlatform extends PlatformInterface {
  /// Constructs a FlutterMediaWriterPlatform.
  FlutterMediaWriterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMediaWriterPlatform _instance = MethodChannelFlutterMediaWriter();

  /// The default instance of [FlutterMediaWriterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMediaWriter].
  static FlutterMediaWriterPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMediaWriterPlatform] when
  /// they register themselves.
  static set instance(FlutterMediaWriterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
