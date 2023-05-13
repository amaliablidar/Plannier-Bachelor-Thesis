//
//  AVAssetWriterWrapper.swift
//  flutter_media_writer
//
//  Created by Amalia Blidar on 13.05.2023.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import os
import CoreImage.CIFilterBuiltins
import CoreVideo

class AVAssetWriterWrapper{
    var assetwriter : AVAssetWriter?
    var settingsAssistant : [String : Any]?
    var assetWriterInput : AVAssetWriterInput?
    var assetWriterAdaptor:AVAssetWriterInputPixelBufferAdaptor?
    var frameCount = 0
    
    
    
    func prepare(outputPath: String, width:Int, height:Int)->String {
        
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("2.mp4")
        
        do{
            assetwriter = try AVAssetWriter(outputURL: url!, fileType: .mp4)
        }
        catch{
            return "error"
        }
        settingsAssistant =  [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080,
            
        ]
        
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
            kCVPixelBufferWidthKey as String: NSNumber(value: width),
            kCVPixelBufferHeightKey as String: NSNumber(value: height),
            kCVPixelBufferBytesPerRowAlignmentKey as String: NSNumber(value:width * 4)

        ]
        
        
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        assetWriterAdaptor  = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        assetwriter?.add(assetWriterInput!)
        assetwriter?.startWriting()
        assetwriter?.startSession(atSourceTime: CMTime.zero)
        return (url!.path);
        
        
    }
    
    func encode(frame: Data?)->String {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        let ySize = 1200 * 2000
        let uSize = ySize/2

        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         1200,
                                         2000,
                                         kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                         attrs,
                                         &pixelBuffer)
        
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // Copy the Y plane data into the pixel buffer
        if let yDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 0) {
            let yData = frame!.subdata(in: 0..<ySize)
            yData.copyBytes(to: yDestination.assumingMemoryBound(to: UInt8.self), count: ySize)
        }
        
        // Copy the UV plane data into the pixel buffer
        if let uDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 1) {
            let uData = frame!.subdata(in: ySize..<ySize+uSize)
            uData.copyBytes(to: uDestination.assumingMemoryBound(to: UInt8.self), count: uSize)
        }

        // Unlock the base address of the pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        //determine how many frames we need to generate
        let framesPerSecond = 30
        let totalFrames = 3 * framesPerSecond
        
        //        while frameCount < totalFrames + frameCount {
        if assetWriterInput!.isReadyForMoreMediaData {
            let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
            
            //append the contents of the pixelBuffer at the correct ime
            
            assetWriterAdaptor?.append(pixelBuffer!, withPresentationTime: frameTime)
            frameCount+=1
        }
        else{
            return "great failure"
        }
        //        }

        return "great success"
        
        
    }
    
    func stop() {
        assetWriterInput?.markAsFinished()
        assetwriter?.finishWriting {
            print("")
        }
        frameCount = 0
    }
    
}
