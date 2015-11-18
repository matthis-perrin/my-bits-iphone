import Foundation

class BitcoinAddress     { var value: String = ""       }
class BlockHash          { var value: String = ""       }
class BlockHeight        { var value: Int = 0           }
class BitcoinScript      { var value: String = ""       }
class TxConfidence       { var value: Int = 0           }
class TxConfirmations    { var value: Int = 0           }
class TxConfirmationTime { var value: NSDate = NSDate() }
class TxReceptionTime    { var value: NSDate = NSDate() }
class TxHash             { var value: String = ""       }
class TxSize             { var value: Int = 0           }
class TxLockTime         { var value: int = 0           }
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