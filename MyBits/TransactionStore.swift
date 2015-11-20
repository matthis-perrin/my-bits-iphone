protocol TransactionProtocol: class {

    func transactionDidUpdate(newTx: BitcoinTx)

}

protocol AllTransactionsProtocol: class {

    func transactionReceived(tx: BitcoinTx)

}

class TransactionStore {

    private static var delegates = [TxHash: [TransactionProtocol]]()
    private static var globalDelegates = [AllTransactionsProtocol]()
    private static var transactions = [TxHash: BitcoinTx]()

    static func register(delegate: AllTransactionsProtocol) {
        TransactionStore.globalDelegates.append(delegate)
    }

    static func register(delegate: TransactionProtocol, forTx: BitcoinTx) {
        if var delegatesForTx = TransactionStore.delegates[forTx.hash] {
            delegatesForTx.append(delegate)
        } else {
            TransactionStore.delegates[forTx.hash] = [delegate]
        }
    }

    static func unregister(delegate: AllTransactionsProtocol) {
        TransactionStore.globalDelegates = TransactionStore.globalDelegates.filter({ d in
            return d !== delegate
        })
    }

    static func unregister(delegate: TransactionProtocol) {
        for (txHash, delegates) in TransactionStore.delegates {
            TransactionStore.delegates[txHash] = delegates.filter({ d in
                return d !== delegate
            })
        }
    }

    static func addTransaction(tx: BitcoinTx) {
        if let localTx = TransactionStore.transactions[tx.hash] {
            if localTx != tx {
                // We already know the transaction, but it has been updated
                TransactionStore.transactions[tx.hash] = tx
                if let delegates = TransactionStore.delegates[tx.hash] {
                    for delegate in delegates {
                        delegate.transactionDidUpdate(tx)
                    }
                }
            }
        }
        else {
            // This is a new transaction
            TransactionStore.transactions[tx.hash] = tx
            for delegate in TransactionStore.globalDelegates {
                delegate.transactionReceived(tx)
            }
            // Extract the different involved addresses and store weither they are present
            // in the inputs, the outputs or both
            var addresses = [BitcoinAddress: (Bool, Bool)]()
            for input in tx.inputs {
                for address in input.sourceAddresses {
                    addresses[address] = (true, false)
                }
            }
            for output in tx.outputs {
                for address in output.destinationAddresses {
                    if let inputOutputInfo = addresses[address] {
                        addresses[address] = (inputOutputInfo.0, true)
                    } else {
                        addresses[address] = (false, true)
                    }
                }
            }
            for (address, inputOutputInfo) in addresses {
                AddressStore.triggerNewTransactionReceived(tx, forAddress: address, inInputs: inputOutputInfo.0, inOutputs: inputOutputInfo.1)
            }
        }
    }

}


class TransactionStoreTestClass: TransactionProtocol {

    func load() {
        let time = "2015-11-19T18:08:40Z"
        let testTx1 = BitcoinTx(blockHash: BlockHash(), blockHeight: BlockHeight(), hash: TxHash(value: "11"), fees: TxFee(), size: TxSize(), confirmationTime: TxConfirmationTime(value: time), receptionTime: TxReceptionTime(value: time), lockTime: TxLockTime(), isDoubleSpent: false, confirmations: TxConfirmations(), inputs: [], outputs: [])
        let testTx2 = BitcoinTx(blockHash: BlockHash(), blockHeight: BlockHeight(), hash: TxHash(value: "22"), fees: TxFee(), size: TxSize(), confirmationTime: TxConfirmationTime(value: time), receptionTime: TxReceptionTime(value: time), lockTime: TxLockTime(), isDoubleSpent: false, confirmations: TxConfirmations(), inputs: [], outputs: [])
        let testTx1WithoutUpdate = BitcoinTx(blockHash: BlockHash(), blockHeight: BlockHeight(), hash: TxHash(value: "11"), fees: TxFee(), size: TxSize(), confirmationTime: TxConfirmationTime(value: time), receptionTime: TxReceptionTime(value: time), lockTime: TxLockTime(), isDoubleSpent: false, confirmations: TxConfirmations(), inputs: [], outputs: [])
        let testTx1WithUpdate = BitcoinTx(blockHash: BlockHash(value: "11"), blockHeight: BlockHeight(), hash: TxHash(value: "11"), fees: TxFee(), size: TxSize(), confirmationTime: TxConfirmationTime(value: time), receptionTime: TxReceptionTime(value: time), lockTime: TxLockTime(), isDoubleSpent: false, confirmations: TxConfirmations(), inputs: [], outputs: [])
        TransactionStore.register(self, forTx: testTx1)
        TransactionStore.addTransaction(testTx1)
        TransactionStore.addTransaction(testTx2)
        TransactionStore.addTransaction(testTx1WithoutUpdate)
        TransactionStore.addTransaction(testTx1WithUpdate)
    }

    func transactionDidUpdate(newTx: BitcoinTx) {
        print("Transaction \(newTx.hash) updated! Block hash: \(newTx.blockHash)")
    }

}