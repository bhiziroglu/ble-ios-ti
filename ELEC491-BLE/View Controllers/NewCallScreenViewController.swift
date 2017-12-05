//
//  NewCallScreenViewController.swift
//  ELEC491-BLE
//
//  Created by Cem Ergin on 2.12.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth
import DataCompression

class NewCallScreenViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    //BLUETOOTH
    
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
    // DATA - SERVICE CHAR UUID : F0001132-0451-4000-B000-000000000000
    var blePeripheral: CBPeripheral!
    var dataService: CBCharacteristic!
    var dataService2: CBCharacteristic!
    
    @objc func dataServiceChar(notif: NSNotification) {
        dataService = notif.object as! CBCharacteristic
        print("DATA CHAR SET!!")
    }
    
    @objc func didUpdateValue(notif: NSNotification){
        let dd = notif.object as! CBCharacteristic
        print(dd.value)
    }
    
    func sendRecording() {
        print("Trying to Send Recording to TI - CC2640R2F")
        DispatchQueue.main.async {
            let url = self.getDocumentsDirectory().appendingPathComponent("output.m4a")
            let par = NSData(contentsOf: url)
            let count = (par?.length)! / 2
            for i in 0...(count-1) {
                let ananas = par?.subdata(with: NSRange.init(location: i, length: 2))
                self.blePeripheral.writeValue(ananas as! Data, for: self.dataService, type: CBCharacteristicWriteType.withResponse)
            }
            
        }
    }
    
    func sendByte() {
        print("Trying to Send Byte to TI - CC2640R2F")
        DispatchQueue.main.async {
            let par = NSData(contentsOfFile: "A")
            self.blePeripheral.writeValue(par! as Data, for: self.dataService, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    //AUDIO
    
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
            AVSampleRateKey: 16000,
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
    
    //UI
    
    //IBOutlets for buttons
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var toggleButton: UISwitch!
    
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

    @IBAction func toggleTapped(_ sender: Any) {
        print("Toggle Changed")
        if toggleButton.isOn {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateValue), name: NSNotification.Name(rawValue: "didUpdateValue"), object: nil)}
        else {
            NotificationCenter.default.removeObserver(self , name: NSNotification.Name(rawValue: "didUpdateValue"), object: nil)
        }
        
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
         let url = getDocumentsDirectory().appendingPathComponent("output.m4a")
         let url2 = getDocumentsDirectory().appendingPathComponent("compressed.m4a")
            do {
                var fileSize : UInt64
                let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                print("File size: \(fileSize)")
                
                let fileData = try Data.init(contentsOf: url)
                let compressedData = fileData.compress(withAlgorithm: .LZFSE)
                try compressedData?.write(to: url2)
                let attr2 = try FileManager.default.attributesOfItem(atPath: url2.path)
                fileSize = attr2[FileAttributeKey.size] as! UInt64
                print("Compressed size: \(fileSize)")
            } catch {
                print("File Size Cannot Be Calculated: \(error)")
            }
        sendByte()
        if(sendActive) {
            sendButton.setBackgroundImage(UIImage(named: "send1"), for: .normal)
        } else {
            sendButton.setBackgroundImage(UIImage(named: "send0"), for: .normal)
        }
        sendActive = !sendActive
    }
    
    //LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        setupAudioSession()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
