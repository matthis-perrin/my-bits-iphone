import UIKit

// Main tab bar of the application
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    var accountsController: UIViewController?
    var transactionsController: UIViewController?
    var settingsController: UIViewController?
    var moreController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func viewWillAppear(animated: Bool) {

        // Tab 1 - Accounts
        self.accountsController = MainNavigationController(rootViewController: AccountsViewController())
        let accountsTitle = NSLocalizedString("accounts", comment: "Tab bar menu to the accounts screen where the user manages his accounts.")
        let accountIcon = UIImage(named: "TabBar_Accounts")
        let accountsTabBarItem = UITabBarItem(title: accountsTitle, image: accountIcon, selectedImage: accountIcon)
        self.accountsController?.tabBarItem = accountsTabBarItem

        // Tab 2 - Transactions
        self.transactionsController = MainNavigationController(rootViewController: TransactionTableViewController())
        let transactionsTitle = NSLocalizedString("transactions", comment: "Tab bar menu to the main screen where the bitcoin transactions are listed.")
        let transactionsIcon = UIImage(named: "TabBar_Transactions")
        let transactionsTabBarItem = UITabBarItem(title: transactionsTitle, image: transactionsIcon,
            selectedImage: transactionsIcon)
        self.transactionsController?.tabBarItem = transactionsTabBarItem

        // Tab 3 - Settings
        self.settingsController = UIViewController()
        let settingsTitle = NSLocalizedString("settings", comment: "Tab bar menu to the settings screen.")
        let settingsIcon = UIImage(named: "TabBar_Settings")
        let settingsTabBarItem = UITabBarItem(title: settingsTitle, image: settingsIcon,
            selectedImage: settingsIcon)
        self.settingsController?.tabBarItem = settingsTabBarItem

        // Tab 4 - More
        self.moreController = UIViewController()
        let moreTitle = NSLocalizedString("more", comment: "Tab bar menu to the more screen with all additional possible actions.")
        let moreTabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.More, tag: 0)
        moreTabBarItem.title = moreTitle
        self.moreController?.tabBarItem = moreTabBarItem

        // Attach the tabs
        self.viewControllers = [
            self.accountsController!,
            self.transactionsController!,
            self.settingsController!,
            self.moreController!
        ]

    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let enabledTabs = [
            self.accountsController,
            self.transactionsController
        ]
        return enabledTabs.contains({ controller in
            return controller != nil && controller == viewController
        })
    }

}