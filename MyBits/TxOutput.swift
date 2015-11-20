import Foundation

class TxOutput: CustomStringConvertible {

    let value: BitcoinAmount
    let script: BitcoinScript
    let scriptType: BitcoinScriptType
    let destinationAddresses: [BitcoinAddress]
    let spentBy: TxHash?

    init(value: BitcoinAmount = BitcoinAmount(),
         script: BitcoinScript = BitcoinScript(),
         scriptType: BitcoinScriptType = .Unknown,
         destinationAddresses: [BitcoinAddress] = [],
         spentBy: TxHash? = nil) {

        self.value = value
        self.script = script
        self.scriptType = scriptType
        self.destinationAddresses = destinationAddresses
        self.spentBy = spentBy
    }

    static func loadFromJson(json: NSDictionary) -> TxOutput {
        return TxOutput(
            value: BitcoinAmount(satoshis: json["value"] as! Int),
            script: BitcoinScript(value: json["script"] as! String),
            scriptType: BitcoinScriptType.fromString(json["script_type"] as! String),
            destinationAddresses: (json["addresses"] as! [String]).map() { value in
                return BitcoinAddress(value: value)
            },
            spentBy: (json["spent_by"] as! String?).map({ value in
                return TxHash(value: value)
            }))
    }

    var description: String {
        var strings = [
            "Value: " + self.value.description,
            "Script: " + self.script.description,
            "Script Type: " + self.scriptType.description,
            "Source Addresses: " + destinationAddresses.description
        ]
        if let spentBy = self.spentBy {
            strings.append("Spent By Tx: " + spentBy.description)
        }
        return strings.joinWithSeparator("\n")
    }

}