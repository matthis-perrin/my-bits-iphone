import Foundation

class PriceFetcher: NSObject {

    func start() {
        self._fetchPrice()
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "_fetchPrice",
            userInfo: nil, repeats: true)
    }

    func _fetchPrice() {
        let provider = BitcoinAveragePriceProvider()
        provider.getPrice(PriceManager.setPrice)
    }

}