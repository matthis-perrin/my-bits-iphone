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
            self.text = numberFormatter.stringFromNumber(amount)
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


}
