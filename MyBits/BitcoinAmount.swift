class BitcoinAmount {

    private let satoshi: Int
    private static let SatoshiInBitcoin: Double = 1e8


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