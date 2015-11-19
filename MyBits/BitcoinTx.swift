import Foundation

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

    static func loadFromJson(json: NSDictionary) -> BitcoinTx {
        print(json)
        return BitcoinTx(
            blockHash: BlockHash(value: json["block_hash"] as! String),
            blockHeight: BlockHeight(value: json["block_height"] as! Int),
            hash: TxHash(value: json["hash"] as! String),
            fees: TxFee(satoshi: json["fees"] as! Int),
            size: TxSize(value: json["size"] as! Int),
            confirmationTime: TxConfirmationTime(value: json["confirmed"] as! String),
            receptionTime: TxReceptionTime(value: json["received"] as! String),
            lockTime: TxLockTime(value: json["lock_time"] as! Int),
            isDoubleSpent: json["double_spend"] as! Bool,
            confidence: TxConfidence(value: json["confidence"] as! Int),
            inputs: (json["inputs"] as! [NSDictionary]).map({ inputJson in
                return TxInput.loadFromJson(inputJson)
            }),
            outputs: (json["outputs"] as! [NSDictionary]).map({ outputJson in
                return TxOutput.loadFromJson(outputJson)
            }))
    }

}