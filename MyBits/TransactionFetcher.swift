import Foundation

class TransactionFetcher {

    private let FETCHING_INTERVAL = 30.0 // In seconds
    private var timer: NSTimer?


    func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.FETCHING_INTERVAL, target: self, selector: Selector("fetchAll"), userInfo: nil, repeats: true)
    }

    static func fetchOne(address: BitcoinAddress) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            BlockCypher.loadTransactions(address)
        }
    }

    static func fetchMulti(addresses: [BitcoinAddress]) {
        for address in addresses {
            TransactionFetcher.fetchOne(address)
            usleep(500000) // 0.5 second
        }
    }

    @objc private func fetchAll() {
        let addresses = AddressManager.getAddresses()
        TransactionFetcher.fetchMulti(addresses)
    }

}