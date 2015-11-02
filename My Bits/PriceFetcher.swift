import Foundation

class PriceFetcher: NSObject {

    func start() {
        self._fetchPrice()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "_fetchPrice",
            userInfo: nil, repeats: true)
    }

    func _fetchPrice() {
        PriceManager.setPrice((Double)(arc4random_uniform(50000)) / 100.0)
    }

}