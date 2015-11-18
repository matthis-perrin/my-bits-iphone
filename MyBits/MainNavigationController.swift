import UIKit

protocol BackButton {
    var shouldDisplayBackButton: Bool { get }
}

class MainNavigationController : UINavigationController {

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        self.setNavigationButtonsToViewController(viewController)
        super.pushViewController(viewController, animated: animated)
    }

    private func setNavigationButtonsToViewController(vc: UIViewController) {
        // Left item (Privacy) -> only if not displaying back button
        if !vc.respondsToSelector(Selector("shouldDisplayBackButton")) || !(vc.valueForKey("shouldDisplayBackButton") as! Bool) {
            let icon = UIImage(named: "TopBar_Privacy.png")
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, landscapeImagePhone: icon, style: .Plain, target: self, action: "togglePrivacy")
            vc.navigationItem.leftBarButtonItem?.tintColor = PrivacyStore.getPrivacyColor()
        }

        // Right item (Bitcoin price)
        let label = UICurrencyLabel(fromBitcoin: 1.0, displayCurrency: .Fiat)
        label.frame = CGRectMake(0, 0, 100, 20)
        label.setRespectPrivacy(false)
        label.textAlignment = .Right
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }

    @objc private func togglePrivacy() {
        PrivacyStore.setPrivacy(!PrivacyStore.getPrivacy())
        if let vc = self.visibleViewController {
            vc.navigationItem.leftBarButtonItem?.tintColor = PrivacyStore.getPrivacyColor()
        }
    }

}