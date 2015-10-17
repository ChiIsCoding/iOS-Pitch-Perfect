//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Chi Zhang on 10/3/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProcess: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tapToRecord: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var paused: UILabel!
    private var isRestarted: Bool = false
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    // Enum of UI states (after hitting different buttons)
    private enum RecorderState {
        case Stopped
        case Recording
        case Paused
    }
    
    // recording state represents one case of UI states
    private var recordingState = RecorderState.Stopped {
        didSet {
            updateUIButtons()
            }
        }
    
    private func updateUIButtons() {
        switch recordingState {
        case .Stopped:
            stopButton.hidden = true
            recordButton.enabled = true
            pauseButton.hidden = true
            continueButton.hidden = true
            restartButton.hidden = true
            tapToRecord.hidden = false
            recordingInProcess.hidden = true
            paused.hidden = true
        case .Recording:
            stopButton.hidden = false
            recordButton.enabled = false
            pauseButton.hidden = false
            continueButton.hidden = true
            restartButton.hidden = false
            tapToRecord.hidden = true
            recordingInProcess.hidden = false
            paused.hidden = true
        case .Paused:
            stopButton.hidden = false
            recordButton.enabled = false
            pauseButton.hidden = true
            continueButton.hidden = false
            restartButton.hidden = false
            tapToRecord.hidden = true
            recordingInProcess.hidden = true
            paused.hidden = false
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        isRestarted = false
        recordingState = .Stopped
    }

    @IBAction private func recordAudio(sender: UIButton) {
        recordingState = .Recording
        
        // set audio file path
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // setup audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            NSLog("session.setCategory failed. Cannot set audio recorder session")
        }
        
        // initialize and prepare the recorder
        do {
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            NSLog("Cannot initialize recorder with path \(filePath)")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if !isRestarted {

                recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
                
                // Move to the next scene aka perform segue
                self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
                
            } else {
                isRestarted = false
            }
        } else {
            NSLog("Recording was not successful!")
            recordingState = .Stopped
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    @IBAction func pauseAudio(sender: UIButton) {
        recordingState = .Paused
        audioRecorder.pause()
    }
    
    @IBAction func continueAudio(sender: UIButton) {
        recordingState = .Recording
        audioRecorder.record()
    }
    
    @IBAction func restartAudio(sender: UIButton) {
        recordingState = .Stopped
        isRestarted = true
        audioRecorder.stop()
        
        // release audio session
        releaseAudioSession()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordingState = .Stopped
        audioRecorder.stop()
        
        releaseAudioSession()
        
    }
    
    private func releaseAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            NSLog("Cannot release audio session")
        }
    }
}

