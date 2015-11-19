import Foundation


class BitcoinAmount: CustomStringConvertible {

    private let satoshi: Int
    private static let SatoshiInBitcoin: Double = 1e8

    private static var satoshiNumberFormater: NSNumberFormatter {
        let formattedNumber = NSNumberFormatter()
        formattedNumber.numberStyle = .DecimalStyle
        formattedNumber.groupingSeparator = ","
        formattedNumber.decimalSeparator = "."
        return formattedNumber
    }


    // Constructors

    convenience init() {
        self.init(satoshi: 0)
    }

    init(satoshi: Int) {
        self.satoshi = satoshi
    }


    // Public methods

    func getBitcoinAmount() -> Double {
        return Double(self.satoshi) / BitcoinAmount.SatoshiInBitcoin
    }

    func getSatoshiAmount() -> Int {
        return self.satoshi
    }

    var description: String {
        if self.getSatoshiAmount() < 100000 {
            let satoshString = BitcoinAmount.satoshiNumberFormater.stringFromNumber(self.getSatoshiAmount())!
            return "BitcoinAmount(\(satoshString) Satoshis)"
        } else {
            let bitcoinString = NSString(format: "%.08f", self.getBitcoinAmount())
            return "BitcoinAmount(\(bitcoinString) BTC)"
        }
    }

}


// Operator overloading

func +(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshi: left.satoshi + right.satoshi)
}

func -(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshi: left.satoshi - right.satoshi)
}

func *(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshi: left.satoshi * right.satoshi)
}

func /(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshi: left.satoshi / right.satoshi)
}