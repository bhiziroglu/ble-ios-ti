//
//  BLEManager.swift
//  ELEC491-BLE
//
//  Created by Berkan on 13.11.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager {
    var centralManager:CBCentralManager!
    var bleHandler : BLEHandler //delegate
    
    init(){
        self.bleHandler = BLEHandler()
        self.centralManager = CBCentralManager(delegate: self.bleHandler, queue: nil)
    }
    
    
    
    //We added a local variable of type CBCentralManager
    //We added a local variable of type BLEHandler which acts as a delegate (Note: we will create this class in a minute)
    //We initialize the ble handler
    //And finally we initialize the central manager
}
