//
//  CallScreenViewController.swift
//  ELEC491-BLE
//
//  Created by Berkan on 1.12.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth
import Speech


class CallScreenViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var listenButton: UIButton!
    
    
    var blePeripheral: CBPeripheral!
    // DATA - SERVICE CHAR UUID : F0001132-0451-4000-B000-000000000000
    var dataService: CBCharacteristic!
    
    @IBAction func listenTapped(_ sender: Any) {
        print("Listen Tapped")
        playSound()
    }
    
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Data service char listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataServiceChar), name: NSNotification.Name(rawValue: "dataServiceChar"), object: nil)
        
        
        
        
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
        //recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 328, height: 64))
        //recordButton.setTitle("Tap to Record", for: .normal)
        //recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(recordButton)
    }
    
    
    
    
    
    @objc func dataServiceChar(notif: NSNotification) {
        dataService = notif.object as! CBCharacteristic
        print("DATA CHAR SET !!")
        
        
        
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
    
    
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    
    
    func sendRecording() {
        print("Trying to Send Recording to TI - CC2640R2F")
        
//         DispatchQueue.main.async {
//        let url = self.getDocumentsDirectory().appendingPathComponent("output.m4a")
//        let par = NSData(contentsOf: url)
//
//        let count = (par?.length)! / 1
//
//        for i in 0...(count-1) {
//            let ananas = par?.subdata(with: NSRange.init(location: i, length: 1))
//            self.blePeripheral.writeValue(ananas as! Data, for: self.dataService, type: CBCharacteristicWriteType.withResponse)
//        }
//
//        }
        print("Speec-to-Text")
        
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        //audioRecorder = nil
        
        if success {
            
            DispatchQueue.main.async { //Use second thread to send the data
                self.sendRecording()
            }
            
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
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

            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    

    
    var player: AVAudioPlayer?
    
    func playSound() {
        let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
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
    }
}
