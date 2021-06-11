//
//  ViewModel.swift
//  VideoEnc
//
//  Created by Muslim on 11.06.2021.
//

import Foundation
import SwiftUI
import AVKit
import SessionExporter
import AVFoundation
import Photos
import TTProgressHUD

class ViewModel: ObservableObject {
    
    @State var hudConfig = TTProgressHUDConfig(type: .loading, title: "Please Wait")
    
    @Published var showingPicker = false
    @Published var videoPicked = false
    @Published var loading = false
    @Published var showingAlert = false
    
    @Published var url : NSURL? = nil {
        didSet {
            if let url = url {
                videoPicked = true
                self.encodeVideoFrom(videoURL: url as URL)
            }
        }
    }
    
    func encodeVideoFrom(videoURL: URL) {
        self.loading = true
        
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        
        let exporter = NextLevelSessionExporter(withAsset: avAsset)
        exporter.outputFileType = AVFileType.mp4
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(ProcessInfo().globallyUniqueString)
            .appendingPathExtension("mp4")
        exporter.outputURL = tmpURL
        
        if CMTimeGetSeconds(avAsset.duration) > 20 {
            exporter.timeRange = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1000),
                                              end: CMTime(seconds: 20, preferredTimescale: 1000))
        }
    
        let compressionDict: [String: Any] = [
            AVVideoAverageBitRateKey: NSNumber(integerLiteral: 1500000),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel as String,
        ]
        exporter.videoOutputConfiguration = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(integerLiteral: 540),
            AVVideoHeightKey: NSNumber(integerLiteral: 960),
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            AVVideoCompressionPropertiesKey: compressionDict
        ]
        exporter.audioOutputConfiguration = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: NSNumber(integerLiteral: 64000),
            AVNumberOfChannelsKey: NSNumber(integerLiteral: 1),
            AVSampleRateKey: NSNumber(value: Float(44100))
        ]

        exporter.export(progressHandler: { (progress) in
            print(progress)
        }, completionHandler: { result in
            
            DispatchQueue.main.async {
                self.loading = false
                self.showingAlert = true
            }
            
            switch result {
            case .success(let status):
                switch status {
                case .completed:
                    print("NextLevelSessionExporter, export completed, \(exporter.outputURL?.description ?? "")")
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exporter.outputURL!)
                    }) { saved, error in
                        if saved {
                            print("Saved")
                        }
                    }
                    
                    break
                default:
                    print("NextLevelSessionExporter, did not complete")
                    break
                }
                break
            case .failure(let error):
                print("NextLevelSessionExporter, failed to export \(error)")
                break
            }
        })

    }
    
}
