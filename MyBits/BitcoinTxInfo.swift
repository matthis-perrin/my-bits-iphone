import Foundation

class BitcoinTxInfo {
    let inputTxIO: [TxIO]
    let outputTxIO: [TxIO]
    let involvedAccounts: [Account]

    init(inputTxIO: [TxIO], outputTxIO: [TxIO], involvedAccounts: [Account]) {
        self.inputTxIO = inputTxIO
        self.outputTxIO = outputTxIO
        self.involvedAccounts = involvedAccounts
    }

    func getAccountsBalanceDelta() -> [Account: BitcoinAmount] {
        var balances = [Account: BitcoinAmount]()

        func getAccount(txIO: TxIO) -> Account? {
            if let accountTxIO = txIO as? AccountAddressTxIO {
                return accountTxIO.getAccount()
            } else if let accountTxIO = txIO as? AccountXpubTxIO {
                return accountTxIO.getAccount()
            }
            return nil
        }

        for input in self.inputTxIO {
            if let account = getAccount(input) {
                if let balance = balances[account] {
                    balances[account] = balance - input.amount
                } else {
                    balances[account] = -input.amount
                }
            }
        }
        for output in self.outputTxIO {
            if let account = getAccount(output) {
                if let balance = balances[account] {
                    balances[account] = balance + output.amount
                } else {
                    balances[account] = output.amount
                }
            }
        }

        return balances
    }

    func getExternalBalanceDelta() -> [BitcoinAddress: BitcoinAmount] {
        var balances = [BitcoinAddress: BitcoinAmount]()

        for input in self.inputTxIO {
            if input is ExternalAddressTxIO {
                if let balance = balances[input.address] {
                    balances[input.address] = balance - input.amount
                } else {
                    balances[input.address] = -input.amount
                }
            }
        }
        for output in self.outputTxIO {
            if output is ExternalAddressTxIO {
                if let balance = balances[output.address] {
                    balances[output.address] = balance + output.amount
                } else {
                    balances[output.address] = output.amount
                }
            }
        }

        return balances
    }

    func getBalanceDelta() -> BitcoinAmount {
        var balance = BitcoinAmount(satoshis: 0)
        for input in self.inputTxIO {
            if !(input is ExternalAddressTxIO) {
                balance = balance - input.amount
            }
        }
        for output in self.outputTxIO {
            if !(output is ExternalAddressTxIO) {
                balance = balance + output.amount
            }
        }
        return balance
    }

    static func getForTx(tx: BitcoinTx) -> BitcoinTxInfo {

        var inputIO = [TxIO]()
        var outputIO = [TxIO]()
        var involvedAccounts = [Account]()
        var accountsSeen = [AccountId: Bool]()

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
        for account in AccountStore.getAccounts() {
            for input in tx.inputs {
                var found = false
                for address in input.sourceAddresses {
                    if let txIO = getTxIO(account, bitcoinAddress: address, amount: input.linkedOutputValue) {
                        inputIO.append(txIO)
                        if accountsSeen.updateValue(true, forKey: account.getId()) == nil {
                            involvedAccounts.append(account)
                        }
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
                        if accountsSeen.updateValue(true, forKey: account.getId()) == nil {
                            involvedAccounts.append(account)
                        }
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
        return BitcoinTxInfo(inputTxIO: inputIO, outputTxIO: outputIO, involvedAccounts: involvedAccounts)
    }

}