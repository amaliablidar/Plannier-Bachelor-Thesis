import Flutter
import UIKit

public class SwiftFlutterMediaWriterPlugin: NSObject, FlutterPlugin {
    func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "flutter_media_writer", binaryMessenger: registrar.messenger())
//     let instance = SwiftFlutterMediaWriterPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
  }

  @objc (handleSendMessage:completion:)
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    print("onMethodCall (call.method)")
    if (call.method == "prepare") {
//         let outputPath = call.arguments["outputPath"] as? String
//         let width = call.arguments["width"] as? Int
//         let height = call.arguments["height"] as? Int
//         android.util.Log.d(TAG, "onMethodCall: (outputPath)")
//         mediaMuxerWrapper.prepare(outputPath!, width!, height!)
    } else if (call.method == "encode") {
        print("BYTE 1")
//         let byteBuf = call.arguments["byteBuf"] as? Data
//         mediaMuxerWrapper.encode(byteBuf)
    } else if (call.method == "stop") {
//         mediaMuxerWrapper.stop()
    } else {
//         result.notImplemented()
    }
  }
}
