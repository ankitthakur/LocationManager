//
//  Geocoder.swift
//  LocationManager
//
//  Created by Ankit Thakur on 11/09/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import CoreLocation


let GEOCODER_TIMEOUT = 10 // in seconds

public struct LocationError: Error {
    enum ErrorKind {
        case noAddress
        case reverseGeocode
        case noLocationFound
    }
    let kind: ErrorKind
    let message:String
}

internal class Geocoder: NSObject {
    
    var userLocation:CLLocation?
    var locationCallback: LocationCoorCallback?
    var geoCoder:CLGeocoder?
    var address:String = ""
    var event:EventType?
    var locationError:LocationError?
    
    func geocode(location:CLLocation, queue:DispatchQueue, eventType:EventType, callBack:@escaping LocationCoorCallback){
        
        userLocation = location
        locationCallback = callBack
        event = eventType
        
        geoCoder = CLGeocoder()
        
        
        let group: DispatchGroup = DispatchGroup()
        
        group.enter()
        
        let timeout:DispatchTime = DispatchTime(uptimeNanoseconds: UInt64(GEOCODER_TIMEOUT*1000))
        
        geoCoder?.reverseGeocodeLocation(userLocation!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
            
            if error != nil {
                logger("Reverse geocoder failed with error: \(error!.localizedDescription)")
                self.locationError = LocationError(kind: .reverseGeocode, message: (error?.localizedDescription)!)
                //                completion("[\(location.coordinate.latitude), \(location.coordinate.longitude)]")
            }
            if let placemarks = placemarks , placemarks.count > 0 {
                let placemark = placemarks[0]
                self.address = self.formalizedPlace(placemark: placemark)
                
            } else {
                self.locationError = LocationError(kind: .noAddress, message: "no placemark is found")
            }
            group.leave()
        })
        
        _ = group.wait(timeout: timeout)
        
        
        group.notify(queue: queue) {
            queue.async {
                self.locationCallback!(self.userLocation, self.address, nil, self.event)
            }
        }
        
        
    }
    
    func formalizedPlace(placemark: CLPlacemark) -> String {
        let joiner = "|"
        if let lines = placemark.addressDictionary!["FormattedAddressLines"] as? [String] {
            return lines.joined(separator: joiner)
        }else{
            return ""
        }
    }
    
    
    
}
