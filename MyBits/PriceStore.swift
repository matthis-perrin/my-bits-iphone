import Foundation

protocol PriceProtocol: class {

    func priceDidChange()

}

class PriceStore {

    private static var delegates = [PriceProtocol]()
    private static var price: Double?
    private static var currency: String?
    private static var lastUpdate = NSDate()

    static func getPrice() -> Double? {
        return PriceStore.price
    }

    static func getCurrency() -> String? {
        return PriceStore.currency
    }

    static func getLastUpdate() -> NSDate {
        return PriceStore.lastUpdate
    }

    static func setPrice(price: Double, currency: String, time: NSDate = NSDate()) {
        PriceStore.price = price
        PriceStore.currency = currency
        PriceStore.lastUpdate = time
        PriceStore.delegates.forEach({ delegate in
            delegate.priceDidChange()
        })
    }

    static func register(delegate: PriceProtocol) {
        PriceStore.delegates.append(delegate)
    }

    static func unregister(delegate: PriceProtocol) {
        PriceStore.delegates = PriceStore.delegates.filter({
            d in return d !== delegate
        })
    }

}