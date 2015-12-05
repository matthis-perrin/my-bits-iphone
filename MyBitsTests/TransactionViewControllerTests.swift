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

    func testWithoutChange() {

//        let e1 = "19CVKztLHbg6wBpFwGoRwCUmzYEBFocPUf"
//        let e2 = "1DuSSNT5Gr5CAkkA1sHcKTo1vyCfMX5iwm"
//        let e3 = "1KbbM46vCNPUVZeRMiQFkmwXQWtW9Hq5SF"

        let a1 = "15djifdURkQwpLcfshfZuF6SMcdAAMNTQt"
//        let a2 = "1K4GFCayY3VW8AjaY4HWrj2dcRBWW47vDA"
//        let a3 = "17YcSFaVXEjr1ZsSS95uhw25imqk1gX6XH"
//        let a4 = "1MvDpc1PPkXrgTyZfdX185L7H28vAnyorU"
//        let a5 = "1ACm6vMGNihmiBreLe9ZNF1ro3yo6Gi55A"

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

}
