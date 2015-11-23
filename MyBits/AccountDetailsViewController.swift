import UIKit

class AccountDetailsViewController : UITableViewController, AllTransactionsProtocol {

    private var account: Account?
    private var transactions = [BitcoinTx]()

    convenience init(account: Account) {
        self.init(style: .Plain)
        self.account = account
        self.updateTransactions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = account?.getName()
        self.edgesForExtendedLayout = .None
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        TransactionStore.unregister(self)
        TransactionStore.register(self)
        self.tableView.reloadData()
    }

    func transactionReceived(tx: BitcoinTx) {
        self.updateTransactions()
        self.tableView.reloadData()
    }

    private func updateTransactions() {
        self.transactions = [BitcoinTx]()

        // Listing all addresses
        var addresses = [BitcoinAddress]()
        for address in account!.getAddresses() {
            addresses.append(address.getBitcoinAddress())
        }
        for xpub in account!.getXpubs() {
            addresses.appendContentsOf(xpub.getAddresses())
        }

        // Mapping with all transactions
        for tx in TransactionStore.getTransactions() {
            if isOneAddresseInInputs(addresses, inputs: tx.inputs) || isOneAddresseInOutputs(addresses, outputs: tx.outputs) {
                self.transactions.append(tx)
            }
        }
    }

    private func isOneAddresseInInputs(addresses: [BitcoinAddress], inputs: [TxInput]) -> Bool {
        for input in inputs {
            for address in addresses {
                if input.sourceAddresses.contains(address) {
                    return true
                }
            }
        }
        return false
    }

    private func isOneAddresseInOutputs(addresses: [BitcoinAddress], outputs: [TxOutput]) -> Bool {
        for output in outputs {
            for address in addresses {
                if output.destinationAddresses.contains(address) {
                    return true
                }
            }
        }
        return false
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Transaction cell
        var cell = tableView.dequeueReusableCellWithIdentifier("TransactionCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "TransactionCell")
            cell!.selectionStyle = .None
        }

        cell!.textLabel?.text = self.transactions[indexPath.row].hash.value

//        // Name
//        let account = AccountStore.getAccounts()[indexPath.row];
//        cell!.textLabel?.text = account.getName()
//
//        // Amount
//        cell!.viewWithTag(1)?.removeFromSuperview()
//        let currencyView = UICurrencyLabel(fromBtcAmount: account.getBalance())
//        currencyView.textAlignment = .Right
//        currencyView.frame = CGRectMake(0, 0, self.tableView.frame.size.width - 40, 80)
//        currencyView.tag = 1
//        cell!.addSubview(currencyView)

        return cell!
    }

}