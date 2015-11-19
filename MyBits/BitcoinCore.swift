import Foundation

class BitcoinAddress {
    var value: String
    init(value: String = "") {
        self.value = value
    }
}
class BlockHash {
    var value: String
    init(value: String = "") {
        self.value = value
    }
}
class BlockHeight {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
}
class BitcoinScript {
    var value: String
    init(value: String = "") {
        self.value = value
    }
}
class TxConfidence {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
}
class TxConfirmations {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
}
class TxTime {
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
}
class TxConfirmationTime: TxTime {}
class TxReceptionTime: TxTime {}
class TxHash {
    var value: String
    init(value: String = "") {
        self.value = value
    }
}
class TxSize {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
}
class TxLockTime {
    var value: Int
    init(value: Int = 0) {
        self.value = value
    }
}
class TxFee: BitcoinAmount {}

enum BitcoinScriptType {
    case PayToPubKeyHash, PayToScriptHash, Unknown

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