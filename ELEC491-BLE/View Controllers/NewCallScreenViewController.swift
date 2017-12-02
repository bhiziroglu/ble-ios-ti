//
//  NewCallScreenViewController.swift
//  ELEC491-BLE
//
//  Created by Cem Ergin on 2.12.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit
import AVFoundation

class NewCallScreenViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    var newRec = false
    var newPlay = false
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //sets up Audio Session
    func setupAudioSession() {
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.state = .noAction
                        self.stateChanged()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            print("Unable to initialize Audio Session")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        
        if success {
            print("Browsing directory")
            print(getDocumentsDirectory().absoluteString)
            print(FileManager.default.contents(atPath: getDocumentsDirectory().absoluteString))
            newRec = !newRec
        } else {
            print("Failed to Record Audio")
        }
        state = .noAction
        stateChanged()
    }
    
    //sets up Audio Recorder
    func setupAudioRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("output.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("Started Recording")
            state = .Recording
            stateChanged()
        } catch {
            finishRecording(success: false)
        }
    }
    
    //sets up Recording Session
    func setupPlayerSession() {
        newPlay = !newPlay
        let url = getDocumentsDirectory().appendingPathComponent("output.m4a")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished Playing")
        state = .noAction
        stateChanged()
    }
    
    //IBOutlets for buttons
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    //States for audio player
    enum playerState {
        case noAction
        case Playing
        case Stopped
        case Paused
        case Recording
    }
    
    var recActive = false
    
    //initial audio player state
    var state = playerState.noAction
    
    //Toggles Player's Button images when state changes
    func stateChanged(){
        switch state {
        case .noAction:
            pauseButton.setBackgroundImage(UIImage(named: "pause0"), for: .normal)
            stopButton.setBackgroundImage(UIImage(named: "stop0"), for: .normal)
            playButton.setBackgroundImage(UIImage(named: "play0"), for: .normal)
            recButton.setBackgroundImage(UIImage(named: "record0"), for: .normal)
        case .Playing:
            pauseButton.setBackgroundImage(UIImage(named: "pause0"), for: .normal)
            stopButton.setBackgroundImage(UIImage(named: "stop0"), for: .normal)
            playButton.setBackgroundImage(UIImage(named: "play1"), for: .normal)
            recButton.setBackgroundImage(UIImage(named: "record0"), for: .normal)
        case .Stopped:
            pauseButton.setBackgroundImage(UIImage(named: "pause0"), for: .normal)
            stopButton.setBackgroundImage(UIImage(named: "stop1"), for: .normal)
            playButton.setBackgroundImage(UIImage(named: "play0"), for: .normal)
            recButton.setBackgroundImage(UIImage(named: "record0"), for: .normal)
        case .Paused:
            pauseButton.setBackgroundImage(UIImage(named: "pause1"), for: .normal)
            stopButton.setBackgroundImage(UIImage(named: "stop0"), for: .normal)
            playButton.setBackgroundImage(UIImage(named: "play0"), for: .normal)
            recButton.setBackgroundImage(UIImage(named: "record0"), for: .normal)
        case .Recording:
            pauseButton.setBackgroundImage(UIImage(named: "pause0"), for: .normal)
            stopButton.setBackgroundImage(UIImage(named: "stop0"), for: .normal)
            playButton.setBackgroundImage(UIImage(named: "play0"), for: .normal)
            recButton.setBackgroundImage(UIImage(named: "record1"), for: .normal)
        }
    }
    
    //Sets up PLayer's Button images
    func setupToggleButton() {
        pauseButton.setBackgroundImage(UIImage(named: "pause0"), for: .normal)
        stopButton.setBackgroundImage(UIImage(named: "stop0"), for: .normal)
        playButton.setBackgroundImage(UIImage(named: "play0"), for: .normal)
        recButton.setBackgroundImage(UIImage(named: "record0"), for: .normal)
        sendButton.setBackgroundImage(UIImage(named: "send0"), for: .normal)
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        print("Pause Tapped")
        state = .Paused
        stateChanged()
        guard let player = player else { return }
       player.pause()
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        print("Stop Tapped")
        state = .Stopped
        stateChanged()
        guard let player = player else { return }
        player.stop()
        player.currentTime = 0
    }
    
    @IBAction func playTapped(_ sender: Any) {
        print("Play Tapped")
        state = .Playing
        stateChanged()
        if(newRec != newPlay) {
          setupPlayerSession()
        }
        else {
        guard let player = player else { return }
        player.play()
        }
    }
    
    @IBAction func recTapped(_ sender: Any) {
        print("Rec Tapped")
        if(!recActive) {
            print("Record Initializing")
            state = .Recording
            setupAudioRecorder()
        }
        else {
            state = .noAction
            if (audioRecorder != nil) {
                finishRecording(success: true)
                
            }
        }
        recActive = !recActive
        stateChanged()
    }
    
    var sendActive = true
    
    @IBAction func sendTapped(_ sender: Any) {
        print("Send Tapped")
        if(sendActive) {
            sendButton.setBackgroundImage(UIImage(named: "send1"), for: .normal)
        } else {
            sendButton.setBackgroundImage(UIImage(named: "send0"), for: .normal)
        }
        sendActive = !sendActive
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        setupAudioSession()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
