import Foundation
import UIKit

class TransactionViewController: UIViewController {

    var PADDING: CGFloat = 10.0

    var tx: BitcoinTx!
    var txInfo: BitcoinTxInfo!

    var leftLabels: [UILabel]!
    var rightLabels: [UILabel]!
    var balanceDeltaLabel: UICurrencyLabel!

    convenience init(tx: BitcoinTx) {
        self.init(coder: NSCoder())
        self.tx = tx
        self.txInfo = tx.getInfo()
        self.leftLabels = [UILabel]()
        self.rightLabels = [UILabel]()
    }

    required init(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createComponents()
        self.layoutComponents()
    }

    func createComponents() {
        let fromLabel = UILabel(frame: CGRectZero)
        fromLabel.text = "From:"
        fromLabel.font = UIFont(name: fromLabel.font.familyName, size: 14.0)!
        leftLabels.append(fromLabel)
        self.view.addSubview(fromLabel)

        let toLabel = UILabel(frame: CGRectZero)
        toLabel.text = "To:"
        toLabel.font = UIFont(name: toLabel.font.familyName, size: 14.0)!
        rightLabels.append(toLabel)
        self.view.addSubview(toLabel)

        func txIOToLabel(txIO: TxIO) -> UILabel {
            let currencyLabel = UICurrencyLabel(fromBtcAmount: txIO.amount)
            if (txIO is ExternalAddressTxIO) {
                currencyLabel.setPrefix("External (\(txIO.address.smallDescription)) - ")
            } else if (txIO is AccountAddressTxIO) {
                currencyLabel.setPrefix("\((txIO as! AccountAddressTxIO).getAccount().getName()) (\(txIO.address.smallDescription)) - ")
            } else if (txIO is AccountXpubTxIO) {
                currencyLabel.setPrefix("\((txIO as! AccountXpubTxIO).getAccount().getName()) (\(txIO.address.smallDescription)) - ")
            }
            return currencyLabel
        }

        for txIO in self.txInfo.inputTxIO {
            let label = txIOToLabel(txIO)
            label.font = UIFont(name: label.font.familyName, size: 12.0)!
            self.leftLabels.append(label)
            self.view.addSubview(label)
        }
        for txIO in self.txInfo.outputTxIO {
            let label = txIOToLabel(txIO)
            label.font = UIFont(name: label.font.familyName, size: 12.0)!
            self.rightLabels.append(label)
            self.view.addSubview(label)
        }

        let balanceDelta = txInfo.getBalanceDelta()
        self.balanceDeltaLabel = UICurrencyLabel(fromBtcAmount: balanceDelta)
        self.view.addSubview(self.balanceDeltaLabel)

        self.view.layer.borderWidth = 1
    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Left labels
        for (index, leftLabel) in self.leftLabels.enumerate() {
            if (index == 0) {
                constraints.append(NSLayoutConstraint(
                    item: leftLabel, attribute: .Top,
                    relatedBy: .Equal,
                    toItem: self.view, attribute: .Top,
                    multiplier: 1.0, constant: PADDING))
                constraints.append(NSLayoutConstraint(
                    item: leftLabel, attribute: .Left,
                    relatedBy: .Equal,
                    toItem: self.view, attribute: .Left,
                    multiplier: 1.0, constant: PADDING))
            } else {
                let previous = self.leftLabels[index - 1]
                constraints.append(NSLayoutConstraint(
                    item: leftLabel, attribute: .Top,
                    relatedBy: .Equal,
                    toItem: previous, attribute: .Bottom,
                    multiplier: 1.0, constant: 0.0))
                constraints.append(NSLayoutConstraint(
                    item: leftLabel, attribute: .Left,
                    relatedBy: .Equal,
                    toItem: self.leftLabels.first!, attribute: .Left,
                    multiplier: 1.0, constant: 10.0))
            }
            constraints.append(NSLayoutConstraint(
                item: leftLabel, attribute: .Height,
                relatedBy: .Equal,
                toItem: nil, attribute: .Height,
                multiplier: 1.0, constant: 20.0))
            leftLabel.translatesAutoresizingMaskIntoConstraints = false
        }

        // Right labels
        for (index, rightLabel) in self.rightLabels.enumerate() {
            if (index == 0) {
                constraints.append(NSLayoutConstraint(
                    item: rightLabel, attribute: .Top,
                    relatedBy: .Equal,
                    toItem: self.leftLabels.last!, attribute: .Bottom,
                    multiplier: 1.0, constant: 0.0))
                constraints.append(NSLayoutConstraint(
                    item: rightLabel, attribute: .Left,
                    relatedBy: .Equal,
                    toItem: self.leftLabels.first!, attribute: .Left,
                    multiplier: 1.0, constant: 0.0))
            } else {
                let previous = self.rightLabels[index - 1]
                constraints.append(NSLayoutConstraint(
                    item: rightLabel, attribute: .Top,
                    relatedBy: .Equal,
                    toItem: previous, attribute: .Bottom,
                    multiplier: 1.0, constant: 0.0))
                constraints.append(NSLayoutConstraint(
                    item: rightLabel, attribute: .Left,
                    relatedBy: .Equal,
                    toItem: self.rightLabels.first!, attribute: .Left,
                    multiplier: 1.0, constant: 10.0))
            }
            constraints.append(NSLayoutConstraint(
                item: rightLabel, attribute: .Height,
                relatedBy: .Equal,
                toItem: nil, attribute: .Height,
                multiplier: 1.0, constant: 20.0))
            rightLabel.translatesAutoresizingMaskIntoConstraints = false
        }

        // Balance Delta
        constraints.append(NSLayoutConstraint(
            item: self.balanceDeltaLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: -PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.balanceDeltaLabel, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0))
        self.balanceDeltaLabel.translatesAutoresizingMaskIntoConstraints = false

        // View
        constraints.append(NSLayoutConstraint(
            item: self.view, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.rightLabels.last!, attribute: .Bottom,
            multiplier: 1.0, constant: PADDING))


        NSLayoutConstraint.activateConstraints(constraints)
    }

}