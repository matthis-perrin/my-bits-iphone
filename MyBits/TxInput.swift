class TxInput {

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

}