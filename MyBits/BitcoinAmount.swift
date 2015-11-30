import Foundation


class BitcoinAmount: CustomStringConvertible, Equatable {

    private let satoshis: Int
    private static let SatoshisInBitcoin: Double = 1e8

    private static var satoshiNumberFormater: NSNumberFormatter {
        let formattedNumber = NSNumberFormatter()
        formattedNumber.numberStyle = .DecimalStyle
        formattedNumber.groupingSeparator = ","
        formattedNumber.decimalSeparator = "."
        return formattedNumber
    }


    // Constructors

    convenience init() {
        self.init(satoshis: 0)
    }

    init(satoshis: Int) {
        self.satoshis = satoshis
    }


    // Public methods

    func getBitcoinAmount() -> Double {
        return Double(self.satoshis) / BitcoinAmount.SatoshisInBitcoin
    }

    func getSatoshiAmount() -> Int {
        return self.satoshis
    }

    var description: String {
        if abs(self.getSatoshiAmount()) < 100000 {
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
    return BitcoinAmount(satoshis: left.satoshis + right.satoshis)
}

func -(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshis: left.satoshis - right.satoshis)
}

func *(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshis: left.satoshis * right.satoshis)
}

func /(left: BitcoinAmount, right: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshis: left.satoshis / right.satoshis)
}

prefix func - (amount: BitcoinAmount) -> BitcoinAmount {
    return BitcoinAmount(satoshis: -amount.satoshis)
}

func ==(left: BitcoinAmount, right: BitcoinAmount) -> Bool {
    return left.satoshis == right.satoshis
}

func ==(left: BitcoinAmount, right: Int) -> Bool {
    return left.satoshis == right
}

func ==(left: Int, right: BitcoinAmount) -> Bool {
    return left == right.satoshis
}

func >(left: BitcoinAmount, right: Int) -> Bool {
    return left.satoshis > right
}

func >(left: Int, right: BitcoinAmount) -> Bool {
    return left > right.satoshis
}

func <(left: BitcoinAmount, right: Int) -> Bool {
    return left.satoshis < right
}

func <(left: Int, right: BitcoinAmount) -> Bool {
    return left < right.satoshis
}