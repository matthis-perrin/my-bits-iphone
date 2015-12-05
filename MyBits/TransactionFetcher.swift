import Foundation

class TransactionFetcher {

    private static let FETCHING_INTERVAL = 30.0 // In seconds
    private static let REQUEST_PER_SECONDS = 1.0
    private var timer: NSTimer?


    func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(TransactionFetcher.FETCHING_INTERVAL, target: self, selector: Selector("fetchAll"), userInfo: nil, repeats: true)
    }

    static func fetchMulti(addresses: [BitcoinAddress]) {
        for (index, address) in addresses.enumerate() {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(index) * Double(1/TransactionFetcher.REQUEST_PER_SECONDS) * Double(NSEC_PER_SEC)));
            dispatch_after(delay, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                BlockCypher.loadTransactions(address)
            }
        }
    }

    @objc private func fetchAll() {
        let addresses = AddressManager.getAddresses()
        TransactionFetcher.fetchMulti(addresses)
    }

}