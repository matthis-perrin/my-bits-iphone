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

    static func get(txHash: TxHash) -> BitcoinTx? {
        return self.transactions[txHash]
    }

    static func getTransactions() -> [BitcoinTx] {
        return Array(self.transactions.values)
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
        } else {
            // This is a new transaction
            TransactionStore.transactions[tx.hash] = tx
            for delegate in TransactionStore.globalDelegates {
                delegate.transactionReceived(tx)
            }
        }
    }

}
