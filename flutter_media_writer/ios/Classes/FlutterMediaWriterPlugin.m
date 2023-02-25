#import "FlutterMediaWriterPlugin.h"
#if __has_include(<flutter_media_writer/flutter_media_writer-Swift.h>)
#import <flutter_media_writer/flutter_media_writer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_media_writer-Swift.h"
#endif

@implementation FlutterMediaWriterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMediaWriterPlugin registerWithRegistrar:registrar];
}
@end
