import XCTest
@testable import MyBits

class MyBitsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DB.useTestDB = true
        DB.empty()
        DB.initialize()
    }

    override func tearDown() {
        DB.empty()
        super.tearDown()
    }

    private func getAccount(name: String) -> Account {
        return Account(accountName: name)
    }

    private func getAccountAddress(address: String) -> AccountAddress {
        return AccountAddress(bitcoinAddress: BitcoinAddress(value: address))
    }

    private func getTx(inputs: [String: Int], _ outputs: [String: Int]) -> BitcoinTx {
        return BitcoinTx(
            inputs: inputs.map() { return TxInput(
                linkedOutputValue: BitcoinAmount(satoshis: Int64($0.1)),
                sourceAddresses: [BitcoinAddress(value: $0.0)])
            },
            outputs: outputs.map() { return TxOutput(
                value: BitcoinAmount(satoshis: Int64($0.1)),
                destinationAddresses: [BitcoinAddress(value: $0.0)])
            }
        )
    }

    private func XCTAssertSubtitle(first: (prefix: String, amount: BitcoinAmount?, suffix: String?), _ second:(prefix: String, amount: BitcoinAmount?, suffix: String?)) -> Void {
        XCTAssertEqual(first.prefix, second.prefix)
        XCTAssertEqual(first.amount, second.amount)
        XCTAssertEqual(first.suffix, second.suffix)
    }

    private func getSubtitle(prefix: String, _ amount: BitcoinAmount?, _ suffix: String?) -> (prefix: String, amount: BitcoinAmount?, suffix: String?) {
        return (prefix: prefix, amount: amount, suffix: suffix)
    }

    func testWithoutChange() {
        let a1 = "15djifdURkQwpLcfshfZuF6SMcdAAMNTQt"
        let account1 = getAccount("Account #1")
        try! AccountStore.addAccount(account1)
        try! AccountStore.addAddress(account1, accountAddress: getAccountAddress(a1))

        let t1 = getTx([a1: 100], [a1: 100])
        let t1Info = t1.txInfo
        let t1InfoWC = t1Info.withoutChange()
        XCTAssertTrue(t1Info.inputTxIO.count == 1)
        XCTAssertTrue(t1Info.outputTxIO.count == 1)
        XCTAssertTrue(t1Info.involvedAccounts.count == 1)
        XCTAssertTrue(t1InfoWC.inputTxIO.count == 0)
        XCTAssertTrue(t1InfoWC.outputTxIO.count == 0)
        XCTAssertTrue(t1InfoWC.involvedAccounts.count == 0)
    }

    func testTransactions() {

        let e1 = "19CVKztLHbg6wBpFwGoRwCUmzYEBFocPUf"
        let e2 = "1DuSSNT5Gr5CAkkA1sHcKTo1vyCfMX5iwm"
        //        let e3 = "1KbbM46vCNPUVZeRMiQFkmwXQWtW9Hq5SF"

        let a1_1 = "15djifdURkQwpLcfshfZuF6SMcdAAMNTQt"
        let a1_2 = "1K4GFCayY3VW8AjaY4HWrj2dcRBWW47vDA"
        //        let a3 = "17YcSFaVXEjr1ZsSS95uhw25imqk1gX6XH"
        //        let a4 = "1MvDpc1PPkXrgTyZfdX185L7H28vAnyorU"
        //        let a5 = "1ACm6vMGNihmiBreLe9ZNF1ro3yo6Gi55A"

        let account1 = getAccount("Account #1")
        try! AccountStore.addAccount(account1)
        try! AccountStore.addAddress(account1, accountAddress: getAccountAddress(a1_1))
        try! AccountStore.addAddress(account1, accountAddress: getAccountAddress(a1_2))

        let t1 = getTx([a1_1: 100], [a1_1: 100])
        let t1Info = t1.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t1Info).getSatoshiAmount(), 0)
        XCTAssertEqual(TransactionViewController.getTitle(t1Info), "Empty transaction")
        let subtitles1 = TransactionViewController.getSubtitles(t1Info)
        XCTAssert(subtitles1.isEmpty)

        let t2 = getTx([a1_1: 100], [e1: 100])
        let t2Info = t2.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t2Info).getSatoshiAmount(), -100)
        XCTAssertEqual(TransactionViewController.getTitle(t2Info), "Bitcoin sent")
        let subtitles2 = TransactionViewController.getSubtitles(t2Info)
        XCTAssertSubtitle(subtitles2[0], ("From Account #1 to \(e1)", nil, nil))

        let t3 = getTx([a1_1: 100], [a1_1: 30, e1:70])
        let t3Info = t3.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t3Info).getSatoshiAmount(), -70)
        XCTAssertEqual(TransactionViewController.getTitle(t3Info), "Bitcoin sent")
        let subtitles3 = TransactionViewController.getSubtitles(t3Info)
        XCTAssertSubtitle(subtitles3[0], ("From Account #1 to \(e1)", nil, nil))

        let t4 = getTx([e1: 100], [a1_1: 100])
        let t4Info = t4.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t4Info).getSatoshiAmount(), 100)
        XCTAssertEqual(TransactionViewController.getTitle(t4Info), "Bitcoin received")
        let subtitles4 = TransactionViewController.getSubtitles(t4Info)
        XCTAssertSubtitle(subtitles4[0], ("In Account #1 from \(e1)", nil, nil))

        let t5 = getTx([e1: 100], [a1_1: 70, e1: 70])
        let t5Info = t5.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t5Info).getSatoshiAmount(), 70)
        XCTAssertEqual(TransactionViewController.getTitle(t5Info), "Bitcoin received")
        let subtitles5 = TransactionViewController.getSubtitles(t5Info)
        XCTAssertSubtitle(subtitles5[0], ("In Account #1 from \(e1)", nil, nil))

        let t6 = getTx([e1: 100], [a1_1: 70, e2: 30])
        let t6Info = t6.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t6Info).getSatoshiAmount(), 70)
        XCTAssertEqual(TransactionViewController.getTitle(t6Info), "Bitcoin received")
        let subtitles6 = TransactionViewController.getSubtitles(t6Info)
        XCTAssertSubtitle(subtitles6[0], ("In Account #1 from \(e1)", nil, nil))

        let t7 = getTx([a1_1: 100], [a1_2: 100])
        let t7Info = t7.txInfo.withoutChange()
        XCTAssertEqual(TransactionViewController.getAmount(t7Info).getSatoshiAmount(), 0)
        XCTAssertEqual(TransactionViewController.getTitle(t7Info), "In-account transfer")
        let subtitles7 = TransactionViewController.getSubtitles(t7Info)
        XCTAssertSubtitle(subtitles7[0], ("", BitcoinAmount(satoshis: 100), " from Account #1 to Account #1"))

    }

}
