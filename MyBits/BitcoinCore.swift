import Foundation

class BitcoinAddress {
    var value: String = ""
    init(value: String = "") {
        self.value = value
    }
}
class BlockHash {
    var value: String = ""
    init(value: String = "") {
        self.value = value
    }
}
class BlockHeight {
    var value: Int = 0
    init(value: Int = 0) {
        self.value = value
    }
}
class BitcoinScript {
    var value: String = ""
    init(value: String = "") {
        self.value = value
    }
}
class TxConfidence {
    var value: Int = 0
    init(value: Int = 0) {
        self.value = value
    }
}
class TxConfirmations {
    var value: Int = 0
    init(value: Int = 0) {
        self.value = value
    }
}
class TxConfirmationTime {
    var value: NSDate = NSDate()
    init(value: NSDate = NSDate()) {
        self.value = value
    }
}
class TxReceptionTime {
    var value: NSDate = NSDate()
    init(value: NSDate = NSDate()) {
        self.value = value
    }
}
class TxHash {
    var value: String = ""
    init(value: String = "") {
        self.value = value
    }
}
class TxSize {
    var value: Int = 0
    init(value: Int = 0) {
        self.value = value
    }
}
class TxLockTime {
    var value: Int = 0
    init(value: Int = 0) {
        self.value = value
    }
}
class TxFee: BitcoinAmount {}

enum BitcoinScriptType {
    case PayToPubKeyHash, Unknown

    func formString(string: String) -> BitcoinScriptType {
        if string == "pay-to-pubkey-hash" {
            return .PayToPubKeyHash
        } else {
            return .Unknown
        }
    }
}