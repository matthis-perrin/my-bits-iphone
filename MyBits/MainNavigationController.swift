import UIKit

class MainNavigationController : UINavigationController, PrivacyProtocol {

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        self.setNavigationButtonsToViewController(viewController)
        super.pushViewController(viewController, animated: animated)
    }

    private func setNavigationButtonsToViewController(vc: UIViewController) {
        // Left item (Privacy) -> only if not displaying back button
        if self.viewControllers.count == 0 || self.viewControllers[0] == vc {
            let icon = UIImage(named: "TopBar_Privacy.png")
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, landscapeImagePhone: icon, style: .Plain, target: self, action: "togglePrivacy")
        }

        // Right item (Bitcoin price)
        let label = UICurrencyLabel(fromBitcoin: 1.0, displayCurrency: .Fiat)
        label.frame = CGRectMake(0, 0, 100, 20)
        label.setRespectPrivacy(false)
        label.textAlignment = .Right
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }

    override func viewWillAppear(animated: Bool) {
        PrivacyStore.register(self)
        updatePrivacyButton()
    }

    override func viewDidDisappear(animated: Bool) {
        PrivacyStore.unregister(self)
        updatePrivacyButton()
    }

    func privacyDidChange() {
        updatePrivacyButton()
    }

    @objc private func togglePrivacy() {
        PrivacyStore.setPrivacy(!PrivacyStore.getPrivacy())
    }

    private func updatePrivacyButton() {
        if let vc = self.visibleViewController {
            let color = PrivacyStore.getPrivacy() ? UIColor.blackColor() : UIColor.redColor()
            vc.navigationItem.leftBarButtonItem?.tintColor = color
        }
    }

}