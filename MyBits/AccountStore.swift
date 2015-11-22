import Foundation

enum AccountStoreException: ErrorType {
    case AddressAlreadyInAccount, XpubAlreadyInAccount
}

protocol AccountProtocol: class {

    func accountReceivedNewTransaction(account: Account, newTransaction: BitcoinTx)
    func accountReceivedNewAddress(account: Account, newAccountAddress: AccountAddress)
    func accountReceivedNewXpub(account: Account, newAccountXpub: AccountXpub)

}

class AccountStore {

    private static var delegates = [AccountId: [AccountProtocol]]()
    private static var accounts = [Account]()

    static func initialize() throws {
        // Accounts
        let accounts = DB.getAccounts()
        AccountStore.accounts = accounts

        // Public addresses
        for account in accounts {
            for address in DB.getBitcoinAddresses(account) {
                try AccountStore.addAddress(account, accountAddress: AccountAddress(bitcoinAddress: address), saveToDisk: false)
            }
        }

        // Master Public Keys
        for account in accounts {
            for mpk in DB.getMasterPublicKeys(account) {
                let accountXpub =  AccountXpub(masterPublicKey: mpk)
                try AccountStore.addXpub(account, accountXpub: accountXpub, saveToDisk: false)
                accountXpub.setAddresses(DB.getBitcoinAddresses(mpk), start: 0)
            }
        }
    }

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

    static func addAccount(account: Account) throws {
        if !AccountStore.accounts.contains({ acct in return acct.accountId == account.accountId }) {
            try DB.insertAccount(account)
            AccountStore.accounts.append(account)
        }
    }

    // TODO - throw AddressAlreadyInXpub
    static func addAddress(account: Account, accountAddress: AccountAddress, saveToDisk: Bool = true) throws {
        try account.addAddress(accountAddress)
        if saveToDisk {
            try DB.insertBitcoinAddress(accountAddress.getBitcoinAddress(), account: account)
        }
        AddressManager.rebuildAddressPool()
        if let delegates = AccountStore.delegates[account.getId()] {
            for delegate in delegates {
                delegate.accountReceivedNewAddress(account, newAccountAddress: accountAddress)
            }
        }
    }

    static func addXpub(account: Account, accountXpub: AccountXpub, saveToDisk: Bool = true) throws {
        try account.addXpub(accountXpub)
        if saveToDisk {
            try DB.insertMasterPublicKey(accountXpub.getMasterPublicKey(), account: account)
        }
        AddressManager.rebuildAddressPool()
        if let delegates = AccountStore.delegates[account.getId()] {
            for delegate in delegates {
                delegate.accountReceivedNewXpub(account, newAccountXpub: accountXpub)
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
            var found = false
            for address in account.getAddresses() {
                if addresses.contains(address.getBitcoinAddress()) {
                    accountsToNotify.append(account)
                    found = true
                    break
                }
            }
            for xpub in account.getXpubs() {
                if found {
                    break
                }
                for address in xpub.getAddresses() {
                    if addresses.contains(address) {
                        accountsToNotify.append(account)
                        found = true
                        break
                    }
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

class AccountId: GenericId {}

class Account {

    private var accountId: AccountId
    private var accountName: String
    private var accountAddresses: [AccountAddress]
    private var accountXpubs: [AccountXpub]

    init(accountId: AccountId, accountName: String) {
        self.accountId = accountId
        self.accountName = accountName
        self.accountAddresses = [AccountAddress]()
        self.accountXpubs = [AccountXpub]()
    }

    convenience init(accountName: String) {
        self.init(accountId: AccountId(), accountName: accountName)
    }

    internal func addAddress(accountAddress: AccountAddress) throws {
        if self.accountAddresses.contains({ address in return address.getBitcoinAddress() == accountAddress.getBitcoinAddress() }) {
            throw AccountStoreException.AddressAlreadyInAccount
        }
        self.accountAddresses.append(accountAddress)
    }

    internal func addXpub(accountXpub: AccountXpub) throws {
        if self.accountXpubs.contains(accountXpub) {
            throw AccountStoreException.XpubAlreadyInAccount
        }
        self.accountXpubs.append(accountXpub)
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

    func getXpubs() -> [AccountXpub] {
        return self.accountXpubs
    }

    func getBalance() -> BitcoinAmount {
        var balance = BitcoinAmount(satoshis: 0)
        for address in self.accountAddresses {
            balance = balance + address.getBalance()
        }
        for xpub in self.accountXpubs {
            balance = balance + xpub.getBalance()
        }
        return balance
    }

}
