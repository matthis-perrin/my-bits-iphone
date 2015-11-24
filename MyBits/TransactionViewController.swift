import Foundation
import UIKit

class TransactionViewController: UIViewController {

    var tx: BitcoinTx!
    var testLabel: UILabel!

    convenience init(tx: BitcoinTx) {
        self.init(coder: NSCoder())
        self.tx = tx
    }

    required init(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createComponents()
        self.configureComponents()
        self.layoutComponents()
    }

    func createComponents() {
        self.testLabel = UILabel(frame: CGRectZero)
        self.testLabel.text = tx.hash.description
        self.view.addSubview(self.testLabel)
    }

    func configureComponents() {

    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Position the label
        constraints.append(NSLayoutConstraint(
            item: self.testLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testLabel, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.testLabel, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0.0))
        self.testLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activateConstraints(constraints)
    }

}