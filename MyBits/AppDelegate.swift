import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Crashlytics
        Fabric.with([Crashlytics.self])

        // Initialize DB and load data in memory
        DB.initialize()

        ///////////////////////////////////////////
        ///////////////////////////////////////////
        ///////////////////////////////////////////
//        class TestViewController: AllTransactionsProtocol, XpubProtocol {
//            let testAccountXpub: AccountXpub
//            init(testAccountXpub: AccountXpub) {
//                self.testAccountXpub = testAccountXpub
//                TransactionStore.register(self)
//                XpubStore.register(self, forXpub: testAccountXpub)
//            }
//            func transactionReceived(tx: BitcoinTx) {
//                print("Transaction \(tx.hash) received!")
//                print("Xpub balance: \(self.testAccountXpub.getBalance())")
//                for address in self.testAccountXpub.getAddresses() {
//                    let balance = address.getBalance()
//                    if balance.getSatoshiAmount() > 0 {
//                        print("\(address): \(address.getBalance())")
//                    }
//                }
//            }
//            func xpubReceivedNewAddress(xpub: AccountXpub, newAccountAddress: BitcoinAddress) {
//                print("Xpub got \(newAccountAddress)")
//            }
//        }
//        let testAccountXpub = AccountXpub(masterPublicKey: MasterPublicKey(value: "xpub6DJzLL3834dPK7zDAjTEWj6vYziA4Yu2t6VhARMudW8d1jkCGF58yUrkug7MVQQB7iNCCAhBKmPGZYZVf3MmTaunA7iCZXkHC5vdUnDvyxY"))
//        let _ = TestViewController(testAccountXpub: testAccountXpub)
//
//        do {
//            let testAccount = Account(accountName: "Test Account")
//            let testAccountAddress = AccountAddress(bitcoinAddress: BitcoinAddress(value: "1GDdV6DdaBq3mH1GjG1SQM9DsJZ3U1DVoV"))
//            try AccountStore.addAccount(testAccount)
//            try AccountStore.addAddress(testAccount, accountAddress: testAccountAddress)
//            try AccountStore.addXpub(testAccount, accountXpub: testAccountXpub)
//            try AccountStore.addAddress(testAccount, accountAddress: testAccountAddress) // Should error
//        } catch let e {
//            print("Error: \(e)")
//        }
        ///////////////////////////////////////////
        ///////////////////////////////////////////
        ///////////////////////////////////////////

        // Starts fetching transactions details
        TransactionFetcher().start()

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

