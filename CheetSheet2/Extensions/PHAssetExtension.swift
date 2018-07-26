//
//  PHAssetExtension.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/10/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL: URL?) -> Void)) {

        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) -> Void in
            completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
        })
    }

    func getPHAssetURL(completionHandler : @escaping ((_ responseURL: URL?) -> Void)) {

        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })

        } else if self.mediaType == .video {

            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable: Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }

}
