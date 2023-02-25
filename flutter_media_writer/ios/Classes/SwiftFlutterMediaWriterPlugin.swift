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
  }
}
