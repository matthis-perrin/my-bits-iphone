import Foundation

class PriceManager {

    private static var _delegates = [PriceProtocol]()
    private static var price: Double?
    private static var lastUpdate = NSDate()

    static func getPrice() -> Double? {
        return self.price
    }

    static func getLastUpdate() -> NSDate {
        return self.lastUpdate
    }

    static func setPrice(price: Double, lastUpdate: NSDate = NSDate()) {
        self.price = price
        self.lastUpdate = lastUpdate
        self._delegates.forEach({ delegate in delegate.priceDidChange() })
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