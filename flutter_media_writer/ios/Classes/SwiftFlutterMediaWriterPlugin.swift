import Flutter
import UIKit

public class SwiftFlutterMediaWriterPlugin: NSObject, FlutterPlugin {
    var avAssetWrapper: AVAssetWriterWrapper

    override
    init() {
        self.avAssetWrapper = AVAssetWriterWrapper()
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_media_writer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediaWriterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if (call.method.elementsEqual("prepare")){
            guard let arguments = call.arguments as? [String: Any],
                  let outputPath = arguments["outputPath"] as? String,
                  let width = arguments["width"] as? Int,
                  let height = arguments["height"] as? Int else {
                result(FlutterError(code: "Arguments error prepare", message: "Missing or invalid arguments", details: nil))
                return
            }
            result(avAssetWrapper.prepare(outputPath: outputPath, width: width, height: height)  )
        }
        else
        if (call.method.elementsEqual("encode")){
            guard let arguments = call.arguments as? [String: Any],
                  let frame = arguments["byteBuf"] as? FlutterStandardTypedData,
                  let data = Data? (frame.data)
                  else {
                result(FlutterError(code: "Arguments error encode", message: "Missing or invalid arguments", details: nil))
                return
            }
            result(avAssetWrapper.encode(frame: data))
        }
        else
        if (call.method.elementsEqual("stop")){
            avAssetWrapper.stop()
            result("hello")
        }
    }
}
