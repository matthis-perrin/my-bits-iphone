import Foundation

class TxInput: CustomStringConvertible, Equatable {

    let previousTxHash: TxHash
    let linkedOutputIndex: Int64
    let linkedOutputValue: BitcoinAmount
    let script: BitcoinScript
    let scriptType: BitcoinScriptType
    let sequence: Int64
    let sourceAddresses: [BitcoinAddress]

    init(previousTxHash: TxHash = TxHash(),
         linkedOutputIndex: Int64 = 0,
         linkedOutputValue: BitcoinAmount = BitcoinAmount(),
         script: BitcoinScript = BitcoinScript(),
         scriptType: BitcoinScriptType = .Unknown,
         sequence: Int64 = 0,
         sourceAddresses: [BitcoinAddress] = []) {

        self.previousTxHash = previousTxHash
        self.linkedOutputIndex = linkedOutputIndex
        self.linkedOutputValue = linkedOutputValue
        self.script = script
        self.scriptType = scriptType
        self.sequence = sequence
        self.sourceAddresses = sourceAddresses
    }

    static func loadFromJson(json: NSDictionary) -> TxInput {
        return TxInput(
            previousTxHash: TxHash(value: json["prev_hash"] as! String),
            linkedOutputIndex: (json["output_index"] as! NSNumber).longLongValue,
            linkedOutputValue: BitcoinAmount(satoshis: (json["output_value"] as! NSNumber).longLongValue),
            script: BitcoinScript(value: json["script"] as! String),
            scriptType: BitcoinScriptType.fromString(json["script_type"] as! String),
            sequence: (json["sequence"] as! NSNumber).longLongValue,
            sourceAddresses: (json["addresses"] as! [String]).map({ value in
                return BitcoinAddress(value: value)
            }))
    }

    var description: String {
        return [
            "Previous Tx Hash: " + self.previousTxHash.description,
            "Linked Output Index: " + self.linkedOutputIndex.description,
            "Linked Output Value: " + self.linkedOutputValue.description,
            "Script: " + self.script.description,
            "Script Type: " + self.scriptType.description,
            "Sequence: " + self.sequence.description,
            "Source Addresses: " + sourceAddresses.description
        ].joinWithSeparator("\n")
    }

}

func ==(left: TxInput, right: TxInput) -> Bool {
    return (
        left.previousTxHash == right.previousTxHash &&
        left.linkedOutputIndex == right.linkedOutputIndex &&
        left.linkedOutputValue == right.linkedOutputValue &&
        left.script == right.script &&
        left.scriptType == right.scriptType &&
        left.sequence == right.sequence &&
        left.sourceAddresses == right.sourceAddresses)
}