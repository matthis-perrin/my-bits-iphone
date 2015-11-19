import Foundation

class TxInput: CustomStringConvertible {

    let previousTxHash: TxHash
    let linkedOutputIndex: Int
    let linkedOutputValue: BitcoinAmount
    let script: BitcoinScript
    let scriptType: BitcoinScriptType
    let sequence: Int
    let sourceAddresses: [BitcoinAddress]

    init(previousTxHash: TxHash = TxHash(),
         linkedOutputIndex: Int = 0,
         linkedOutputValue: BitcoinAmount = BitcoinAmount(),
         script: BitcoinScript = BitcoinScript(),
         scriptType: BitcoinScriptType = .Unknown,
         sequence: Int = 0,
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
            linkedOutputIndex: json["output_index"] as! Int,
            linkedOutputValue: BitcoinAmount(satoshi: json["output_value"] as! Int),
            script: BitcoinScript(value: json["script"] as! String),
            scriptType: BitcoinScriptType.fromString(json["script_type"] as! String),
            sequence: json["sequence"] as! Int,
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