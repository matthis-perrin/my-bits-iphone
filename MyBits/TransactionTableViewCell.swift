import UIKit

class TransactionTableViewCell: UITableViewCell {

    // Controller that will handle building and updating the view
    var transactionViewController: TransactionViewController

    init(tx: BitcoinTx) {
        self.transactionViewController = TransactionViewController(tx: tx)
        super.init(style: .Default, reuseIdentifier: TransactionTableViewCell.reusableIdentifierFor(tx))
        self.contentView.addSubview(self.transactionViewController.view)

        self.transactionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Top,
            multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Right,
            multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Bottom,
            multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Left,
            multiplier: 1.0, constant: 0).active = true
    }

    required convenience init(coder: NSCoder) {
        self.init(tx: BitcoinTx())
    }

    static func reusableIdentifierFor(tx: BitcoinTx) -> String {
        // The only real change in the layout is the number of subtitles, so we
        // base the reusable identifier from that
        let subtitleCount = 1 // For now always 1 (hardcoded)
        return "TransactionViewCell.\(subtitleCount)"
    }

}