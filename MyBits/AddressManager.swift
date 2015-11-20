import Foundation

class AddressManager {

    private static var addressPool = [BitcoinAddress]()

    static func rebuildAddressPool() {
        var all = [BitcoinAddress]()
        var seen = [BitcoinAddress: Bool]()
        for account in AccountStore.getAccounts() {
            for address in account.getAddresses() {
                let bitcoinAddress = address.getBitcoinAddress()
                if seen.updateValue(true, forKey: bitcoinAddress) == nil {
                    all.append(bitcoinAddress)
                }
            }
        }
        AddressManager.addressPool = all
        print("Rebuilt address pool:")
        for address in self.getAddresses() {
            print("  \(address.value)")
        }
    }

    static func getAddresses() -> [BitcoinAddress] {
        return AddressManager.addressPool
    }

}