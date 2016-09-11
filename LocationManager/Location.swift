//
//  Location.swift
//  LocationManager
//
//  Created by Ankit Thakur on 11/09/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import  CoreData

public class Location {
    
    open var latitude: Double?
    open var longitude: Double?
    open var altitude: Double?
    open var horizontalAccuracy: Double?
    open var verticalAccuracy: Double?
    open var direction: Double?
    open var speed: Double?
    open var address:String?
    
    var timestamp: Date = Date()
    
    lazy var json:String = {
        return "{latitude:\(self.latitude),longitude:\(self.longitude),altitude:\(self.altitude),horizontalAccuracy:\(self.horizontalAccuracy),verticalAccuracy:\(self.verticalAccuracy),direction:\(self.direction),speed:\(self.speed),address:\(self.address)}"
    }()
    
    
    open class func allLocations(queue:DispatchQueue) -> [Location]{
        
        guard let result:[LocationEntity] = Location.locationEntities(queue: queue) else{
            return []
        }
        
        var locations:[Location] = []
        
        for entity in result {
            let location:Location = Location.locationFromEntity(entity: entity)
            locations.append(location)
            
        }
        return locations
    }
    
    open func insertAndSave(queue:DispatchQueue) {
        insertInDB(queue: queue)
        
    }
    
    fileprivate class func locationFromEntity(entity:LocationEntity) -> Location{
        
        let location:Location = Location()
        location.latitude = entity.latitude
        location.longitude = entity.longitude
        location.altitude = entity.altitude
        location.horizontalAccuracy = entity.horizontalAccuracy
        location.verticalAccuracy = entity.verticalAccuracy
        location.direction = entity.direction
        location.speed = entity.speed
        location.address = entity.address
        location.timestamp = entity.timestamp as! Date
        
        return location
    }
    
    fileprivate class func locationEntities(queue:DispatchQueue) -> [LocationEntity]?{
        
        var result:[LocationEntity]?
        
        // Create Entity Description
        let entityDescription:NSEntityDescription?
        let context:NSManagedObjectContext?
        
        if queue == DispatchQueue.main {
            context = EncryptedDB.sharedInstance.managedObjectContext
        }
        else{
            context = EncryptedDB.sharedInstance.backgroundContext
            
        }
        entityDescription = NSEntityDescription.entity(forEntityName: "LocationEntity", in: context!)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<LocationEntity>()
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            result = try context!.fetch(fetchRequest)
            logger(result)
            
        } catch {
            let fetchError = error as NSError
            logger(fetchError)
        }
        
        return result
    }
    
    fileprivate func insertInDB(queue:DispatchQueue){
        
        
        // Create Entity Description
        let entityDescription:NSEntityDescription?
        let context:NSManagedObjectContext?
        
        if queue == DispatchQueue.main {
            context = EncryptedDB.sharedInstance.managedObjectContext
        }
        else{
            context = EncryptedDB.sharedInstance.backgroundContext
            
        }
        entityDescription = NSEntityDescription.entity(forEntityName: "LocationEntity", in: context!)
        
        
        let entity:LocationEntity = LocationEntity(entity: entityDescription!, insertInto: context!)
        entity.latitude = self.latitude
        entity.longitude = self.longitude
        entity.altitude = self.altitude
        entity.horizontalAccuracy = self.horizontalAccuracy
        entity.verticalAccuracy = self.verticalAccuracy
        entity.direction = self.direction
        entity.speed = self.speed
        entity.address = self.address
        entity.timestamp = self.timestamp as NSDate?
        
        
        do {
            try context?.save()
            
        } catch {
            let fetchError = error as NSError
            logger(fetchError)
        }
        
    }
}

internal class LocationEntity: NSManagedObject {
    public var latitude: Double?
    public var longitude: Double?
    public var altitude: Double?
    public var horizontalAccuracy: Double?
    public var verticalAccuracy: Double?
    public var direction: Double?
    public var speed: Double?
    public var address: String?
    public var timestamp: NSDate?

}
