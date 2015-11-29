import UIKit

class TransactionTableViewController: UITableViewController, AllTransactionsProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("transactions", comment: "")
        self.view.backgroundColor = UIColor.whiteColor()
        TransactionStore.register(self)

        self.tableView.allowsSelection = false
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150.0 // TODO - Put a real average size
    }

    func transactionReceived(tx: BitcoinTx) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionStore.getTransactions().count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sortedTxs = TransactionStore.getTransactions().sort() { tx1, tx2 in
            if tx1.blockHeight.value == tx2.blockHeight.value {
                return tx1.receptionTime.value.compare(tx2.receptionTime.value) == NSComparisonResult.OrderedAscending
            } else {
                if tx1.blockHeight.value < 0 {
                    return false
                } else if tx2.blockHeight.value < 0 {
                    return true
                } else {
                    return tx1.receptionTime.value.compare(tx2.receptionTime.value) == NSComparisonResult.OrderedDescending
                }
            }
        }
        let tx = sortedTxs[indexPath.row]
        if let cell = self.tableView.dequeueReusableCellWithIdentifier(TransactionTableViewCell.reusableIdentifierFor(tx)) as? TransactionTableViewCell {
            cell.setTx(tx)
            return cell
        }
        let cell = TransactionTableViewCell(tx: tx)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }

}

