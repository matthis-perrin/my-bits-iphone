import Foundation

protocol XpubProtocol: class {

    func xpubReceivedNewAddress(xpub: AccountXpub, newAccountAddress: BitcoinAddress)

}

class XpubStore {

    private static var delegates = [AccountXpub: [XpubProtocol]]()

    static func register(delegate: XpubProtocol, forXpub: AccountXpub) {
        if var delegatesForAccount = XpubStore.delegates[forXpub] {
            delegatesForAccount.append(delegate)
        } else {
            XpubStore.delegates[forXpub] = [delegate]
        }
    }

    static func unregister(delegate: XpubProtocol) {
        for (xpub, delegates) in XpubStore.delegates {
            XpubStore.delegates[xpub] = delegates.filter({ d in
                return d !== delegate
            })
        }
    }

    static func triggerXpubReceivedAddress(xpub: AccountXpub, address: BitcoinAddress) {
        if let delegates = XpubStore.delegates[xpub] {
            for delegate in delegates {
                delegate.xpubReceivedNewAddress(xpub, newAccountAddress: address)
            }
        }
    }

}


// Models

class AccountXpub: Hashable, AllTransactionsProtocol {

    private static let CLEAN_ADDRESSES_LENGTH = 20
    private let masterPublicKey: MasterPublicKey
    private var addresses: [BitcoinAddress]
    // Flag that indicates we're fetching new addresses from the server for this xpub.
    private var isGeneratingNewAddresses: Bool

    init(masterPublicKey: MasterPublicKey, addresses: [BitcoinAddress], generateAddresses: Bool) {
        self.masterPublicKey = masterPublicKey
        self.addresses = addresses
        self.isGeneratingNewAddresses = false
        TransactionStore.register(self)
        if generateAddresses {
            Server.generateAddresses(self, start: 0, count: 19)
//            self.generateNextAddresses(AccountXpub.CLEAN_ADDRESSES_LENGTH)
        }
    }

    convenience init(masterPublicKey: MasterPublicKey) {
        self.init(masterPublicKey: masterPublicKey, addresses: [BitcoinAddress](), generateAddresses: true)
    }

    func transactionReceived(tx: BitcoinTx) {
        if self.addresses.isEmpty {
            return
        }
        let txAddresses = tx.getInvolvedAddresses()
        let max = min(AccountXpub.CLEAN_ADDRESSES_LENGTH - 1, self.addresses.count - 1)
        for (index, address) in addresses.reverse()[0...max].enumerate() {
            if txAddresses.contains(address) {
                self.generateNextAddresses(AccountXpub.CLEAN_ADDRESSES_LENGTH - index)
                break
            }
        }
    }
    func getMasterPublicKey() -> MasterPublicKey {
        return self.masterPublicKey
    }
    func getAddresses() -> [BitcoinAddress] {
        return self.addresses
    }
    func getBalance() -> BitcoinAmount {
        var balance = BitcoinAmount(satoshis: 0)
        for address in self.addresses {
            balance = balance + address.getBalance()
        }
        return balance
    }
    func setAddresses(addresses: [BitcoinAddress], start: Int) throws {
        for address in addresses {
            self.addresses.append(address)
            try DB.insertBitcoinAddress(address, masterPublicKey: self.masterPublicKey)
            XpubStore.triggerXpubReceivedAddress(self, address: address)
        }
        self.isGeneratingNewAddresses = false
        AddressManager.rebuildAddressPool()
    }
    private func generateNextAddresses(count: Int) {
//        if self.isGeneratingNewAddresses {
//            // Retry in 2 seconds
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//                self.generateNextAddresses(count)
//            });
//            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("generateNextAddresses"), userInfo: [count], repeats: false)
//        } else {
//            self.isGeneratingNewAddresses = true
//            Server.generateAddresses(self, start: self.addresses.count, count: count)
//        }
    }
    func contains(address: BitcoinAddress) -> Bool {
        return self.addresses.contains(address)
    }
    var hashValue: Int {
        get {
            return masterPublicKey.hashValue
        }
    }
    func copy() -> AccountXpub {
        return AccountXpub(masterPublicKey: self.masterPublicKey, addresses: self.addresses.map() { return $0.copy() }, generateAddresses: true)
    }

}
func ==(left: AccountXpub, right: AccountXpub) -> Bool {
    return left.masterPublicKey == right.masterPublicKey
}
