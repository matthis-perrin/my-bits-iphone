import Foundation

enum AccountStoreException: ErrorType {
    case AddressAlreadyInAccount, XpubAlreadyInAccount
}

protocol MultiAccountProtocol: class {
    func userReceivedNewTransaction(newTx: BitcoinTx, inputs: [TxIO], outputs: [TxIO])
}

protocol AccountProtocol: class {

    func accountReceivedNewAddress(account: Account, newAccountAddress: AccountAddress)
    func accountReceivedNewXpub(account: Account, newAccountXpub: AccountXpub)

}

class AccountStore {

    private static var accountDelegates = [AccountId: [AccountProtocol]]()
    private static var multiAccountDelegates = [MultiAccountProtocol]()
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
                let accountXpub = AccountXpub(masterPublicKey: mpk, addresses: DB.getBitcoinAddresses(mpk))
                try AccountStore.addXpub(account, accountXpub: accountXpub, saveToDisk: false)
            }
        }
    }

    static func register(delegate: MultiAccountProtocol) {
        self.multiAccountDelegates.append(delegate)
    }

    static func register(delegate: AccountProtocol, forAccount: Account) {
        if var delegatesForAccount = AccountStore.accountDelegates[forAccount.accountId] {
            delegatesForAccount.append(delegate)
        } else {
            AccountStore.accountDelegates[forAccount.accountId] = [delegate]
        }
    }

    static func unregister(delegate: MultiAccountProtocol) {
        AccountStore.multiAccountDelegates = AccountStore.multiAccountDelegates.filter({ d in
            return d !== delegate
        })
    }

    static func unregister(delegate: AccountProtocol) {
        for (accountId, delegates) in AccountStore.accountDelegates {
            AccountStore.accountDelegates[accountId] = delegates.filter({ d in
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
        if let delegates = AccountStore.accountDelegates[account.getId()] {
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
        if let delegates = AccountStore.accountDelegates[account.getId()] {
            for delegate in delegates {
                delegate.accountReceivedNewXpub(account, newAccountXpub: accountXpub)
            }
        }
    }

    // This method is called manually by the TransactionStore for each
    // new transaction received. We do this manually instead of using the
    // AllTransactionsProtocol because the class is static.
    static func triggerNewTransactionReceived(tx: BitcoinTx) {
        var inputIO = [TxIO]()
        var outputIO = [TxIO]()

        // Look into `account` for the address `bitcoinAddress` and generate a TxIO
        func getTxIO (account: Account, bitcoinAddress: BitcoinAddress, amount: BitcoinAmount) -> TxIO? {
            for aAddress in account.getAddresses() {
                if bitcoinAddress == aAddress.getBitcoinAddress() {
                    return AccountAddressTxIO(account: account, accountAddress: aAddress, amount: amount)
                }
            }
            for xpub in account.getXpubs() {
                for xAddress in xpub.getAddresses() {
                    if bitcoinAddress == xAddress {
                        return AccountXpubTxIO(account: account, accountXpub: xpub, address: xAddress, amount: amount)
                    }
                }
            }
            return nil
        }

        // Generates all the TxIO for this transaction
        for account in AccountStore.accounts {
            for input in tx.inputs {
                var found = false
                for address in input.sourceAddresses {
                    if let txIO = getTxIO(account, bitcoinAddress: address, amount: input.linkedOutputValue) {
                        inputIO.append(txIO)
                        found = true
                        break
                    }
                }
                if !found {
                    if let address = input.sourceAddresses.first {
                        inputIO.append(ExternalAddressTxIO(amount: input.linkedOutputValue, address: address))
                    }
                }
            }
            for output in tx.outputs {
                var found = false
                for address in output.destinationAddresses {
                    if let txIO = getTxIO(account, bitcoinAddress: address, amount: output.value) {
                        outputIO.append(txIO)
                        found = true
                        break
                    }
                }
                if !found {
                    if let address = output.destinationAddresses.first {
                        inputIO.append(ExternalAddressTxIO(amount: output.value, address: address))
                    }
                }
            }
        }
        for delegate in self.multiAccountDelegates {
            delegate.userReceivedNewTransaction(tx, inputs: inputIO, outputs: outputIO)
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
