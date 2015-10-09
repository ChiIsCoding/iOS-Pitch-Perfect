//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Chi Zhang on 10/4/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var receivedAudio: RecordedAudio!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    lazy var engine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            audioFile = try AVAudioFile(forReading: receivedAudio.filePathUrl)
        } catch {
            print("Cannot find audio to play")
        }

    }
    
    private func playSoundEffects(audioEffectValue: Float, audioEffectType: String) {
        // Connect audio player node and audio effect node to audio engine
        audioPlayerNode = AVAudioPlayerNode()
        
        if engine.running {
            engine.stop()
            engine.reset()
        }
        
        engine.attachNode(audioPlayerNode)
        
        let audioEffect = AVAudioUnitTimePitch()
        if audioEffectType == "rate" {
            audioEffect.rate = audioEffectValue
        } else {
            audioEffect.pitch = audioEffectValue
        }
        
        engine.attachNode(audioEffect)
        engine.connect(audioPlayerNode, to: audioEffect, format: nil)
        engine.connect(audioEffect, to: engine.outputNode, format: nil)
        
        // Prepare and play audio
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
            try engine.start()
            audioPlayerNode.play()
        } catch {
            print("Cannot start audio player")
        }
        
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playSoundEffects(0.5, audioEffectType: "rate")
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playSoundEffects(1.5, audioEffectType: "rate")
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playSoundEffects(1000, audioEffectType: "pitch")
    }

    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playSoundEffects(-1000, audioEffectType: "pitch")
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        
        if audioPlayerNode.playing {
            audioPlayerNode.stop()
        }
        
        if engine.running {
            engine.stop()
            engine.reset()
        }

    }

}
