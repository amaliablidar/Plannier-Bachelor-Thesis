import Foundation
import UIKit
import AVFoundation
import AVKit
import os
import CoreImage.CIFilterBuiltins
import CoreVideo
import Photos

class AVAssetWriterWrapper{
    var assetWriter : AVAssetWriter?
    var settingsAssistant : [String : Any]?
    var assetWriterInput : AVAssetWriterInput?
    var assetWriterAdaptor:AVAssetWriterInputPixelBufferAdaptor?
    var frameCount = 0

    func saveVideoToGallery(videoData: Data, fileName: String) {
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let videoURL = tempDirectoryURL.appendingPathComponent(fileName)

        do {
            try videoData.write(to: videoURL)
        } catch {
            print("Error saving video to temporary directory: \(error)")
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            if success {
                print("Video saved to gallery.")
            } else {
                print("Error saving video to gallery: \(error?.localizedDescription ?? "")")
            }

            do {
                try FileManager.default.removeItem(at: videoURL)
            } catch {
                print("Error deleting temporary video file: \(error)")
            }
        }
    }



    func prepare(width:Int, height:Int) {

        let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = formatter.string(from: Date())
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(dateString).mp4")

        do{
            assetWriter = try AVAssetWriter(outputURL: url!, fileType: .mp4)
        }
        catch{
            return "error"
        }
        settingsAssistant =  [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920,
        ]

        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value:kCVPixelFormatType_420YpCbCr8Planar),
            kCVPixelBufferWidthKey as String: NSNumber(value: width),
            kCVPixelBufferHeightKey as String: NSNumber(value: height)
        ]

        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        assetWriterAdaptor  = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        assetWriter?.add(assetWriterInput!)
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: CMTime.zero)
        return (url!.path);
    }

    func encode(frame: Data?)->String {

        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary

        let ySize = 1200 * 2000
        let uSize = ySize / 4

        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         1200,
                                         2000,
                                         kCVPixelFormatType_420YpCbCr8Planar,
                                         attrs,
                                         &pixelBuffer)

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        if let yDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 0) {
            let yData = frame!.subdata(in: 0..<ySize)
            yData.copyBytes(to: yDestination.assumingMemoryBound(to: UInt8.self), count: ySize)
        }
        
        if let uDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 1) {
            let uData = frame!.subdata(in: ySize..<ySize+uSize)
            uData.copyBytes(to: uDestination.assumingMemoryBound(to: UInt8.self), count: uSize)
        }

         if let vDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 2) {
             let vData = frame!.subdata(in: ySize+uSize..<ySize+uSize*2)
             vData.copyBytes(to: vDestination.assumingMemoryBound(to: UInt8.self), count: uSize)
         }

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        let framesPerSecond = 2
        let totalFrames = 10 * framesPerSecond

        while frameCount < totalFrames + frameCount {
            if assetWriterInput!.isReadyForMoreMediaData {
                let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
                assetWriterAdaptor?.append(pixelBuffer!, withPresentationTime: frameTime)
                frameCount+=1
            }
            
        }
    }

    func stop() {
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in

                guard let videoData = try? Data(contentsOf: self.assetWriter?.outputURL)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd_HHmmss"
                let dateString = formatter.string(from: Date())
                let fileName = "\(dateString).mp4"

                self.saveVideoToGallery(videoData: videoData, fileName: fileName)
            }
        frameCount = 0
    }

}
