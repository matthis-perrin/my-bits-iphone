import Foundation

let MaxSizeForHashDescription = 30

class BitcoinAddress: CustomStringConvertible {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        return "BitcoinAddress(\(self.value))"
    }
}
class BlockHash: CustomStringConvertible {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        return "BlockHash(\(self.value.substringToIndex(self.value.startIndex.advancedBy(MaxSizeForHashDescription)) + suffix))"
    }
}
class BlockHeight: CustomStringConvertible {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
    var description: String {
        return "BlockHeight(\(self.value))"
    }
}
class BitcoinScript: CustomStringConvertible {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        return "BitcoinScript(\(self.value.substringToIndex(self.value.startIndex.advancedBy(MaxSizeForHashDescription)) + suffix))"
    }
}
class TxConfidence: CustomStringConvertible {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
    var description: String {
        return "TxConfidence(\(self.value))"
    }
}
class TxConfirmations: CustomStringConvertible {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
    var description: String {
        return "TxConfirmations(\(self.value))"
    }
}
class TxTime: CustomStringConvertible {
    var value: NSDate
    private static let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ]
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
    var description: String {
        return "TxTime(\(self.value))"
    }
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
class TxHash: CustomStringConvertible {
    var value: String
    init(value: String = "") {
        self.value = value
    }
    var description: String {
        let suffix = self.value.characters.count > MaxSizeForHashDescription ? "..." : ""
        return "TxHash(\(self.value.substringToIndex(self.value.startIndex.advancedBy(MaxSizeForHashDescription)) + suffix))"
    }
}
class TxSize: CustomStringConvertible {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
    var description: String {
        return "TxSize(\(self.value))"
    }
}
class TxLockTime: CustomStringConvertible {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
    var description: String {
        return "TxLockTime(\(self.value))"
    }
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