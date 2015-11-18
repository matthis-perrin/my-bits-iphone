class TxOutput {

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

}