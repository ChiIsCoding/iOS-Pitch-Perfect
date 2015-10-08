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
    var engine: AVAudioEngine!

    override func viewDidLoad() {
        super.viewDidLoad()

        engine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playSoundEffects(audioEffectValue: Float, audioEffectType: String) {
        audioPlayerNode = AVAudioPlayerNode()
        engine.stop()
        engine.reset()
        
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
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! engine.start()
        
        audioPlayerNode.play()
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
        audioPlayerNode.stop()
        engine.stop()
        engine.reset()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
