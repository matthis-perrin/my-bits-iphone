import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    var transactionsController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override func viewWillAppear(animated: Bool) {

        // Tab 1 - Transactions
        transactionsController = ViewController()
        let transactionsTitle = NSLocalizedString("transactions", comment: "Tab bar menu to the main screen where the bitcoin transactions are listed.")
        let transactionsIcon = UIImage(named: "TabBar_Transactions")
        let transactionsTabBarItem = UITabBarItem(title: transactionsTitle, image: transactionsIcon,
            selectedImage: transactionsIcon)
        transactionsController?.tabBarItem = transactionsTabBarItem

        // Tab 2 - Addresses
        let addressesController = UIViewController()
        let addressesTitle = NSLocalizedString("addresses", comment: "Tab bar menu to the addresses screen where the user manages his addresses/xpub.")
        let addressIcon = UIImage(named: "TabBar_Addresses")
        let addressesTabBarItem = UITabBarItem(title: addressesTitle, image: addressIcon,
            selectedImage: addressIcon)
        addressesController.tabBarItem = addressesTabBarItem

        // Tab 3 - Settings
        let settingsController = UIViewController()
        let settingsTitle = NSLocalizedString("settings", comment: "Tab bar menu to the settings screen.")
        let settingsIcon = UIImage(named: "TabBar_Settings")
        let settingsTabBarItem = UITabBarItem(title: settingsTitle, image: settingsIcon,
            selectedImage: settingsIcon)
        settingsController.tabBarItem = settingsTabBarItem

        // Tab 4 - More
        let moreController = UIViewController()
        let moreTitle = NSLocalizedString("more", comment: "Tab bar menu to the more screen with all additional possible actions.")
        let moreTabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.More, tag: 0)
        moreTabBarItem.title = moreTitle
        moreController.tabBarItem = moreTabBarItem

        // Attach the tabs
        self.viewControllers = [transactionsController!, addressesController, settingsController, moreController]
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return viewController == transactionsController
    }

}