import UIKit

// UINavigationController that is the starting point for the "Transactions" screen.
// This controller is used by the MainTabBarController.
class TransactionsViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.tintColor = UIColor.redColor()
        self.pushViewController(TransactionsListViewController(), animated: false)
    }

}