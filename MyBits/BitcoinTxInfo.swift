import Foundation

class BitcoinTxInfo {
    var inputTxIO: [TxIO]
    var outputTxIO: [TxIO]
    var involvedAccounts: [Account]

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

    func withoutChange() -> BitcoinTxInfo {
        let copy = self.copy()
        for input in copy.inputTxIO {
            if let input = input as? AccountXpubTxIO {
                for output in copy.outputTxIO {
                    if let output = output as? AccountXpubTxIO {
                        if output.getAccountXpub().contains(input.address) {
                            let amount = min(input.amount, output.amount)
                            input.amount -= amount
                            output.amount -= amount
                            break
                        }
                    }
                }
            } else {
                for output in copy.outputTxIO {
                    if input.address == output.address {
                        let amount = min(input.amount, output.amount).copy()
                        input.amount -= amount
                        output.amount -= amount
                        break
                    }
                }
            }
        }
        copy.inputTxIO = copy.inputTxIO.filter() { return $0.amount > 0 }
        copy.outputTxIO = copy.outputTxIO.filter() { return $0.amount > 0 }
        var accountsSeen = [AccountId: Bool]()
        func readAccountFromTxIO(txIO: TxIO) -> Void {
            if let txIO = txIO as? AccountXpubTxIO {
                accountsSeen[txIO.getAccount().getId()] = true
            } else if let txIO = txIO as? AccountXpubTxIO {
                accountsSeen[txIO.getAccount().getId()] = true
            }
        }
        for input in copy.inputTxIO {
            readAccountFromTxIO(input)
        }
        for output in copy.outputTxIO {
            readAccountFromTxIO(output)
        }
        copy.involvedAccounts = AccountStore.getAccounts().filter() { account in accountsSeen.contains() { $0.0 == account.getId() } }
        return copy
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
                        outputIO.append(ExternalAddressTxIO(amount: output.value, address: address))
                    }
                }
            }
        }
        return BitcoinTxInfo(inputTxIO: inputIO, outputTxIO: outputIO, involvedAccounts: involvedAccounts)
    }

    func copy() -> BitcoinTxInfo {
        let clonedInputTxIO = self.inputTxIO.map() { return $0.copy() }
        let clonedOutputTxIO = self.outputTxIO.map() { return $0.copy() }
        let clonedInvolvedAccounts = self.involvedAccounts.map() { return $0.copy() }
        return BitcoinTxInfo(inputTxIO: clonedInputTxIO, outputTxIO: clonedOutputTxIO, involvedAccounts: clonedInvolvedAccounts)
    }

}