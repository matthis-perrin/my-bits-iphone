import Foundation
import UIKit

class TransactionsListViewController: UIViewController, PrivacyProtocol, PriceProtocol {

    var testButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarCustomization()
        PrivacyManager.register(self)
        PriceManager.register(self)

        createComponents()
        configureComponents()
        layoutComponents()
    }

    override func viewDidDisappear(animated: Bool) {
        PrivacyManager.unregister(self)
    }

    func navBarCustomization() {
        // Left item (Privacy)
        let icon = UIImage(named: "TopBar_Privacy.png")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, landscapeImagePhone: icon, style: .Plain, target: self, action: "onHideCurrencyButtonTap")
        self.navigationItem.leftBarButtonItem?.tintColor = PrivacyManager.getPrivacy() ? UIColor.redColor() : UIColor.blackColor()

        // Right item (Bitcoin price)
        let label = UILabel(frame: CGRectMake(0, 0, 100, 20))
        label.textAlignment = .Right
        label.text = NSString(format: "$%.2f", PriceManager.getPrice()) as String
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
    }

    func privacyDidChange() {
        navBarCustomization()
        configureComponents()
    }

    func priceDidChange() {
        navBarCustomization()
    }

    func onHideCurrencyButtonTap() {
        PrivacyManager.setPrivacy(!PrivacyManager.getPrivacy())
    }

    func createComponents() {
        self.testButton = UIButton(type: UIButtonType.RoundedRect)
        self.view.addSubview(self.testButton!);
    }

    func configureComponents() {
        let text = "Privacy " + (PrivacyManager.getPrivacy() ? "On" : "Off")
        self.testButton?.setTitle(text, forState: UIControlState.Normal)
        self.testButton?.layer.borderColor = self.testButton?.titleColorForState(UIControlState.Normal)?.CGColor
        self.testButton?.layer.borderWidth = 1.0
        self.testButton?.layer.cornerRadius = 4.0
        self.view.backgroundColor = UIColor.whiteColor()
    }

    func layoutComponents() {
        let testButtonXConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0)
        let testButtonYConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0)
        let testButtonWConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .Width,
            relatedBy: .Equal,
            toItem: nil, attribute: .Width,
            multiplier: 1.0, constant: 150)
        let testButtonHConstraint = NSLayoutConstraint(
            item: self.testButton!, attribute: .Height,
            relatedBy: .Equal,
            toItem: nil, attribute: .Height,
            multiplier: 1.0, constant: 50)
        testButton?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activateConstraints([
            testButtonXConstraint,
            testButtonYConstraint,
            testButtonWConstraint,
            testButtonHConstraint
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

