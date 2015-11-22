import UIKit
import QRCodeReader
import AVFoundation

class NewAccountViewController: UIViewController {

    private var nameTextField: UITextField?
    private var addressTextField: UITextField?
    private lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("new account", comment: "")
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = .None

        var currentY: CGFloat = 10;
        var label: UILabel
        var textField: UITextField
        var button: UIButton

        label = UILabel(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 20))
        label.text = NSLocalizedString("account name", comment: "")
        self.view.addSubview(label)
        currentY += label.frame.height

        textField = UITextField(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 40))
        textField.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(textField)
        currentY += textField.frame.height + 20
        self.nameTextField = textField

        label = UILabel(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 20))
        label.text = NSLocalizedString("public address or xpub", comment: "")
        self.view.addSubview(label)
        currentY += label.frame.height

        textField = UITextField(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 40))
        textField.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(textField)
        currentY += textField.frame.height + 10
        self.addressTextField = textField

        if QRCodeReader.isAvailable() {
            button = UIButton(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 30))
            button.setTitle(NSLocalizedString("scan qrcode", comment: ""), forState: .Normal)
            button.backgroundColor = UIColor.blackColor()
            button.addTarget(self, action: Selector("startCamera"), forControlEvents: .TouchUpInside)
            self.view.addSubview(button)
            currentY += button.frame.height + 50
        } else {
            currentY += 40
        }

        button = UIButton(frame: CGRectMake(10, currentY, self.view.frame.size.width - 20, 30))
        button.setTitle(NSLocalizedString("add account", comment: ""), forState: .Normal)
        button.backgroundColor = UIColor.blackColor()
        button.addTarget(self, action: Selector("addAccount"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
    }

    @objc private func startCamera() {
        self.reader.completionBlock = { result in
            self.dismissViewControllerAnimated(true, completion: nil)
            if let address = result {
                self.addressTextField?.text = address
            }
        }
        self.reader.modalPresentationStyle = .OverFullScreen
        self.presentViewController(reader, animated: true, completion: nil)
    }

    @objc private func addAccount() {
        if self.nameTextField!.text == "" {
            let alertController = UIAlertController(title: NSLocalizedString("textfield error", comment: ""), message: NSLocalizedString("name required", comment: ""), preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }

        if self.addressTextField!.text == "" {
            let alertController = UIAlertController(title: NSLocalizedString("textfield error", comment: ""), message: NSLocalizedString("address required", comment: ""), preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }

        let account = Account(accountName: self.nameTextField!.text!)

        do {
            // TODO - add logic for XPUBs
            try account.addAddress(AccountAddress(bitcoinAddress: BitcoinAddress(value: self.addressTextField!.text!)))
        } catch let e {
            print(e)
            return
        }

        if !AccountStore.addAccount(account) {
            print("Error saving object")
            return
        }

        self.navigationController?.popViewControllerAnimated(true)
    }

}