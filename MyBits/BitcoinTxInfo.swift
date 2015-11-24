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
}