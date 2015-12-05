import Foundation

let MaxSizeForHashDescription = 30

class BitcoinAddressId: GenericId {}

class BitcoinAddress: CustomStringConvertible, Hashable {
    var bitcoinAddressId: BitcoinAddressId
    var value: String

    init(bitcoinAddressId: BitcoinAddressId, value: String) {
        self.bitcoinAddressId = bitcoinAddressId
        self.value = value
    }

    convenience init(value: String) {
        self.init(bitcoinAddressId: BitcoinAddressId(), value: value)
    }

    func getBalance() -> BitcoinAmount {
        var balance = BitcoinAmount(satoshis: 0)
        // Loop through each transactions and compute the balance
        for tx in TransactionStore.getTransactions() {
            for input in tx.inputs {
                if input.sourceAddresses.contains(self) {
                    balance = balance - input.linkedOutputValue
                }
            }
            for output in tx.outputs {
                if output.destinationAddresses.contains(self) {
                    balance = balance + output.value
                }
            }
        }
        return balance
    }

    var smallDescription: String {
        return self.value.substringToIndex(self.value.startIndex.advancedBy(5)) +
               "..." +
               self.value.substringFromIndex(self.value.endIndex.advancedBy(-4))
    }

    var description: String {
        return "BitcoinAddress(\(self.value))"
    }
    var hashValue: Int {
        get {
            return value.hashValue
        }
    }
    func copy() -> BitcoinAddress {
        return BitcoinAddress(bitcoinAddressId: self.bitcoinAddressId, value: self.value)
    }
}
func ==(left: BitcoinAddress, right: BitcoinAddress) -> Bool {
    return left.value == right.value
}

class MasterPublicKeyId: GenericId {}

class MasterPublicKey: CustomStringConvertible, Hashable {
    var masterPublicKeyId: MasterPublicKeyId
    var value: String

    init(masterPublicKeyId: MasterPublicKeyId, value: String) {
        self.masterPublicKeyId = masterPublicKeyId
        self.value = value
    }

    convenience init(value: String) {
        self.init(masterPublicKeyId: MasterPublicKeyId(), value: value)
    }

    var description: String {
        return "MasterPublicKey(\(self.value))"
    }
    var hashValue: Int {
        get {
            return value.hashValue
        }
    }
}
func ==(left: MasterPublicKey, right: MasterPublicKey) -> Bool {
    return left.value == right.value
}

class BlockHash: CustomStringConvertible, Equatable {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        let end = min(MaxSizeForHashDescription, self.value.characters.count)
        return "BlockHash(\(self.value.substringToIndex(self.value.startIndex.advancedBy(end)) + suffix))"
    }
}
func ==(left: BlockHash, right: BlockHash) -> Bool {
    return left.value == right.value
}

class BlockHeight: CustomStringConvertible, Equatable {
    var value: Int64
    init(value: Int64 = 0) {
        self.value = value
    }
    var description: String {
        return "BlockHeight(\(self.value))"
    }
}
func ==(left: BlockHeight, right: BlockHeight) -> Bool {
    return left.value == right.value
}

class BitcoinScript: CustomStringConvertible, Equatable {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        let end = min(MaxSizeForHashDescription, self.value.characters.count)
        return "BitcoinScript(\(self.value.substringToIndex(self.value.startIndex.advancedBy(end)) + suffix))"
    }
}
func ==(left: BitcoinScript, right: BitcoinScript) -> Bool {
    return left.value == right.value
}

class TxConfirmations: CustomStringConvertible, Equatable {
    var value: Int64
    init(value: Int64 = 0) {
        self.value = value
    }
    var description: String {
        return "TxConfirmations(\(self.value))"
    }
}
func ==(left: TxConfirmations, right: TxConfirmations) -> Bool {
    return left.value == right.value
}

class TxTime: CustomStringConvertible, Equatable {
    var value: NSDate
    private static let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ]
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter
    }()
    init() {
        self.value = NSDate()
    }
    init(value: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        var date: NSDate? = nil
        for dateFormat in TxTime.dateFormats {
            dateFormatter.dateFormat = dateFormat
            if let dateValue = dateFormatter.dateFromString(value) {
                date = dateValue
                break
            }
        }
        if let date = date {
            self.value = date
        } else {
            self.value = NSDate()
            NSLog("Received invalid date \(value)")
        }
    }
    var userFriendlyDescription: String {
        return TxTime.dateFormatter.stringFromDate(self.value)
    }
    var description: String {
        return "TxTime(\(self.value))"
    }
}
func ==(left: TxTime, right: TxTime) -> Bool {
    return left.value.compare(right.value) == NSComparisonResult.OrderedSame
}

class TxConfirmationTime: TxTime {
    override var description: String {
        return super.description.stringByReplacingOccurrencesOfString("TxTime", withString: "TxConfirmationTime")
    }
}

class TxReceptionTime: TxTime {
    override var description: String {
        return super.description.stringByReplacingOccurrencesOfString("TxTime", withString: "TxReceptionTime")
    }
}

class TxHash: CustomStringConvertible, Hashable {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        let end = min(MaxSizeForHashDescription, self.value.characters.count)
        return "TxHash(\(self.value.substringToIndex(self.value.startIndex.advancedBy(end)) + suffix))"
    }
    var hashValue: Int {
        get {
            return value.hashValue
        }
    }
}
func ==(left: TxHash, right: TxHash) -> Bool {
    return left.value == right.value
}

class TxSize: CustomStringConvertible, Equatable {
    var value: Int64
    init(value: Int64 = 0) {
        self.value = value
    }
    var description: String {
        return "TxSize(\(self.value))"
    }
}
func ==(left: TxSize, right: TxSize) -> Bool {
    return left.value == right.value
}

class TxLockTime: CustomStringConvertible, Equatable {
    var value: Int64
    init(value: Int64 = 0) {
        self.value = value
    }
    var description: String {
        return "TxLockTime(\(self.value))"
    }
}
func ==(left: TxLockTime, right: TxLockTime) -> Bool {
    return left.value == right.value
}

class TxFee: BitcoinAmount {
    override var description: String {
        return super.description.stringByReplacingOccurrencesOfString("BitcoinAmount", withString: "TxFee")
    }
}

enum BitcoinScriptType: String, CustomStringConvertible {
    case PayToPubKeyHash, PayToScriptHash, Unknown

    var description: String {
        return "BitcoinScriptType.\(self.rawValue)"
    }

    static func fromString(string: String) -> BitcoinScriptType {
        if string == "pay-to-pubkey-hash" {
            return .PayToPubKeyHash
        } else if string == "pay-to-script-hash" {
            return .PayToScriptHash
        } else {
            return .Unknown
        }
    }
}