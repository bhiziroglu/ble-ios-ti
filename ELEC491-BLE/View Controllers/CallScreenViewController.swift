//
//  CallScreenViewController.swift
//  ELEC491-BLE
//
//  Created by Berkan on 1.12.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit
import AVFoundation


class CallScreenViewController: UIViewController, AVAudioRecorderDelegate {

    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        
    }
    
    
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 328, height: 64))
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(recordButton)
    }
    
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        //audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            print("Browsing directory")
            print(getDocumentsDirectory().absoluteString)
            print(FileManager.default.contents(atPath: getDocumentsDirectory().absoluteString))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
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
//            let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
//            backgroundQueue.async {
//                while(self.audioRecorder.isRecording){
//                    sleep(2)
//                    print("RECORDING...")
//
//                }
//            }
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
}
