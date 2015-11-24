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
}