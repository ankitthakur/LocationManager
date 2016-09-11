//
//  Logger.swift
//  LocationManager
//
//  Created by Ankit Thakur on 11/09/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import CoreData

func dateFormatter(_ date:Date) -> String{
    /***** NSDateFormatter Part *****/
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    
    let dateString = formatter.string(from: date)
    return dateString
}

func logger(_ string:Any){
    
    
    let log:String = "\(string)"
    
    print("\(dateFormatter(Date())) -> \(log)")
    
    // Create Entity Description
    let entityDescription:NSEntityDescription?
    let context:NSManagedObjectContext = EncryptedDB.sharedInstance.backgroundContext!
    
    entityDescription = NSEntityDescription.entity(forEntityName: "LoggerEntity", in: context)
    
    
    let entity:LoggerEntity = LoggerEntity(entity: entityDescription!, insertInto: context)
    entity.log = log
    entity.dateString = (dateFormatter(Date()))
    
    
    do {
        try context.save()
        
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    
}

internal class LoggerEntity: NSManagedObject {
    public var log: String?
    public var dateString: String?
    
}

