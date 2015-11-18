import UIKit

class TransactionsListViewController: UIViewController, PrivacyProtocol {

    var testButton: UIButton!
    var testBalanceLabel: UICurrencyLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("transactions", comment: "")
        self.createComponents()
        self.layoutComponents()
    }

    override func viewWillAppear(animated: Bool) {
        PrivacyStore.register(self)
        self.configureComponents()
    }

    override func viewDidDisappear(animated: Bool) {
        PrivacyStore.unregister(self)
    }

    func privacyDidChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.configureComponents()
        }
    }

    func createComponents() {
        let bitcoinBalance = 3.14
        self.testButton = UIButton(type: UIButtonType.RoundedRect)
        self.testBalanceLabel = UICurrencyLabel(fromBitcoin: bitcoinBalance, displayCurrency: .Bitcoin)
        self.view.addSubview(self.testBalanceLabel);
        self.view.addSubview(self.testButton);
    }

    func configureComponents() {
        let text = "Privacy " + (PrivacyStore.getPrivacy() ? "On" : "Off")
        self.testButton.setTitle(text, forState: UIControlState.Normal)
        self.testButton.layer.borderColor = self.testButton.titleColorForState(UIControlState.Normal)?.CGColor
        self.testButton.layer.borderWidth = 1.0
        self.testButton.layer.cornerRadius = 4.0

        self.testBalanceLabel.setFontSize(16)
        self.testBalanceLabel.setPrefix("Your balance is ")
        self.testBalanceLabel.setSuffix("!")

        self.view.backgroundColor = UIColor.whiteColor()
    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Position button (centered in the page)
        constraints.append(NSLayoutConstraint(
            item: self.testButton, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testButton, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testButton, attribute: .Width,
            relatedBy: .Equal,
            toItem: nil, attribute: .Width,
            multiplier: 1.0, constant: 150))
        constraints.append(NSLayoutConstraint(
            item: self.testButton, attribute: .Height,
            relatedBy: .Equal,
            toItem: nil, attribute: .Height,
            multiplier: 1.0, constant: 50))
        self.testButton.translatesAutoresizingMaskIntoConstraints = false

        // Position label
        testBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(NSLayoutConstraint(
            item: testBalanceLabel, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.testButton, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testBalanceLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.testButton, attribute: .Bottom,
            multiplier: 1.0, constant: 10.0))

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

