import UIKit

class TransactionsListViewController: UIViewController, AllTransactionsProtocol {

    var scrollView: UIScrollView!
    var transactionViewControllers: [TransactionViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("transactions", comment: "")
        self.createComponents()
        self.configureComponents()
        self.layoutComponents()
        for tx in TransactionStore.getTransactions() {
            self.addTxToUI(tx)
        }
        TransactionStore.register(self)
    }

    func createComponents() {
        self.transactionViewControllers = [TransactionViewController]()
        self.scrollView = UIScrollView()
        self.view.addSubview(self.scrollView);
    }

    func configureComponents() {
        self.view.backgroundColor = UIColor.whiteColor()
    }

    func layoutComponents() {
        var constraints:[NSLayoutConstraint] = []

        // Position the scrollview
        constraints.append(NSLayoutConstraint(
            item: self.scrollView, attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Top,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.scrollView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: self.scrollView, attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom,
            multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(
            item: self.scrollView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0))
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activateConstraints(constraints)
    }

    func transactionReceived(tx: BitcoinTx) {
        dispatch_async(dispatch_get_main_queue(), {
            self.addTxToUI(tx)
        })
    }

    func addTxToUI(tx: BitcoinTx) {
        // Create the transaction view controller
        let transactionViewController = TransactionViewController(tx: tx)
        self.transactionViewControllers.append(transactionViewController)

        // Prepare the constraints
        let txView = transactionViewController.view
        var constraints:[NSLayoutConstraint] = []

        // Add the top constraint (Top = Top of the scrollview or Bottom of the last transaction view)
        if (self.transactionViewControllers.count == 1) {
            constraints.append(NSLayoutConstraint(
                item: txView, attribute: .Top,
                relatedBy: .Equal,
                toItem: self.scrollView, attribute: .Top,
                multiplier: 1.0, constant: 0.0))
        } else {
            let previous = self.transactionViewControllers[self.transactionViewControllers.count - 2]
            constraints.append(NSLayoutConstraint(
                item: txView, attribute: .Top,
                relatedBy: .Equal,
                toItem: previous.view, attribute: .Bottom,
                multiplier: 1.0, constant: 0.0))
        }

        // Right and left constraints (edge of the scrollview)
        constraints.append(NSLayoutConstraint(
            item: txView, attribute: .Right,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Right,
            multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(
            item: txView, attribute: .Left,
            relatedBy: .Equal,
            toItem: self.view, attribute: .Left,
            multiplier: 1.0, constant: 0))
        txView.translatesAutoresizingMaskIntoConstraints = false

        // Add the tx view to the scroll view and activate the constraints
        self.scrollView.addSubview(txView)
        NSLayoutConstraint.activateConstraints(constraints)
    }
}

