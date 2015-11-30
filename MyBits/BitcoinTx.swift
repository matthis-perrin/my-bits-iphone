import Foundation

class BitcoinTx: CustomStringConvertible, Equatable {

    let blockHash: BlockHash?
    let blockHeight: BlockHeight
    let hash: TxHash
    let fees: TxFee
    let size: TxSize
    let confirmationTime: TxConfirmationTime?
    let receptionTime: TxReceptionTime
    let lockTime: TxLockTime
    let isDoubleSpent: Bool
    let confirmations: TxConfirmations
    let inputs: [TxInput]
    let outputs: [TxOutput]

    var txInfo: BitcoinTxInfo!

    init(blockHash: BlockHash? = nil,
         blockHeight: BlockHeight = BlockHeight(),
         hash: TxHash = TxHash(),
         fees: TxFee = TxFee(),
         size: TxSize = TxSize(),
         confirmationTime: TxConfirmationTime? = nil,
         receptionTime: TxReceptionTime = TxReceptionTime(),
         lockTime: TxLockTime = TxLockTime(),
         isDoubleSpent: Bool = false,
         confirmations: TxConfirmations = TxConfirmations(),
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
        self.inputs = inputs
        self.outputs = outputs

        self.txInfo = BitcoinTxInfo.getForTx(self)
    }

    static func loadFromJson(json: NSDictionary) -> BitcoinTx {
        var blockHash: BlockHash? = nil
        if let blockHashString = json["block_hash"] {
            if blockHashString is String {
                blockHash = BlockHash(value: blockHashString as! String)
            }
        }

        var confirmationTime: TxConfirmationTime? = nil
        if let confirmationTimeString = json["confirmed"] {
            if confirmationTimeString is String {
                confirmationTime = TxConfirmationTime(value: confirmationTimeString as! String)
            }
        }
        return BitcoinTx(
            blockHash: blockHash,
            blockHeight: BlockHeight(value: json["block_height"] as! Int),
            hash: TxHash(value: json["hash"] as! String),
            fees: TxFee(satoshis: json["fees"] as! Int),
            size: TxSize(value: json["size"] as! Int),
            confirmationTime: confirmationTime,
            receptionTime: TxReceptionTime(value: json["received"] as! String),
            lockTime: TxLockTime(value: json["lock_time"] as! Int),
            isDoubleSpent: json["double_spend"] as! Bool,
            confirmations: TxConfirmations(value: json["confirmations"] as! Int),
            inputs: (json["inputs"] as! [NSDictionary]).map({ inputJson in
                return TxInput.loadFromJson(inputJson)
            }),
            outputs: (json["outputs"] as! [NSDictionary]).map({ outputJson in
                return TxOutput.loadFromJson(outputJson)
            }))
    }

    func getInvolvedAddresses() -> [BitcoinAddress] {
        var addresses = [BitcoinAddress]()
        for input in self.inputs {
            for address in input.sourceAddresses {
                addresses.append(address)
            }
        }
        for output in self.outputs {
            for address in output.destinationAddresses {
                addresses.append(address)
            }
        }
        return addresses
    }

    var isConfirmed: Bool {
        return self.confirmations.value > 0
    }

    var description: String {
        var strings = [String]()
        strings.append("Block Hash: \(self.blockHash?.description)")
        strings.append("Block Height: \(self.blockHeight.description)")
        strings.append("Hash: \(self.hash.description)")
        strings.append("Fees: \(self.fees.description)")
        strings.append("Size: \(self.size.description)")
        strings.append("Confirmation Time: \(self.confirmationTime?.description)")
        strings.append("Reception Time: \(self.receptionTime.description)")
        strings.append("Lock Time: \(self.lockTime.description)")
        strings.append("Double Spent: \(self.isDoubleSpent ? "true" : "false")")
        for (index, input) in self.inputs.enumerate() {
            strings.append("Input #\(index): ")
            strings.append("  " + input.description.stringByReplacingOccurrencesOfString("\n", withString: "\n  "))
        }
        for (index, output) in self.outputs.enumerate() {
            strings.append("Output #\(index): ")
            strings.append("  " + output.description.stringByReplacingOccurrencesOfString("\n", withString: "\n  "))
        }
        return strings.joinWithSeparator("\n")
    }

}

func ==(left: BitcoinTx, right: BitcoinTx) -> Bool {
    return (
        left.blockHash == right.blockHash &&
        left.blockHeight == right.blockHeight &&
        left.hash == right.hash &&
        left.fees == right.fees &&
        left.size == right.size &&
        left.confirmationTime == right.confirmationTime &&
        left.receptionTime == right.receptionTime &&
        left.lockTime == right.lockTime &&
        left.isDoubleSpent == right.isDoubleSpent &&
        left.confirmations == right.confirmations &&
        left.inputs == right.inputs &&
        left.outputs == right.outputs)
}