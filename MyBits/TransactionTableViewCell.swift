import UIKit

class TransactionTableViewCell: UITableViewCell {

    // Controller that will handle building and updating the view
    var transactionViewController: TransactionViewController

    init(tx: BitcoinTx) {
        self.transactionViewController = TransactionViewController(tx: tx)
        super.init(style: .Default, reuseIdentifier: TransactionTableViewCell.reusableIdentifierFor(tx))
        self.contentView.addSubview(self.transactionViewController.view)

        self.transactionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Top,
            multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Right,
            multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Bottom,
            multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(
            item: self.transactionViewController.view, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.contentView, attribute: .Left,
            multiplier: 1.0, constant: 0)

        bottomConstraint.priority = UILayoutPriorityFittingSizeLevel
        NSLayoutConstraint.activateConstraints([topConstraint, rightConstraint, bottomConstraint, leftConstraint])
    }

    required convenience init(coder: NSCoder) {
        self.init(tx: BitcoinTx())
    }

    func setTx(tx: BitcoinTx) {
        self.transactionViewController.setTx(tx)
    }

    static func reusableIdentifierFor(tx: BitcoinTx) -> String {
        // The only real change in the layout is the number and type of subtitles, so we
        // base the reusable identifier from that.
        // Subtitle are simply represented by a number (0 for UICurrencyLabel and 1 for simple UILabel)
        // and joined in a sequence separated by "."
        // Example: TransactionViewCell.0.0.1.0
        // (Cell with four subtitles - first two are UICurrencyLabels, third is a simple UILabel and
        // last is a UICurrencyLabel again)
        let subtitles = TransactionViewController.getSubtitles(tx.txInfo.withoutChange())
        let code = subtitles.map() { return $0.amount == nil ? "0" : "1" }
        return "TransactionViewCell.\(code.joinWithSeparator("."))"
    }

}