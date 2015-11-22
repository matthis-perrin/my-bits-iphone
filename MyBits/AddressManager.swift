import Foundation

class AddressManager {

    private static var addressPool = [BitcoinAddress]()

    static func rebuildAddressPool() {
        var all = [BitcoinAddress]()
        var new = [BitcoinAddress]() // Store the new addresses (compared to the last call to this function)
        var seen = [BitcoinAddress: Bool]() // Helps track duplicates
        for account in AccountStore.getAccounts() {
            for address in account.getAddresses() {
                let bitcoinAddress = address.getBitcoinAddress()
                if seen.updateValue(true, forKey: bitcoinAddress) == nil {
                    all.append(bitcoinAddress)
                    if (!AddressManager.addressPool.contains(bitcoinAddress)) {
                        new.append(bitcoinAddress)
                    }
                }
            }
            for xpub in account.getXpubs() {
                for bitcoinAddress in xpub.getAddresses() {
                    if seen.updateValue(true, forKey: bitcoinAddress) == nil {
                        all.append(bitcoinAddress)
                        if (!AddressManager.addressPool.contains(bitcoinAddress)) {
                            new.append(bitcoinAddress)
                        }
                    }
                }
            }
        }
        AddressManager.addressPool = all
        TransactionFetcher.fetchMulti(new)
    }

    static func getAddresses() -> [BitcoinAddress] {
        return AddressManager.addressPool
    }

}