//
//  EncryptedDB.swift
//  LocationManager
//
//  Created by Ankit Thakur on 07/09/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import Foundation
import EncryptedCoreData
import CoreData

class EncryptedDB: NSObject {
    
    private let key = "sample"
    let storeFileName = "SampleFile.sqlite"
    
    static let sharedInstance = EncryptedDB()
    
    
    lazy var applicationDocumentsDirectory:URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
//        let modelURL = Bundle(for: self.dynamicType).url(forResource: "store", withExtension: "momd")
        let modelURL = Bundle.main.url(forResource: "LocationManager", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory!.appendingPathComponent("SampleFile.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            return nil
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // Returns the background object context for the application.
    // You can use it to process bulk data update in background.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        return backgroundContext
    }()

    
    // save NSManagedObjectContext
    func saveContext (context: NSManagedObjectContext) {
        var error: NSError? = nil
        if context.hasChanges {
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func saveContext () {
        self.saveContext( context: self.backgroundContext! )
    }
}
