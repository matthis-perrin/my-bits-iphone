class BitcoinTx {

    let blockHash: BlockHash
    let blockHeight: BlockHeight
    let hash: TxHash
    let fees: TxFee
    let size: TxSize
    let confirmationTime: TxConfirmationTime
    let receptionTime: TxReceptionTime
    let lockTime: TxLockTime
    let isDoubleSpent: Bool
    let confirmations: TxConfirmations
    let confidence: TxConfidence
    let inputs: [TxInput]
    let outputs: [TxOutput]

    init(blockHash: BlockHash = BlockHash(),
         blockHeight: BlockHeight = BlockHeight(),
         hash: TxHash = TxHash(),
         fees: TxFee = TxFee(),
         size: TxSize = TxSize(),
         confirmationTime: TxConfirmationTime = TxConfirmationTime(),
         receptionTime: TxReceptionTime = TxReceptionTime(),
         lockTime: TxLockTime = TxLockTime(),
         isDoubleSpent: Bool = false,
         confirmations: TxConfirmations = TxConfirmations(),
         confidence: TxConfidence = TxConfidence(),
         inputs: [TxInput] = [],
         outputs: [TxOutput] = []) {

        self.blockHash = blockHash
        self.blockHeight = blockHeight
        self.hash = hash
        self.fees = fees
        self.size = size
        self.confirmationTime = confirmationTime
        self.receptionTime = receptionTime
        self.lockTime = lockTime
        self.isDoubleSpent = isDoubleSpent
        self.confirmations = confirmations
        self.confidence = confidence
        self.inputs = inputs
        self.outputs = outputs
    }

}