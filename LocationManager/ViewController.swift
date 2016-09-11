//
//  ViewController.swift
//  LocationManager
//
//  Created by Ankit Thakur on 29/08/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import UIKit
import CoreLocation
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LocationManager.sharedInstance.listeningEvent { (location: Location?, error: LocationError?, event:EventType?) -> (Void) in
            logger("\(location?.json) : \(error) : \(event?.string)")
        }
        
        LocationManager.sharedInstance.getLocation(.userTrigger)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

