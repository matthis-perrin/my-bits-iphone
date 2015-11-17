import Foundation

protocol PriceProtocol: class {

    func priceDidChange()

}

class PriceStore {

    private static var _delegates = [PriceProtocol]()
    private static var price: Double?
    private static var currency: String?
    private static var lastUpdate = NSDate()

    static func getPrice() -> Double? {
        return self.price
    }

    static func getCurrency() -> String? {
        return self.currency
    }

    static func getLastUpdate() -> NSDate {
        return self.lastUpdate
    }

    static func setPrice(price: Double, currency: String, time: NSDate = NSDate()) {
        self.price = price
        self.currency = currency
        self.lastUpdate = time
        self._delegates.forEach({ delegate in
            delegate.priceDidChange()
        })
    }

    static func register(delegate: PriceProtocol) {
        self._delegates.append(delegate)
    }

    static func unregister(delegate: PriceProtocol) {
        self._delegates = self._delegates.filter({
            d in return d !== delegate
        })
    }

}