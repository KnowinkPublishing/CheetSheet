//
//  SoundManager.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/28/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioType {
    case wav
    case mp3
}

class SoundManager {

    var player: AVAudioPlayer?

    func playSound(_ soundPath: URL, _ myAudioType: AudioType) {

        do {
            self.player = try AVAudioPlayer(contentsOf: soundPath)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
}
