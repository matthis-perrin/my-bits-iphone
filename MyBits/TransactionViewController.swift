import Foundation
import UIKit

class TransactionViewController: UIViewController {

    static let PADDING: CGFloat = 18.0
    static let SMALL_PADDING: CGFloat = 5.0

    static let BIG_TEXT_FONT_SIZE: CGFloat = 17.0
    static let SMALL_TEXT_FONT_SIZE: CGFloat = 11.0

    static let DARK_TEXT_COLOR: UIColor = UIColor(white: 51.0 / 255.0, alpha: 1.0)
    static let LIGHT_TEXT_COLOR: UIColor = UIColor(white: 155.0 / 255.0, alpha: 1.0)
    static let GREEN_TEXT_COLOR: UIColor = UIColor(red: 0, green: 150 / 255.0, blue: 136 / 255.0, alpha: 1.0)
    static let RED_TEXT_COLOR: UIColor = UIColor(red: 1.0, green: 87 / 255.0, blue: 34 / 255.0, alpha: 1.0)

    static let CONFIRMATION_ICON_LABEL_GAP: CGFloat = 3.0


    static let UNKNOWN_TITLE = "Unknown transaction"
    static let TITLES = [
        TxType.External: "External transaction",
        TxType.Empty: "Empty transaction",
        TxType.InAccount: "In-account transfer",
        TxType.Sent: "Bitcoin sent",
        TxType.Received: "Bitcoin received",
        TxType.Unknown: UNKNOWN_TITLE,
    ]


    var tx: BitcoinTx

    var titleView: UIView!
    var subtitleView: UIView!
    var amountView: UIView!
    var bottomView: UIView!

    var titleLabel: UILabel!
    var subtitleLabels: [UILabel]!
    var confirmationIcon: UIImageView!
    var confirmationLabel: UILabel!
    var amountLabel: UICurrencyLabel!
    var dateLabel: UILabel!

