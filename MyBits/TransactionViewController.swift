import Foundation
import UIKit

class TransactionViewController: UIViewController {

    let PADDING: CGFloat = 10.0
    let CONFIRMATION_FONT_SIZE: CGFloat = 11.0

    var tx: BitcoinTx
    var txInfo: BitcoinTxInfo

    // Left part of the view.
    // Handles displaying the confirmation level of the transaction.
    var leftView: UIView!

    // Left part subviews.
    var confirmationLabel: UILabel!


    // Middle part of the view.
    // Handles displaying the title and eventual subtitles for the transaction.
    var middleView: UIView!


    // Right part of the view.
    // Handles displaying the transaction balance delta
    var rightView: UIView!

    // Right part subviews
    var balanceDeltaLabel: UICurrencyLabel!

//    var leftLabels: [UILabel]!
//    var rightLabels: [UILabel]!
//    var balanceDeltaLabel: UICurrencyLabel!

    init(tx: BitcoinTx) {
        self.tx = tx
        self.txInfo = tx.getInfo()
        super.init(nibName: nil, bundle: nil)
//        self.leftLabels = [UILabel]()
//        self.rightLabels = [UILabel]()
    }

    required convenience init(coder: NSCoder) {
        self.init(tx: BitcoinTx())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createComponents()
        self.layoutComponents()
    }

    func createComponents() {
        // Left view
        self.leftView = UIView(frame: CGRectZero)
        self.leftView.translatesAutoresizingMaskIntoConstraints = false
//        self.leftView.layer.borderWidth = 1.0
        self.view.addSubview(leftView)

        // Confirmation label
        var confirmationText = ""
        if self.tx.confirmations.value == 0 {
            confirmationText = NSLocalizedString("confirmation.zero", comment: "Number of confirmation (0) of the transaction")
        } else if self.tx.confirmations.value == 1 {
            confirmationText = NSLocalizedString("confirmation.one", comment: "Number of confirmation (1) of the transaction")
        } else {
            let confirmationCount = self.tx.confirmations.value > 99 ? "99+" : self.tx.confirmations.value.description
            print(confirmationCount)
            confirmationText = String(format: NSLocalizedString("confirmation.several", comment: "Number of confirmation (>1) of the transaction"), arguments: [confirmationCount])
        }
        self.confirmationLabel = UILabel(frame: CGRectZero)
        self.confirmationLabel.text = confirmationText
        self.confirmationLabel.textAlignment = .Center
        self.confirmationLabel.font = UIFont(name: self.confirmationLabel.font!.fontName, size: CONFIRMATION_FONT_SIZE)
        self.confirmationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.addSubview(self.confirmationLabel)

        // Middle view
        self.middleView = UIView(frame: CGRectZero)
        self.middleView.translatesAutoresizingMaskIntoConstraints = false
//        self.middleView.layer.borderWidth = 1.0
        self.view.addSubview(middleView)

        // Right view
        self.rightView = UIView(frame: CGRectZero)
        self.rightView.translatesAutoresizingMaskIntoConstraints = false
//        self.rightView.layer.borderWidth = 1.0
        self.view.addSubview(rightView)

        self.balanceDeltaLabel = UICurrencyLabel(fromBtcAmount: self.txInfo.getBalanceDelta())
        self.balanceDeltaLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightView.addSubview(balanceDeltaLabel)


//        let fromLabel = UILabel(frame: CGRectZero)
//        fromLabel.text = "From:"
//        fromLabel.font = UIFont(name: fromLabel.font.familyName, size: 14.0)!
//        leftLabels.append(fromLabel)
//        self.view.addSubview(fromLabel)
//
//        let toLabel = UILabel(frame: CGRectZero)
//        toLabel.text = "To:"
//        toLabel.font = UIFont(name: toLabel.font.familyName, size: 14.0)!
//        rightLabels.append(toLabel)
//        self.view.addSubview(toLabel)
//
//        func txIOToLabel(txIO: TxIO) -> UILabel {
//            let currencyLabel = UICurrencyLabel(fromBtcAmount: txIO.amount)
//            if (txIO is ExternalAddressTxIO) {
//                currencyLabel.setPrefix("External (\(txIO.address.smallDescription)) - ")
//            } else if (txIO is AccountAddressTxIO) {
//                currencyLabel.setPrefix("\((txIO as! AccountAddressTxIO).getAccount().getName()) (\(txIO.address.smallDescription)) - ")
//            } else if (txIO is AccountXpubTxIO) {
//                currencyLabel.setPrefix("\((txIO as! AccountXpubTxIO).getAccount().getName()) (\(txIO.address.smallDescription)) - ")
//            }
//            return currencyLabel
//        }
//
//        for txIO in self.txInfo.inputTxIO {
//            let label = txIOToLabel(txIO)
//            label.font = UIFont(name: label.font.familyName, size: 12.0)!
//            self.leftLabels.append(label)
//            self.view.addSubview(label)
//        }
//        for txIO in self.txInfo.outputTxIO {
//            let label = txIOToLabel(txIO)
//            label.font = UIFont(name: label.font.familyName, size: 12.0)!
//            self.rightLabels.append(label)
//            self.view.addSubview(label)
//        }
//
//        let balanceDelta = txInfo.getBalanceDelta()
//        self.balanceDeltaLabel = UICurrencyLabel(fromBtcAmount: balanceDelta)
//        self.view.addSubview(self.balanceDeltaLabel)
    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Left view
        constraints.append(NSLayoutConstraint(
            item: self.leftView, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view, attribute: .CenterY,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.leftView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: PADDING))

        // Confirmation label
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.leftView, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.leftView, attribute: .Top,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.leftView, attribute: .Left,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.leftView, attribute: .Right,
            multiplier: 1.0, constant: 0))

        // Middle view
        constraints.append(NSLayoutConstraint(
            item: self.middleView, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.middleView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.middleView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.leftView, attribute: .Right,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.middleView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.rightView, attribute: .Left,
            multiplier: 1.0, constant: 0))

        // Right view
        constraints.append(NSLayoutConstraint(
            item: self.rightView, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.rightView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom,
            multiplier: 1.0, constant: -PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.rightView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: -PADDING))

        // Balance delta
        constraints.append(NSLayoutConstraint(
            item: self.balanceDeltaLabel, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.rightView, attribute: .Left,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.balanceDeltaLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.rightView, attribute: .Right,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.balanceDeltaLabel, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.rightView, attribute: .CenterY,
            multiplier: 1.0, constant: 0))

        // Main view
        for view in [self.leftView, self.middleView, self.rightView] {
            print(view)
            constraints.append(NSLayoutConstraint(
                item: self.view, attribute: .Bottom,
                relatedBy: .GreaterThanOrEqual,
                toItem: view, attribute: .Bottom,
                multiplier: 1.0, constant: PADDING))
        }



