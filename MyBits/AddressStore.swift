protocol AddressProtocol: class {

    func addressReceivedNewTransaction(address: AccountAddress, newTx: BitcoinTx, inInputs: Bool, inOutputs: Bool)

}

class AddressStore {

    private static var delegates = [BitcoinAddress: [AddressProtocol]]()
    private static var accountAddresses = [AccountAddress]()

    static func register(delegate: AddressProtocol, forAddress: AccountAddress) {
        if var delegatesForAddress = AddressStore.delegates[forAddress.bitcoinAddress] {
            delegatesForAddress.append(delegate)
        } else {
            AddressStore.delegates[forAddress.bitcoinAddress] = [delegate]
        }
    }

    static func unregister(delegate: AddressProtocol) {
        for (bitcoinAddress, delegates) in AddressStore.delegates {
            AddressStore.delegates[bitcoinAddress] = delegates.filter({ d in
                return d !== delegate
            })
        }
    }

    static func addAddress(address: AccountAddress) {
        if !AddressStore.accountAddresses.contains({ addr in return addr.bitcoinAddress == address.bitcoinAddress }) {
            AddressStore.accountAddresses.append(address)
        }
    }

    static func triggerNewTransactionReceived(tx: BitcoinTx, forAddress: BitcoinAddress, inInputs: Bool, inOutputs: Bool) {
        if let delegates = AddressStore.delegates[forAddress] {
            let matchingAccountAddresses = AddressStore.accountAddresses.filter({ accountAddress in return accountAddress.bitcoinAddress == forAddress })
            if let accountAddress = matchingAccountAddresses.first {
                for delegate in delegates {
                    delegate.addressReceivedNewTransaction(accountAddress, newTx: tx, inInputs: inInputs, inOutputs: inOutputs)
                }
            }
        }
    }

}


// Models

class AccountAddress {

    private var bitcoinAddress: BitcoinAddress

    init(bitcoinAddress: BitcoinAddress) {
        self.bitcoinAddress = bitcoinAddress
    }

    func getBitcoinAddress() -> BitcoinAddress {
        return self.bitcoinAddress
    }

    func getBalance() -> BitcoinAmount {
        return self.bitcoinAddress.getBalance()
    }

}