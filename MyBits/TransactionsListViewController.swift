import Foundation
import UIKit

class TransactionsListViewController: UIViewController, PrivacyProtocol, PriceProtocol {

    var testButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBarCustomization()
        self.createComponents()
        self.configureComponents()
        self.layoutComponents()
    }

    override func viewWillAppear(animated: Bool) {
        PrivacyManager.register(self)
        PriceManager.register(self)
    }

    override func viewDidDisappear(animated: Bool) {
        PrivacyManager.unregister(self)
        PriceManager.unregister(self)
    }

    func privacyDidChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.navBarCustomization()
            self.configureComponents()
        }
    }

    func priceDidChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.navBarCustomization()
        }
    }

    func onHideCurrencyButtonTap() {
        PrivacyManager.setPrivacy(!PrivacyManager.getPrivacy())
    }


    func navBarCustomization() {
        // Left item (Privacy)
        let icon = UIImage(named: "TopBar_Privacy.png")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, landscapeImagePhone: icon, style: .Plain, target: self, action: "onHideCurrencyButtonTap")
        self.navigationItem.leftBarButtonItem?.tintColor = PrivacyManager.getPrivacy() ? UIColor.redColor() : UIColor.blackColor()

        // Right item (Bitcoin price)
        let price = PriceManager.getPrice()
        let currency = PriceManager.getCurrency()
        let label = UILabel(frame: CGRectMake(0, 0, 100, 20))
        label.textAlignment = .Right
        if (price != nil && currency != nil) {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = NSLocale.currentLocale()
            numberFormatter.currencyCode = currency
            numberFormatter.numberStyle = .CurrencyStyle
            label.text = numberFormatter.stringFromNumber(price!)
        } else {
            label.text = ""
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
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

