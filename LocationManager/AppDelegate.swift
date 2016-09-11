//
//  AppDelegate.swift
//  LocationManager
//
//  Created by Ankit Thakur on 29/08/16.
//  Copyright © 2016 Ankit Thakur. All rights reserved.
//

import UIKit
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /**
         The system guarantees that it will not wake up your application for a background fetch more
         frequently than the interval provided. Set to UIApplicationBackgroundFetchIntervalMinimum to be
         woken as frequently as the system desires
         */
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        
        logger(launchOptions);
        
        let options:[UIApplicationLaunchOptionsKey: Any]? = launchOptions as? [UIApplicationLaunchOptionsKey: Any]
        
        /*
         UIApplicationLaunchOptionsKey.location:
         this key indicates that the app was launched in response to an incoming location event. The value of this key is an NSNumber object containing a Boolean value. We use the presence of this key as a signal to create a CLLocationManager object and start location services again. Location data is delivered only to the location manager delegate and not using this key.
         */
        if options?[UIApplicationLaunchOptionsKey.location] != nil {
            LocationManager.sharedInstance.getLocation(.backgroundSignificant)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
    
    /// Implement this method if your app supports the fetch background mode. When an opportunity arises to download data, the system calls this method to give your app a chance to download any data it needs.
    private func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        LocationManager.sharedInstance.getLocation(.backgroundRefresh)
        
    }

}

