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
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    // Enum of UI states (after hitting different buttons)
    private enum UIState {
        case Stopped
        case Recording
        case Paused
        case Restarted
    }
    
    // recording state represents one case of UI states
    private var recordingState = UIState.Stopped {
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
        case .Restarted:
            stopButton.hidden = true
            recordButton.enabled = true
            pauseButton.hidden = true
            continueButton.hidden = true
            restartButton.hidden = true
            tapToRecord.hidden = false
            recordingInProcess.hidden = true
            paused.hidden = true
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
            print("Cannot set audio recorder session")
        }
        
        // initialize and prepare the recorder
        do {
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            print("Cannot initialize recorder with path")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if recordingState == .Stopped {

                recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
                
                // Move to the next scene aka perform segue
                self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
                
            } else {
                // Do not perform any action here (hit restart button case)
            }
        } else {
            print("Recording was not successful!")
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
        recordingState = .Restarted
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
            print("Cannot release audio session")
        }
    }
}

