import Foundation
import UIKit

enum CurrencyType {
    case Fiat, Bitcoin
}

class UICurrencyLabel: UILabel, PrivacyProtocol, PriceProtocol {

    // Data
    // ----

    private var amount: Double
    private var amountCurrencyType: CurrencyType
    private var displayCurrencyType: CurrencyType
    private var respectPrivacy: Bool
    private var prefix: String = ""
    private var suffix: String = ""


    // Constructors
    // ------------

    required convenience init?(coder: NSCoder) {
        self.init()
    }

    convenience init() {
        self.init(amount: 0, amountCurrency: .Fiat, displayCurrency: .Fiat)
    }

    convenience init(fromFiat amount: Double) {
        self.init(amount: amount, amountCurrency: .Fiat, displayCurrency: .Fiat)
    }

    convenience init(fromBtc amount: Double) {
        self.init(amount: amount, amountCurrency: .Bitcoin, displayCurrency: .Bitcoin)
    }

    convenience init(fromBtcAmount amount: BitcoinAmount) {
        self.init(fromBtc: amount.getBitcoinAmount())
    }

    convenience init(fromFiat amount: Double, displayCurrency: CurrencyType) {
        self.init(amount: amount, amountCurrency: .Fiat, displayCurrency: displayCurrency)
    }

    convenience init(fromBitcoin amount: Double, displayCurrency: CurrencyType) {
        self.init(amount: amount, amountCurrency: .Bitcoin, displayCurrency: displayCurrency)
    }

    init (amount: Double, amountCurrency: CurrencyType, displayCurrency: CurrencyType) {
        self.amount = amount
        self.amountCurrencyType = amountCurrency
        self.displayCurrencyType = displayCurrency
        self.respectPrivacy = true
        super.init(frame: CGRectZero)
        PrivacyStore.register(self)
        PriceStore.register(self)
        updateText()
    }


    // Internal methods
    // ----------------

    private func updateText() {
        // If we respect the privacy settings and if it's enabled, don't show
        // the amount, show a placeholder instead.
        if self.respectPrivacy && PrivacyStore.getPrivacy() {
            self.text = self.prefix + "XXXX" + self.suffix
            return
        }

        // If the currency of the amount is different from the currency displayed,
        // we need to do a conversion.
        var amountToDisplay: Double?
        var currencyToDisplay: String?
        if self.amountCurrencyType != self.displayCurrencyType {
            if let price = PriceStore.getPrice(), currency = PriceStore.getCurrency() {
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
                // Prepend and append the prefix and suffix
                let fullAmountString = self.prefix + amountString + self.suffix

                // If the currency is "BTC" we have some extra work to do to display the bitcoin symbol
                if currency == "BTC" {
                    // Safety in case the substring "BTC" is not there
                    if let currencyRange = fullAmountString.rangeOfString(currency) {
                        // Get the range for the "BTC" symbol
                        let start = fullAmountString.startIndex.distanceTo(currencyRange.startIndex)
                        let amountWithSymbol = fullAmountString.stringByReplacingCharactersInRange(currencyRange, withString: "A")
                        let symbolRange = NSMakeRange(start, 1)
                        // Create an attributed string for the amount
                        let attributedAmount = NSMutableAttributedString(string: amountWithSymbol)
                        // Customize the font of the "BTC" symbol to use our "btc-symbol" font
                        if let font = UIFont(name: "btc-symbol-regular", size: self.font.pointSize) {
                            attributedAmount.addAttribute(NSFontAttributeName, value: font, range: symbolRange)
                            // Use the default system font for the rest of the string
                            let preRange = NSMakeRange(0, start)
                            let postRange = NSMakeRange(start + 1, amountWithSymbol.startIndex.distanceTo(amountWithSymbol.endIndex) - start - 1)
                            attributedAmount.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(self.font.pointSize), range: preRange)
                            attributedAmount.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(self.font.pointSize), range: postRange)
                            self.attributedText = attributedAmount
                        } else {
                            self.text = fullAmountString
                        }
                    } else {
                        self.text = fullAmountString
                    }
                } else {
                    self.text = fullAmountString
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
        self.updateText()
    }

    func setFontSize(pointSize: CGFloat) {
        self.font = UIFont(name: self.font.familyName, size: pointSize)
        self.updateText()
    }

    func setPrefix(prefix: String) {
        self.prefix = prefix
        self.updateText()
    }

    func setSuffix(suffix: String) {
        self.suffix = suffix
        self.updateText()
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
