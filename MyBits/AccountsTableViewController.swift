import UIKit

class AccountsTableViewController : UITableViewController {

    private var accounts = [Account]()

    convenience init() {
        self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("accounts", comment: "")
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        self.accounts = AccountStore.getAccounts()
        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.accounts.count
        }
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Special cell for adding new accounts
        if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("CreateAccountCell")
            if (cell == nil) {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "CreateAccountCell")
                cell!.accessoryType = .DisclosureIndicator
            }
            cell!.textLabel?.text = NSLocalizedString("create new account", comment: "")
            cell!.detailTextLabel?.text = NSLocalizedString("create new account description", comment: "")
            return cell!;
        }

        // Account cell
        var cell = tableView.dequeueReusableCellWithIdentifier("AccountCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "AccountCell")
            cell!.accessoryType = .DisclosureIndicator
        }

        // Name
        let account = self.accounts[indexPath.row];
        cell!.textLabel?.text = account.getName()

        // Amount
        cell!.viewWithTag(1)?.removeFromSuperview()
        let currencyView = UICurrencyLabel(fromBtcAmount: account.getBalance())
        currencyView.textAlignment = .Right
        currencyView.frame = CGRectMake(200, 0, 80, 80)
        currencyView.tag = 1
        cell!.addSubview(currencyView)

        return cell!;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            self.navigationController?.pushViewController(NewAccountViewController(), animated: true)
            return
        }
    }

}