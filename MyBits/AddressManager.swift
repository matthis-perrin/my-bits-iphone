import Foundation

class AddressManager {

    private static var addressPool = [BitcoinAddress]()

    static func rebuildAddressPool() {
        var all = [BitcoinAddress]()
        var seen = [BitcoinAddress: Bool]() // Helps track duplicates
        for account in AccountStore.getAccounts() {
            for address in account.getAddresses() {
                let bitcoinAddress = address.getBitcoinAddress()
                if seen.updateValue(true, forKey: bitcoinAddress) == nil {
                    all.append(bitcoinAddress)
                }
            }
            for xpub in account.getXpubs() {
                for bitcoinAddress in xpub.getAddresses() {
                    if seen.updateValue(true, forKey: bitcoinAddress) == nil {
                        all.append(bitcoinAddress)
                    }
                }
            }
            TransactionFetcher.queueAddressesForAccount(account)
        }
        AddressManager.addressPool = all
    }

    static func getAddresses() -> [BitcoinAddress] {
        return AddressManager.addressPool
    }

}