//        // Left labels
//        for (index, leftLabel) in self.leftLabels.enumerate() {
//            if (index == 0) {
//                constraints.append(NSLayoutConstraint(
//                    item: leftLabel, attribute: .Top,
//                    relatedBy: .Equal,
//                    toItem: self.view, attribute: .Top,
//                    multiplier: 1.0, constant: PADDING))
//                constraints.append(NSLayoutConstraint(
//                    item: leftLabel, attribute: .Left,
//                    relatedBy: .Equal,
//                    toItem: self.view, attribute: .Left,
//                    multiplier: 1.0, constant: PADDING))
//            } else {
//                let previous = self.leftLabels[index - 1]
//                constraints.append(NSLayoutConstraint(
//                    item: leftLabel, attribute: .Top,
//                    relatedBy: .Equal,
//                    toItem: previous, attribute: .Bottom,
//                    multiplier: 1.0, constant: 0.0))
//                constraints.append(NSLayoutConstraint(
//                    item: leftLabel, attribute: .Left,
//                    relatedBy: .Equal,
//                    toItem: self.leftLabels.first!, attribute: .Left,
//                    multiplier: 1.0, constant: 10.0))
//            }
//            constraints.append(NSLayoutConstraint(
//                item: leftLabel, attribute: .Height,
//                relatedBy: .Equal,
//                toItem: nil, attribute: .Height,
//                multiplier: 1.0, constant: 20.0))
//            leftLabel.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        // Right labels
//        for (index, rightLabel) in self.rightLabels.enumerate() {
//            if (index == 0) {
//                constraints.append(NSLayoutConstraint(
//                    item: rightLabel, attribute: .Top,
//                    relatedBy: .Equal,
//                    toItem: self.leftLabels.last!, attribute: .Bottom,
//                    multiplier: 1.0, constant: 0.0))
//                constraints.append(NSLayoutConstraint(
//                    item: rightLabel, attribute: .Left,
//                    relatedBy: .Equal,
//                    toItem: self.leftLabels.first!, attribute: .Left,
//                    multiplier: 1.0, constant: 0.0))
//            } else {
//                let previous = self.rightLabels[index - 1]
//                constraints.append(NSLayoutConstraint(
//                    item: rightLabel, attribute: .Top,
//                    relatedBy: .Equal,
//                    toItem: previous, attribute: .Bottom,
//                    multiplier: 1.0, constant: 0.0))
//                constraints.append(NSLayoutConstraint(
//                    item: rightLabel, attribute: .Left,
//                    relatedBy: .Equal,
//                    toItem: self.rightLabels.first!, attribute: .Left,
//                    multiplier: 1.0, constant: 10.0))
//            }
//            constraints.append(NSLayoutConstraint(
//                item: rightLabel, attribute: .Height,
//                relatedBy: .Equal,
//                toItem: nil, attribute: .Height,
//                multiplier: 1.0, constant: 20.0))
//            rightLabel.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        // Balance Delta
//        constraints.append(NSLayoutConstraint(
//            item: self.balanceDeltaLabel, attribute: .Right,
//            relatedBy: .Equal,
//            toItem: self.view, attribute: .Right,
//            multiplier: 1.0, constant: -PADDING))
//        constraints.append(NSLayoutConstraint(
//            item: self.balanceDeltaLabel, attribute: .CenterY,
//            relatedBy: .Equal,
//            toItem: self.view, attribute: .CenterY,
//            multiplier: 1.0, constant: 0.0))
//        self.balanceDeltaLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        // View
//        constraints.append(NSLayoutConstraint(
//            item: self.view, attribute: .Bottom,
//            relatedBy: .Equal,
//            toItem: self.rightLabels.last!, attribute: .Bottom,
//            multiplier: 1.0, constant: PADDING))


        NSLayoutConstraint.activateConstraints(constraints)
    }

}