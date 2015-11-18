import UIKit

class AccountNameViewController: UIViewController, BackButton {

    let shouldDisplayBackButton = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("new account", comment: "")
        self.view.backgroundColor = UIColor.whiteColor()
    }

}