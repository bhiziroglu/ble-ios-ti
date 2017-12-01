//
//  ViewController.swift
//  ELEC491-BLE
//
//  Created by Berkan on 13.11.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("NEW PERIPHERAL STATUS")
        print(peripheral.state)
    }
    
    
    
    @IBAction func refresh(_ sender: Any) {
        bleManager.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    @IBAction func stop(_ sender: Any) {
        if(isConnected){
            bleManager.centralManager.cancelPeripheralConnection(blePeripheral!)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var bleManager = BLEManager()
    var bleReqScreen = BLERequired()
    var blePeripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager?
    let LedServiceUUID = CBUUID(string: "0xFFF1")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        
        //Table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource=self
        tableView.delegate=self
        
        
        
        //List of listeners
        
        //PowerON Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.powerTurnedOn), name: NSNotification.Name(rawValue: "POWERON"), object: nil)
        
        
        //PowerOFF Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.powerTurnedOff), name: NSNotification.Name(rawValue: "POWEROFF"), object: nil)
        
        
        //Discover Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDiscover), name: NSNotification.Name(rawValue: "didDiscover"), object: nil)
        
        
        //Connection Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didConnect), name: NSNotification.Name(rawValue: "didConnect"), object: nil)
        
        
        //Connection Fail Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFail), name: NSNotification.Name(rawValue: "didFail"), object: nil)
        
        //Disconnect Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnect), name: NSNotification.Name(rawValue: "didDisconnect"), object: nil)
        
        
        //Characteristics Listener
        //Connection Fail Listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDiscoverCharacteristics), name: NSNotification.Name(rawValue: "didDiscoverCharacteristics"), object: nil)
        
        
    }
    
    var discovered: [CBPeripheral] = []
    
    @objc func didDiscoverCharacteristics(notif: NSNotification){
        let chars = notif.object as! [CBCharacteristic]?
        
        print("LISTING FOUND CHARACTERISTICS")
        
        // RED LED - UUID : F0001111-0451-4000-B000-000000000000
        // GREEN LED - UUID : F0001112-0451-4000-B000-000000000000
        
        for ch in chars! {
            print(ch.uuid.uuidString)
            if (ch.uuid.uuidString == "F0001112-0451-4000-B000-000000000000"){
                
                var parameter = NSInteger(1)
                let data = NSData(bytes: &parameter, length: 1)
                
                blePeripheral.writeValue(data as Data, for: ch, type: CBCharacteristicWriteType.withResponse)
            }
            
        }
        
    }
    
    
    @objc func didDisconnect(notif: NSNotification){
        print("DISCONNECTED")
        isConnected=false
        
    }
    
    @objc func didFail(notif: NSNotification){
        print("COULD NOT CONNECT TO")
        let res = notif.object as! NSDictionary
        let name = res["name"]
        let error = res["error"]
        print(name!)
        print("ERROR +>")
        print(error!)
        
    }
    
    var isConnected = false
    var connectedTo:CBPeripheral? = nil
    var services:[CBService] = []
    var targetName:String = ""
    
    
    @objc func didConnect(notif: NSNotification){
        isConnected=true
        print("CONNECTED TO PERIPHERAL")
        blePeripheral.discoverServices(nil)
        print( "DISCOVERING SERVICES...")
        //bleManager.centralManager.stopScan() //Stop scan
    
        //Set Target Name
        let target = notif.object as! CBPeripheral
        targetName = target.name!
        performSegue(withIdentifier: "callSegue", sender: self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                print("LISTING CHARS")
                print(characteristic)
                if characteristic.properties.contains([.write]),characteristic.uuid.uuidString == "0xFFF0" {
                    
                    print("led control: \(characteristic)")
                    
                    var parameter = NSInteger(1)
                    let data = NSData(bytes: &parameter, length: 1)
                    
                    peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    
    
    /*
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("DID DISCOVER CHARACTERISTICS?")
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            if thisCharacteristic.uuid == LedServiceUUID {
                print("sd")
            }
        }
    }*/

    @objc func didDiscover(notif: NSNotification){
        let res = notif.object as! [String:AnyObject]
        let name = res["name"]
        let rssi = res["rssi"]
        
        print("DID DISCOVER")
        
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        /*
        
        let current = res["name"] as! CBPeripheral //Assign the discovered peripheral as our peripheral
        
        if(current.name == "SimpleBLEPeripheral"){
            blePeripheral = current
            blePeripheral.delegate = self //Assign the delegate as self
        }
        
        */
        /*
        
        print(name!)
        print(rssi!)
 
 */
        if(!discovered.contains(name as! CBPeripheral)){
            discovered.append(name as! CBPeripheral)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    
    @objc func powerTurnedOn(notif: NSNotification) {
        print("VIEW CONT - BLE ON")
    }
    
    @objc func powerTurnedOff(notif: NSNotification) {
        print("VIEW CONT - BLE OFF")
        self.bleReqScreen.modalPresentationStyle = .overCurrentContext
        self.present(bleReqScreen, animated: true, completion: nil)
    }

    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TRYING TO CONNECT TO")
        print(discovered[indexPath.row])
        
        self.bleManager.centralManager.stopScan() //stop scanning
        self.blePeripheral = discovered[indexPath.row]
        blePeripheral.delegate = bleManager.bleHandler
        bleManager.centralManager.connect(blePeripheral, options: nil)
        
        
    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discovered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        //cell.textLabel?.text = discovered[indexPath.row].identifier.uuidString
        cell.textLabel?.text = discovered[indexPath.row].name
        cell.backgroundColor = UIColor.gray
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "callSegue") {
            let vc = segue.destination as! CallScreenViewController
            vc.navigationItem.title = targetName
        }
    }
}