    init(tx: BitcoinTx) {
        self.tx = tx
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init(coder: NSCoder) {
        self.init(tx: BitcoinTx())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createComponents()
        self.layoutComponents()
        self.setTx(self.tx)
    }

    func createComponents() {

//        let BORDER_WIDTH: CGFloat = 1.0
        let BORDER_WIDTH: CGFloat = 0.0
//        let BACKGROUND_COLOR: UIColor = UIColor.redColor()
        let BACKGROUND_COLOR: UIColor = UIColor(white: 1, alpha: 0)

        // Title view
        self.titleView = UIView(frame: CGRectZero)
        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.layer.borderWidth = BORDER_WIDTH
        self.view.addSubview(self.titleView)

        // Subtitle view
        self.subtitleView = UIView(frame: CGRectZero)
        self.subtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleView.layer.borderWidth = BORDER_WIDTH
        self.view.addSubview(self.subtitleView)

        // Amount view
        self.amountView = UIView(frame: CGRectZero)
        self.amountView.translatesAutoresizingMaskIntoConstraints = false
        self.amountView.layer.borderWidth = BORDER_WIDTH
        self.view.addSubview(self.amountView)

        // Bottom view
        self.bottomView = UIView(frame: CGRectZero)
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.layer.borderWidth = BORDER_WIDTH
        self.view.addSubview(self.bottomView)


        // Title label
        self.titleLabel = UILabel(frame: CGRectZero)
        self.titleLabel.textAlignment = .Left
        self.titleLabel.font = UIFont(name: self.titleLabel.font!.fontName, size: TransactionViewController.BIG_TEXT_FONT_SIZE)
        self.titleLabel.textColor = TransactionViewController.DARK_TEXT_COLOR
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.backgroundColor = BACKGROUND_COLOR
        self.titleView.addSubview(self.titleLabel)

        // Subtitle labels
        self.subtitleLabels = self.getSubtitles()
        for subtitle in subtitleLabels {
            subtitle.textAlignment = .Left
            subtitle.font = UIFont(name: subtitle.font!.fontName, size: TransactionViewController.SMALL_TEXT_FONT_SIZE)
            subtitle.textColor = TransactionViewController.DARK_TEXT_COLOR
            subtitle.translatesAutoresizingMaskIntoConstraints = false
            subtitle.backgroundColor = BACKGROUND_COLOR
            self.subtitleView.addSubview(subtitle)
        }

        // Amount label
        self.amountLabel = UICurrencyLabel()
        self.amountLabel.textAlignment = .Right
        self.amountLabel.font = UIFont(name: self.amountLabel.font!.fontName, size: TransactionViewController.BIG_TEXT_FONT_SIZE)
        self.amountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.amountLabel.backgroundColor = BACKGROUND_COLOR
        self.amountView.addSubview(amountLabel)

        // Confirmation icon
        self.confirmationIcon = UIImageView()
        self.confirmationIcon.translatesAutoresizingMaskIntoConstraints = false
        self.confirmationIcon.backgroundColor = BACKGROUND_COLOR
        self.confirmationIcon.tintColor = TransactionViewController.LIGHT_TEXT_COLOR
        self.bottomView.addSubview(self.confirmationIcon)

        // Confirmation label
        self.confirmationLabel = UILabel(frame: CGRectZero)
        self.confirmationLabel.textAlignment = .Left
        self.confirmationLabel.font = UIFont(name: self.confirmationLabel.font!.fontName, size: TransactionViewController.SMALL_TEXT_FONT_SIZE)
        self.confirmationLabel.textColor = TransactionViewController.LIGHT_TEXT_COLOR
        self.confirmationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.confirmationLabel.backgroundColor = BACKGROUND_COLOR
        self.bottomView.addSubview(self.confirmationLabel)

        // Date label
        self.dateLabel = UILabel(frame: CGRectZero)
        self.dateLabel.textAlignment = .Right
        self.dateLabel.font = UIFont(name: self.dateLabel.font!.fontName, size: TransactionViewController.SMALL_TEXT_FONT_SIZE)
        self.dateLabel.textColor = TransactionViewController.LIGHT_TEXT_COLOR
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.backgroundColor = BACKGROUND_COLOR
        self.bottomView.addSubview(self.dateLabel)

    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Title view
        constraints.append(NSLayoutConstraint(
            item: self.titleView, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.titleView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.amountView, attribute: .Left,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.titleView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.subtitleView, attribute: .Top,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.titleView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0))

        // Subtitle view
        constraints.append(NSLayoutConstraint(
            item: self.subtitleView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.amountView, attribute: .Left,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.subtitleView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Top,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.subtitleView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0))

        // Amount view
        constraints.append(NSLayoutConstraint(
            item: self.amountView, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.amountView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.amountView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Top,
            multiplier: 1.0, constant: 0))

        // Bottom view
        constraints.append(NSLayoutConstraint(
            item: self.bottomView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.bottomView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.bottomView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0))

        // Title label
        constraints.append(NSLayoutConstraint(
            item: self.titleLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.titleView, attribute: .Top,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.titleLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.titleView, attribute: .Right,
            multiplier: 1.0, constant: -TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.titleLabel, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.titleView, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.titleLabel, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.titleView, attribute: .Left,
            multiplier: 1.0, constant: TransactionViewController.PADDING))

        // Subtitle labels
        for (index, subtitleLabel) in self.subtitleLabels.enumerate() {
            let previous = index == 0 ? self.subtitleView : self.subtitleLabels[index - 1]
            let next = index == self.subtitleLabels.count - 1 ? self.bottomView : self.subtitleLabels[index + 1]
            constraints.append(NSLayoutConstraint(
                item: subtitleLabel, attribute: .Top,
                relatedBy: .Equal,
                toItem: previous, attribute: .Top,
                multiplier: 1.0, constant: TransactionViewController.SMALL_PADDING))
            constraints.append(NSLayoutConstraint(
                item: subtitleLabel, attribute: .Right,
                relatedBy: .Equal,
                toItem: self.subtitleView, attribute: .Right,
                multiplier: 1.0, constant: -TransactionViewController.PADDING))
            constraints.append(NSLayoutConstraint(
                item: subtitleLabel, attribute: .Bottom,
                relatedBy: .Equal,
                toItem: next, attribute: .Top,
                multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(
                item: subtitleLabel, attribute: .Left,
                relatedBy: .Equal,
                toItem: self.subtitleView, attribute: .Left,
                multiplier: 1.0, constant: TransactionViewController.PADDING))
        }

        // Amount label
        constraints.append(NSLayoutConstraint(
            item: self.amountLabel, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.amountView, attribute: .CenterY,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.amountLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.amountView, attribute: .Right,
            multiplier: 1.0, constant: -TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.amountLabel, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.amountView, attribute: .Left,
            multiplier: 1.0, constant: 0))

        // Confirmation icon
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Top,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.confirmationLabel, attribute: .Left,
            multiplier: 1.0, constant: -TransactionViewController.CONFIRMATION_ICON_LABEL_GAP))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Bottom,
            multiplier: 1.0, constant: -2.0 * TransactionViewController.SMALL_PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Left,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Width,
            relatedBy: .Equal,
            toItem: nil, attribute: .Width,
            multiplier: 1.0, constant: self.tx.isConfirmed ? 11.0 : 13.0))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationIcon, attribute: .Height,
            relatedBy: .Equal,
            toItem: nil, attribute: .Height,
            multiplier: 1.0, constant: self.tx.isConfirmed ? 11.0 : 13.0))

        // Confirmation label
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Top,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.dateLabel, attribute: .Left,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.confirmationLabel, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Bottom,
            multiplier: 1.0, constant: -2.0 * TransactionViewController.SMALL_PADDING))

        // Date label
        constraints.append(NSLayoutConstraint(
            item: self.dateLabel, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Top,
            multiplier: 1.0, constant: TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.dateLabel, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Right,
            multiplier: 1.0, constant: -TransactionViewController.PADDING))
        constraints.append(NSLayoutConstraint(
            item: self.dateLabel, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.bottomView, attribute: .Bottom,
            multiplier: 1.0, constant: -2.0 * TransactionViewController.SMALL_PADDING))

        NSLayoutConstraint.activateConstraints(constraints)
    }

    private func getTitleText() -> String {
        if let title = TransactionViewController.TITLES[self.tx.getType()] {
            return title
        } else {
            return TransactionViewController.UNKNOWN_TITLE
        }
    }

    private func getSubtitles() -> [UILabel] {
        var labels = [UILabel]()

        let subtitleLabel1 = UILabel(frame: CGRectZero)
        subtitleLabel1.text = "Subtitle - coming soon"
        labels.append(subtitleLabel1)

        return labels
    }

    func setTx(tx: BitcoinTx) {
        self.tx = tx
        let balanceDelta = self.tx.txInfo.getBalanceDelta()
        self.titleLabel.text = self.getTitleText()
        self.amountLabel.setAmount(balanceDelta.getBitcoinAmount(), amountCurrency: .Bitcoin, displayCurrency: .Bitcoin)
        self.amountLabel.textColor = balanceDelta > 0 ? TransactionViewController.GREEN_TEXT_COLOR : balanceDelta < 0 ? TransactionViewController.RED_TEXT_COLOR : TransactionViewController.DARK_TEXT_COLOR
        self.confirmationIcon.image = UIImage(named: self.tx.isConfirmed ? "Transaction_Check" : "Transaction_Clock")
        var confirmationText = ""
        if self.tx.confirmations.value == 0 {
            confirmationText = NSLocalizedString("confirmation.zero", comment: "Number of confirmation (0) of the transaction")
        } else if self.tx.confirmations.value == 1 {
            confirmationText = NSLocalizedString("confirmation.one", comment: "Number of confirmation (1) of the transaction")
        } else {
            let confirmationCount = self.tx.confirmations.value > 99 ? "99+" : self.tx.confirmations.value.description
            confirmationText = String(format: NSLocalizedString("confirmation.several", comment: "Number of confirmation (>1) of the transaction"), arguments: [confirmationCount])
        }
        self.confirmationLabel.text = confirmationText
        self.dateLabel.text = tx.receptionTime.userFriendlyDescription
    }

}