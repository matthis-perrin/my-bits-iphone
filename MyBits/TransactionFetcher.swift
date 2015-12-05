import Foundation

class TransactionFetcher {

    private static let REFRESH_DELAY = 30.0 // In seconds
    private static let REQUEST_DELAY = 0.1 // In seconds
    private static let DEBUG = true

    private static var addressesQueue = [BitcoinAddress]()
    private static let lockQueue = dispatch_queue_create("TransactionFetcherLockQueue", nil)
    private static var readyForRefresh = false

    static func queueAddresses(addresses: [BitcoinAddress]) {
        log("Queuing \(addresses.count) bitcoin addresses")
        dispatch_sync(lockQueue) {
            addressesQueue.appendContentsOf(addresses)
        }
        readyForRefresh = true
        delayRunQueue(REQUEST_DELAY)
    }

    private static func delayRunQueue(delay: Double) {
        var emptyQueue = false
        dispatch_sync(lockQueue) {
            emptyQueue = addressesQueue.isEmpty
        }
        if emptyQueue {
            if readyForRefresh {
                log("Planning refresh in \(REFRESH_DELAY) seconds")
                delayFunc(REFRESH_DELAY) {
                    queueAddresses(AddressManager.getAddresses())
                }
            }
        } else {
            delayFunc(delay, runQueue)
        }
    }

    private static func runQueue() {
        var addressOpt: BitcoinAddress?
        dispatch_sync(lockQueue) {
            if !addressesQueue.isEmpty {
                addressOpt = addressesQueue.removeFirst()
            }
        }
        guard let address = addressOpt else {
            return
        }
        log("Fetching bitcoin address \(address)")
        BlockCypher.loadTransactions(address, transactionsCallback: { transactions in
            log("Received bitcoin address \(address)")
            for tx in transactions {
                TransactionStore.addTransaction(tx)
            }
            delayRunQueue(REQUEST_DELAY)
        }) { error in
            log("Error with bitcoin address \(address)")
            dispatch_sync(lockQueue) {
                addressesQueue.append(address)
            }
            delayRunQueue(REQUEST_DELAY * 2)
        }
    }

    private static func delayFunc(delay: Double, _ closure: () -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure)
    }

    private static func log(message: String) {
        if DEBUG {
            NSLog("[TransactionFetcher] \(message)")
        }
    }

}