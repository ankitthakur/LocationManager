# LocationManager
CLLocation based events and reverse geocoding

```swift
// getting event at particular minimum interval, which is set in LocationManager.swift class `minimumTriggerDuration`
LocationManager.sharedInstance.listeningEvent { (location: Location?, error: LocationError?, event:EventType?) -> (Void) in
    logger("\(location?.json) : \(error) : \(event?.string)")
}
        
LocationManager.sharedInstance.getLocation(.userTrigger)
```

* Setting interval to get trigger
```swift 
# In LocationManager.swift

let minimumTriggerDuration:Double = 5*60 // in seconds : 5 minutes

```

* Storing of Locations and Logs in DB 

For safety usage, I have used encrypted Sqlite 
https://github.com/ankitthakur/encrypted-core-data/

So for background trigger, if we will not be able to view the logs on console, then also don't worry, just open the DB and read the debug logs.


Pre-requisites

1. In AppDelegate.m, we need to add below code:
``` swift
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
  
/// Implement this method if your app supports the fetch background mode. When an opportunity arises to download data, the system calls this method to give your app a chance to download any data it needs.
  private func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
      
      LocationManager.sharedInstance.getLocation(.backgroundRefresh)
      
  }  
  ```
