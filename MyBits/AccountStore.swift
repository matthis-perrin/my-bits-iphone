import Foundation

enum AccountStoreException: ErrorType {
    case AddressAlreadyInAccount
}

protocol AccountProtocol: class {

    func accountReceivedNewTransaction(account: Account, newTransaction: BitcoinTx)
    func accountReceivedNewAddress(account: Account, newAccountAddress: AccountAddress)

}

class AccountStore {

    private static var delegates = [AccountId: [AccountProtocol]]()
    private static var accounts = [Account]()

    static func register(delegate: AccountProtocol, forAccount: Account) {
        if var delegatesForAccount = AccountStore.delegates[forAccount.accountId] {
            delegatesForAccount.append(delegate)
        } else {
            AccountStore.delegates[forAccount.accountId] = [delegate]
        }
    }

    static func unregister(delegate: AccountProtocol) {
        for (accountId, delegates) in AccountStore.delegates {
            AccountStore.delegates[accountId] = delegates.filter({ d in
                return d !== delegate
            })
        }
    }

    static func getAccounts() -> [Account] {
        return AccountStore.accounts
    }

    static func addAccount(account: Account) {
        if !AccountStore.accounts.contains({ acct in return acct.accountId == account.accountId }) {
            AccountStore.accounts.append(account)
        }
    }

    // TODO - throw AddressAlreadyInXpub
    static func addAddress(account: Account, accountAddress: AccountAddress) throws {
        try account.addAddress(accountAddress)
        AddressManager.rebuildAddressPool()
        if let delegates = AccountStore.delegates[account.getId()] {
            for delegate in delegates {
                delegate.accountReceivedNewAddress(account, newAccountAddress: accountAddress)
            }
        }
    }

    // This method is called manually by the TransactionStore for each
    // new transaction received. We do this manually instead of using the
    // AllTransactionsProtocol because the class is static.
    static func triggerNewTransactionReceived(tx: BitcoinTx) {
        var accountsToNotify = [Account]()
        for account in AccountStore.accounts {
            var addresses = [BitcoinAddress]()
            for input in tx.inputs {
                for address in input.sourceAddresses {
                    addresses.append(address)
                }
            }
            for output in tx.outputs {
                for address in output.destinationAddresses {
                    addresses.append(address)
                }
            }
            for address in account.accountAddresses {
                if addresses.contains(address.getBitcoinAddress()) {
                    accountsToNotify.append(account)
                    break
                }
            }
        }

        for accountToNotify in accountsToNotify {
            if let delegates = AccountStore.delegates[accountToNotify.accountId] {
                for delegate in delegates {
                    delegate.accountReceivedNewTransaction(accountToNotify, newTransaction: tx)
                }
            }
        }

    }

}


// Models

class AccountId: Hashable {
    var value: Int
    init(value: Int) {
        self.value = value
    }
    static func randomId() -> AccountId {
        return AccountId(value: Int(arc4random()))
    }
    var hashValue: Int {
        get {
            return value
        }
    }
}
func ==(left: AccountId, right: AccountId) -> Bool {
    return left.value == right.value
}

class Account {

    private var accountId: AccountId
    private var accountName: String
    private var accountAddresses: [AccountAddress]

    init(accountName: String) {
        self.accountName = accountName
        self.accountId = AccountId.randomId()
        self.accountAddresses = [AccountAddress]()
    }

    internal func addAddress(accountAddress: AccountAddress) throws {
        if self.accountAddresses.contains({ address in return address.getBitcoinAddress() == accountAddress.getBitcoinAddress() }) {
            throw AccountStoreException.AddressAlreadyInAccount
        }
        self.accountAddresses.append(accountAddress)
    }

    func getId() -> AccountId {
        return self.accountId
    }

    func getName() -> String {
        return self.accountName
    }

    func getAddresses() -> [AccountAddress] {
        return self.accountAddresses
    }

}
