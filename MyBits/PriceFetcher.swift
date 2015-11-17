import Foundation

class PriceFetcher: NSObject {

    private var SUPPORTED_CURRENCY = ["USD", "EUR", "CNY", "GBP", "CAD",
                                      "PLN", "RUB", "AUD", "SEK", "BRL",
                                      "NZD", "SGD", "ZAR", "NOK", "ILS",
                                      "CHF", "RON", "MXN", "IDR"]
    private var DEFAULT_CURRENCY = "USD"

    func start() {
        self._fetchPrice()
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "_fetchPrice",
            userInfo: nil, repeats: true)
    }

    func _fetchPrice() {
        let userCurrency = NSLocale.currentLocale().objectForKey(NSLocaleCurrencyCode)
        let currency = userCurrency != nil && self.SUPPORTED_CURRENCY.contains(userCurrency as! String) ? userCurrency as! String : self.DEFAULT_CURRENCY

        let provider = BitcoinAveragePriceProvider()
        provider.getPrice(currency, callback: { price, date in
            PriceStore.setPrice(price, currency: currency, time: date)
        })
    }

}