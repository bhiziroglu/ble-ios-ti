//
//  BLEHandler.swift
//  ELEC491-BLE
//
//  Created by Berkan on 13.11.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEHandler: NSObject, CBCentralManagerDelegate , CBPeripheralDelegate{
    
    var per:CBPeripheral!
   
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unsupported:
            print("BLE - Unsupported!")
        case .poweredOff:
            print("BLE - Powered Off!")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "POWEROFF"), object: nil)
        case .poweredOn:
            print("BLE - Powered On!")
            print("Start scanning...")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "POWERON"), object: nil)
            central.scanForPeripherals(withServices: nil, options: nil)
        case .resetting:
            print("BLE - resetting!")
        case .unauthorized:
            print("BLE - unauth!")
        case .unknown:
            print("BLE - unknown!")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didDisconnect"), object: peripheral)
        central.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnectPeripheral")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didConnect"), object: peripheral)
        per = peripheral
        per.delegate = self
        per.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
        let res = ["name":peripheral, "error":error!] as NSDictionary
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFail"), object: res)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("\(String(describing: peripheral.name)) : \(RSSI) dBm")
        let res = ["name":peripheral, "rssi":RSSI, "per":peripheral]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didDiscover"), object: res)
    }
    
    
    override init() {
        super.init()
        
        
    }
    
    
    
    
    
    
    
    
    
    ////PERIPHERAL DELEGATE////////
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            print("error: \(error)")
            return
        }
        let services = peripheral.services
        print("Found \(services?.count) services! :\(services)")
    
        //time to discover characteristic
        for service in services! {
            //for each char
            per.discoverCharacteristics(nil, for: service)
        }
        
        
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics?.count) characteristics!")
        
        
        // SEND THE CHARACTERISTICS TO VIEW CONTROLLER TO WRITE //
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didDiscoverCharacteristics"), object: characteristics)
        
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print(" DID WRITE VALUE ? ")
        print(descriptor)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(" DID UPDATE VALUE ? ")
        print(characteristic)
    }
    
    
}
