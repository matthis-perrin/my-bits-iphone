import UIKit

class AccountsTableViewController : UITableViewController {

    private var accounts = ["", ""]

    convenience init() {
        self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("accounts", comment: "")
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

        var cell = tableView.dequeueReusableCellWithIdentifier("AccountCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "AccountCell")
            cell!.accessoryType = .DisclosureIndicator
        }
        cell!.textLabel?.text = "Main Cold Storage"
        cell!.viewWithTag(1)?.removeFromSuperview()
        let currencyView = UICurrencyLabel(fromBitcoin: 100, displayCurrency: .Bitcoin)
        currencyView.textAlignment = .Right
        currencyView.frame = CGRectMake(cell!.frame.size.width - 80, 0, 80, 80)
        currencyView.tag = 1
        cell!.addSubview(currencyView)
        return cell!;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            self.navigationController?.pushViewController(AccountNameViewController(), animated: true)
            return
        }
    }

}