import UIKit
import Fabric
import Crashlytics
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Crashlytics
        Fabric.with([Crashlytics.self])

        // Initialize user data (user_id and device_id)
        // TODO: Move this somewhere else
        // --------------------------------------------
//        do {
//            if let userId = try UserKeychain.getUserId() {
//                NSLog("User id (from keychain): \(userId)")
//                let realm = try! Realm()
//                let localData = realm.objects(LocalData).first
//                if let deviceId = localData?.deviceId {
//                    NSLog("Device id (from cache): \(deviceId)")
//                } else {
//                    Server.registerDevice(userId) { deviceId, error in
//                        if let deviceId = deviceId {
//                            NSLog("Device id (from api): \(deviceId)")
//                        } else if let error = error {
//                            NSLog(String(error.description))
//                        }
//                    }
//                }
//            } else {
//                Server.registerUser() { userId, error in
//                    if let userId = userId {
//                        NSLog("User id (from api): \(userId)")
//                        do {
//                            try UserKeychain.setUserId(userId)
//                        } catch {
//                            NSLog("Error while storing user_id %s", userId)
//                        }
//                    } else if let error = error {
//                        NSLog(String(error.description))
//                    }
//                }
//            }
//        } catch  {
//            NSLog("Can't access keychain")
//        }
        // --------------------------------------------

        // Starts the price fetcher that will pull the bitcoin price on a
        // regular basis and broadcast price changes to all listeners
        PriceFetcher().start()

        // Initialize the application (Mostly, the MainTabBarController)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            window.backgroundColor = UIColor.whiteColor()
            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

