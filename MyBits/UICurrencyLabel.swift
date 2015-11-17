import Foundation
import UIKit

class UICurrencyLabel: UILabel, PrivacyProtocol, PriceProtocol {

    // Data
    // ----

    private var amount: Double
    private var amountCurrencyType: CurrencyType
    private var displayCurrencyType: CurrencyType
    private var respectPrivacy: Bool


    // Constructors
    // ------------

    required convenience init?(coder: NSCoder) {
        self.init(frame: CGRectZero)
    }

    override convenience init(frame: CGRect) {
        self.init(frame: frame, amount: 0, amountCurrency: .Fiat, displayCurrency: .Fiat)
    }

    convenience init(frame: CGRect, fromFiat amount: Double) {
        self.init(frame: frame, amount: amount, amountCurrency: .Fiat, displayCurrency: .Fiat)
    }

    convenience init(frame: CGRect, fromBtc amount: Double) {
        self.init(frame: frame, amount: amount, amountCurrency: .Bitcoin, displayCurrency: .Bitcoin)
    }

    convenience init(frame: CGRect, fromFiat amount: Double, displayCurrency: CurrencyType) {
        self.init(frame: frame, amount: amount, amountCurrency: .Fiat, displayCurrency: displayCurrency)
    }

    convenience init(frame: CGRect, fromBitcoin amount: Double, displayCurrency: CurrencyType) {
        self.init(frame: frame, amount: amount, amountCurrency: .Bitcoin, displayCurrency: displayCurrency)
    }

    init (frame: CGRect, amount: Double, amountCurrency: CurrencyType, displayCurrency: CurrencyType) {
        self.amount = amount
        self.amountCurrencyType = amountCurrency
        self.displayCurrencyType = displayCurrency
        self.respectPrivacy = true
        super.init(frame: frame)
        PrivacyManager.register(self)
        PriceManager.register(self)
        updateText()
    }


    // Internal methods
    // ----------------

    private func updateText() {
        // If we respect the privacy settings and if it's enabled, don't show
        // the amount, show a placeholder instead.
        if self.respectPrivacy && PrivacyManager.getPrivacy() {
            self.text = "xxxx"
            return
        }

        // If the currency of the amount is different from the currency displayed,
        // we need to do a conversion.
        var amountToDisplay: Double?
        var currencyToDisplay: String?
        if self.amountCurrencyType != self.displayCurrencyType {
            if let price = PriceManager.getPrice(), currency = PriceManager.getCurrency() {
                currencyToDisplay = self.displayCurrencyType == .Bitcoin ? "BTC" : currency
                amountToDisplay = self.displayCurrencyType == .Bitcoin ? self.amount / price : self.amount * price
            }
        } else {
            amountToDisplay = self.amount
            currencyToDisplay = self.displayCurrencyType == .Bitcoin ? "BTC" : NSLocale.currentLocale().objectForKey(NSLocaleCurrencyCode) as! String
        }

        // Display the amount with the right currency and correct internationalization
        if let amount = amountToDisplay, currency = currencyToDisplay {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = NSLocale.currentLocale()
            numberFormatter.currencyCode = currency
            numberFormatter.numberStyle = .CurrencyStyle
            let amountString = numberFormatter.stringFromNumber(amount)

            if let amountString = amountString {

                // If the currency is "BTC" we have some extra work to do to display the bitcoin symbol
                if currency == "BTC" {
                    // Safety in case the substring "BTC" is not there
                    if let currencyRange = amountString.rangeOfString(currency) {
                        // Get the range for the "BTC" symbol
                        let start = amountString.startIndex.distanceTo(currencyRange.startIndex)
                        let amountWithSymbol = amountString.stringByReplacingCharactersInRange(currencyRange, withString: "A")
                        let symbolRange = NSMakeRange(start, 1)
                        // Create an attributed string for the amount
                        let attributedAmount = NSMutableAttributedString(string: amountWithSymbol)
                        // Customize the font of the "BTC" symbol to use our "btc-symbol" font
                        if let font = UIFont(name: "btc-symbol-regular", size: self.font.pointSize) {
                            attributedAmount.addAttribute(NSFontAttributeName, value: font, range: symbolRange)
                            // Use the default system font for the rest of the string
                            attributedAmount.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(self.font.pointSize), range: NSMakeRange(1, amountWithSymbol.startIndex.distanceTo(amountWithSymbol.endIndex) - 1))
                            self.attributedText = attributedAmount
                        } else {
                            self.text = amountString
                        }
                    } else {
                        self.text = amountString
                    }
                } else {
                    self.text = amountString
                }
            } else {
                self.text = ""
            }


        } else {
            self.text = ""
        }

    }


    // Public methods
    // --------------

    func setRespectPrivacy(respectPrivacy: Bool) {
        self.respectPrivacy = respectPrivacy
    }


    // Protocol implementations
    // ------------------------

    func privacyDidChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateText()
        }
    }

    func priceDidChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateText()
        }
    }


    // UILabel override
    // ----------------

    override internal var font: UIFont! {
        get {
            return super.font
        }
        set {
            super.font = newValue
            self.updateText()
        }
    }



}
