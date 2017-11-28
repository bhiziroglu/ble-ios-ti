//
//  BLERequired.swift
//  ELEC491-BLE
//
//  Created by Berkan on 14.11.2017.
//  Copyright © 2017 Berkan. All rights reserved.
//

import UIKit

class BLERequired: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.powerTurnedOn), name: NSNotification.Name(rawValue: "POWERON"), object: nil)
        
        
        //Add label
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 50))
        label.textAlignment = .center
        label.numberOfLines=0
        label.font = UIFont(name: "Helvetica-Bold", size: 12)
        label.textColor = UIColor.white
        label.backgroundColor=UIColor.blue
        label.text = "BLUETOOTH IS REQUIRED TO USE THE APPLICATION"
        self.view.addSubview(label)
        
        // Do any additional setup after loading the view.
    }

    
    @objc func powerTurnedOn(notif: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
