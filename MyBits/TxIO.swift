
class TxIO {
    var amount: BitcoinAmount
    var address: BitcoinAddress

    init(amount: BitcoinAmount, address: BitcoinAddress) {
        self.amount = amount
        self.address = address
    }
}

class ExternalAddressTxIO: TxIO {}

class AccountAddressTxIO: TxIO {
    private let account: Account
    private let accountAddress: AccountAddress

    init(account: Account, accountAddress: AccountAddress, amount: BitcoinAmount) {
        self.account = account
        self.accountAddress = accountAddress
        super.init(amount: amount, address: accountAddress.getBitcoinAddress())
    }
}

class AccountXpubTxIO: TxIO {
    private let account: Account
    private let accountXpub: AccountXpub

    init(account: Account, accountXpub: AccountXpub, address: BitcoinAddress, amount: BitcoinAmount) {
        self.account = account
        self.accountXpub = accountXpub
        super.init(amount: amount, address: address)
    }
}
