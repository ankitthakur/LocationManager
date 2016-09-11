//
//  LocationCoordinator.swift
//  LocationManager
//
//  Created by Ankit Thakur on 29/08/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import CoreLocation

/** LocationCoordinator Class
 
 */

let triggerQueue = "com.lm.backgroundTrigger"
internal typealias LocationCoorCallback =  (_ location:CLLocation?, _ address:String?,  _ error:LocationError?, _ eventType:EventType?)->(Void)

internal class LocationCoordinator:NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationCoordinator()
    
    var eventType:EventType?
    
    var manager:CLLocationManager?
    var currentLocation:CLLocation?
    var locationCallback:LocationCoorCallback?
    var isFinalLocation:Bool = false
    var lastLocationFetchTime:Date?
    var locationError:LocationError?
    
    fileprivate override init(){
        manager = CLLocationManager()
    }
    
    func findLocation(_ event:EventType){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            self?.eventType = event
            self?.manager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            logger("event : \(self?.eventType)")
            self?.startTracking()
        }
        
        
    }
    
    func getLocation(_ event:EventType){
        self.stopTracking()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            
            self?.eventType = event
            logger("event : \(self?.eventType)")
            self?.startTracking()
        }
        
        
    }
    
    func listeningEvent(callback:@escaping LocationCoorCallback){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            self?.locationCallback = callback
        }
        
        
    }
    
    func startTracking(){
        logger("startTracking")
        currentLocation = nil
        isFinalLocation = true
        manager?.delegate = nil
        manager?.stopMonitoringVisits()
        manager?.stopMonitoringSignificantLocationChanges()
        
        manager?.requestAlwaysAuthorization();
        manager?.requestWhenInUseAuthorization();
        
        if #available(iOS 9.0, *) {
            self.manager?.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.startUpdatingLocation()
        manager?.delegate = self
    }
    
    func startSignificantAndVisitTracking(){
        logger("startSignificantAndVisitTracking")
        manager?.requestAlwaysAuthorization();
        manager?.requestWhenInUseAuthorization();
        manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager?.delegate = self
        if #available(iOS 9.0, *) {
            self.manager?.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        manager?.startMonitoringVisits()
        manager?.startMonitoringSignificantLocationChanges()
    }
    
    
    func stopTracking(){
        logger("stopTracking")
        manager?.stopUpdatingLocation()
        
        startSignificantAndVisitTracking()
        isFinalLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        logger("locationManager didUpdateLocations")
        
        if (eventType != nil) {
            
            
            if isFinalLocation == false {
                startTracking()
            }
            else{
                if currentLocation == nil {
                    
                    logger("lastLocationFetchTime : \(lastLocationFetchTime)")
                    
                    if (lastLocationFetchTime == nil || Date().timeIntervalSince(lastLocationFetchTime!) > minimumTriggerDuration){
                        currentLocation = locations.last
                        //                        currentLocation?.verticalAccuracy
                        if (self.locationCallback != nil) {
                            
                            let coder:Geocoder = Geocoder()
                            coder.geocode(location: self.currentLocation!, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background), eventType: self.eventType!, callBack: self.locationCallback!)
                            
                            self.currentLocation = nil
                            self.lastLocationFetchTime = Date()
                            logger("updated lastLocationFetchTime : \(self.lastLocationFetchTime)")
                            
                            self.eventType = nil
                            self.stopTracking()
                        }
                    }
                    else{
                        let duration = (Date().timeIntervalSince(lastLocationFetchTime!))/60
                        logger("duration since last capture is \(duration) minutes")
                    }
                    
                }
                else{
                    self.currentLocation = nil
                    logger("updated lastLocationFetchTime : \(self.lastLocationFetchTime)")
                    
                    self.eventType = nil
                    self.stopTracking()
                }
                
                
            }
        }
        else{
            
            if (lastLocationFetchTime == nil || Date().timeIntervalSince(lastLocationFetchTime!) > minimumTriggerDuration){
                self.currentLocation = nil
                LocationManager.sharedInstance.getLocation(.backgroundSignificant)
            }
            else{
                let duration = (Date().timeIntervalSince(lastLocationFetchTime!))/60
                logger("locationManager significant event : duration since last capture is \(duration) minutes")
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        logger("locationManager didFailWithError error")
        
        if (self.locationCallback != nil) {
            DispatchQueue.main.async { [weak self] in
                self?.locationError = LocationError(kind: .noLocationFound, message: "no location is found")
                self?.locationCallback!(nil, nil, self?.locationError, self?.eventType)
                self?.currentLocation = nil
                self?.eventType = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit){
        logger("locationManager didVisit")
        if (lastLocationFetchTime == nil || Date().timeIntervalSince(lastLocationFetchTime!) > minimumTriggerDuration){
            self.currentLocation = nil
            
            LocationManager.sharedInstance.getLocation(.visit)
        }
        else{
            let duration = (Date().timeIntervalSince(lastLocationFetchTime!))/60
            logger("locationManager didVisit event : duration since last capture is \(duration) minutes")
        }
        
    }
}

