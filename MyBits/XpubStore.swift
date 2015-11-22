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

    init(masterPublicKey: MasterPublicKey) {
        self.masterPublicKey = masterPublicKey
        self.addresses = [BitcoinAddress]()
        self.isGeneratingNewAddresses = false
        TransactionStore.register(self)
        self.generateNextAddresses(AccountXpub.CLEAN_ADDRESSES_LENGTH)
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
            }
        }
    }
    func getMasterPublicKey() -> MasterPublicKey {
        return self.masterPublicKey
    }
    func setAddresses(addresses: [BitcoinAddress], start: Int) {
        for address in addresses {
            self.addresses.append(address)
            XpubStore.triggerXpubReceivedAddress(self, address: address)
        }
        AddressManager.rebuildAddressPool()
        self.isGeneratingNewAddresses = false
    }
    private func generateNextAddresses(count: Int) {
        if !self.isGeneratingNewAddresses {
            self.isGeneratingNewAddresses = true
            Server.generateAddresses(self, start: self.addresses.count, count: count)
        }
    }
    var hashValue: Int {
        get {
            return masterPublicKey.hashValue
        }
    }
    
}
func ==(left: AccountXpub, right: AccountXpub) -> Bool {
    return left.masterPublicKey == right.masterPublicKey
}
