//
//  LocationManager.swift
//  LocationManager
//
//  Created by Ankit Thakur on 29/08/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import CoreLocation

/** LocationManager Class
 
 */

let minimumTriggerDuration:Double = 10*60 // in seconds


public enum EventType {
    case userTrigger
    case backgroundSignificant
    case visit
    case backgroundRefresh
    
    var string:String {
        var name:String = ""
        
        switch self {
        case .userTrigger:
            name = "UserTrigger"
        case .backgroundSignificant:
            name = "BackgroundSignificant"
        case .visit:
            name = "Visit"
        default:
            name = "Background Refresh"
            
        }
        
        return name
    }
    
}


public typealias LocationCallback =  (_ location:Location,  _ error:LocationError?, _ eventType:EventType?)->(Void)
open class LocationManager:NSObject {
    
    static let sharedInstance = LocationManager()
    
    open var locationCallback:LocationCallback?
    
    open func getLocation(_ event:EventType){
        LocationCoordinator.sharedInstance.getLocation(.userTrigger)
    }
    
    open func listeningEvent(callback:@escaping LocationCallback){
        
        LocationCoordinator.sharedInstance.listeningEvent { (location: CLLocation?, address:String?, error: LocationError?, event:EventType?) -> (Void) in
            logger("\(location) : \(address) : \(error) : \(event?.string)")
            
            let loc:Location = Location()
            loc.latitude = location?.coordinate.latitude
            loc.longitude = location?.coordinate.longitude
            loc.altitude = location?.altitude
            loc.horizontalAccuracy = location?.horizontalAccuracy
            loc.verticalAccuracy = location?.verticalAccuracy
            loc.direction = location?.course
            loc.speed = location?.speed
            loc.address = address
            if ((location?.timestamp) != nil){
                loc.timestamp = (location?.timestamp)!
            }
            else {
                loc.timestamp = Date()
            }
            loc.insertAndSave(queue: DispatchQueue.global())

            callback(loc, error, event)
        }
        
    }

    
}

