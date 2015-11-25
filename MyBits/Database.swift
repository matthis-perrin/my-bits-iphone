import Foundation
import SQLite

class DB {

    private static let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    private static var conn: Connection!

    // Accounts table
    private static let accounts = Table("accounts")
    private static let accountId = Expression<Int>("id")
    private static let accountName = Expression<String>("account_name")

    // Master Public Keys table
    private static let masterPublicKeys = Table("master_public_keys")
    private static let masterPublicKeyId = Expression<Int>("id")
    private static let masterPublicKeyValue = Expression<String>("value")
    private static let masterPublicKeyAccountId = Expression<Int?>("account_id")

    // Bitcoin Addresses table
    private static let bitcoinAddresses = Table("bitcoin_addresses")
    private static let bitcoinAddressId = Expression<Int>("id")
    private static let bitcoinAddressValue = Expression<String>("value")
    private static let bitcoinAddressAccountId = Expression<Int?>("account_id")
    private static let bitcoinAddressMasterPublicKeyId = Expression<Int?>("master_public_key_id")

    static func initialize() {
        // Creating database connection
//        do { try NSFileManager().removeItemAtPath("\(self.path)/db.sqlite3") } catch {}
        self.conn = try! Connection("\(self.path)/db.sqlite3")
        guard let db = self.conn else {
            return
        }

        // SQL queries logs
//        db.trace { x in print(x + "\n") }

        do {
            // Creating accounts table
            try db.run(self.accounts.create(ifNotExists: true) { t in
                t.column(self.accountId, primaryKey: true)
                t.column(self.accountName)
                })
            try db.run(self.accounts.createIndex([self.accountId], unique: true, ifNotExists: true))

            // Creating master public keys table
            try db.run(self.masterPublicKeys.create(ifNotExists: true) { t in
                t.column(self.masterPublicKeyId, primaryKey: true)
                t.column(self.masterPublicKeyValue)
                t.column(self.masterPublicKeyAccountId, references: self.accounts, self.accountId)
                })
            try db.run(self.masterPublicKeys.createIndex([self.masterPublicKeyAccountId], unique: true, ifNotExists: true))

            // Creating bitcoin addresses table
            try db.run(self.bitcoinAddresses.create(ifNotExists: true) { t in
                t.column(self.bitcoinAddressId, primaryKey: true)
                t.column(self.bitcoinAddressValue)
                t.column(self.self.bitcoinAddressAccountId, references: self.accounts, self.accountId)
                t.column(self.self.bitcoinAddressMasterPublicKeyId, references: self.masterPublicKeys, self.masterPublicKeyId)
                })
            try db.run(self.bitcoinAddresses.createIndex([self.bitcoinAddressAccountId], unique: false, ifNotExists: true))
            try db.run(self.bitcoinAddresses.createIndex([self.bitcoinAddressMasterPublicKeyId], unique: false, ifNotExists: true))
            
            // Initialize stores
            try AccountStore.initialize()
        } catch let e {
            print("DATABASE INIT ERROR: \(e)")
        }
    }

    static func getAccounts() -> [Account] {
        guard let db = self.conn else {
            return []
        }
        var res = [Account]()
        for row in db.prepare(self.accounts) {
            res.append(Account(accountId: AccountId(value: row[self.accountId]), accountName: row[self.accountName]))
        }
        return res
    }

    static func getMasterPublicKeys(account: Account) -> [MasterPublicKey] {
        guard let db = self.conn else {
            return []
        }
        var res = [MasterPublicKey]()
        let rows = db.prepare(
            self.masterPublicKeys
                .select(self.masterPublicKeyId, self.masterPublicKeyValue)
                .filter(self.masterPublicKeyAccountId == account.getId().value)
        )
        for row in rows {
            res.append(MasterPublicKey(masterPublicKeyId: MasterPublicKeyId(value: row[self.masterPublicKeyId]), value: row[self.masterPublicKeyValue]))
        }
        return res
    }

    static func getBitcoinAddresses(account: Account) -> [BitcoinAddress] {
        guard let db = self.conn else {
            return []
        }
        var res = [BitcoinAddress]()
        let rows = db.prepare(
            self.bitcoinAddresses
                .select(self.bitcoinAddressId, self.bitcoinAddressValue)
                .filter(self.bitcoinAddressAccountId == account.getId().value)
        )
        for row in rows {
            res.append(BitcoinAddress(bitcoinAddressId: BitcoinAddressId(value: row[self.bitcoinAddressId]), value: row[self.bitcoinAddressValue]))
        }
        return res
    }

    static func getBitcoinAddresses(masterPublicKey: MasterPublicKey) -> [BitcoinAddress] {
        guard let db = self.conn else {
            return []
        }
        var res = [BitcoinAddress]()
        let rows = db.prepare(
            self.bitcoinAddresses
                .select(self.bitcoinAddressId, self.bitcoinAddressValue)
                .filter(self.bitcoinAddressMasterPublicKeyId == masterPublicKey.masterPublicKeyId.value)
        )
        for row in rows {
            res.append(BitcoinAddress(bitcoinAddressId: BitcoinAddressId(value: row[self.bitcoinAddressId]), value: row[self.bitcoinAddressValue]))
        }
        return res
    }

    static func insertAccount(account: Account) throws {
        guard let db = self.conn else {
            return
        }
        try db.run(self.accounts.insert(
            self.accountId <- account.getId().value,
            self.accountName <- account.getName()
            ))
    }

    static func insertMasterPublicKey(masterPublicKey: MasterPublicKey, account: Account) throws {
        guard let db = self.conn else {
            return
        }
        try db.run(self.masterPublicKeys.insert(
            self.masterPublicKeyId <- masterPublicKey.masterPublicKeyId.value,
            self.masterPublicKeyValue <- masterPublicKey.value,
            self.masterPublicKeyAccountId <- account.getId().value
            ))
    }

    static func insertBitcoinAddress(bitcoinAddress: BitcoinAddress, account: Account) throws {
        guard let db = self.conn else {
            return
        }
        try db.run(self.bitcoinAddresses.insert(
            self.bitcoinAddressId <- bitcoinAddress.bitcoinAddressId.value,
            self.bitcoinAddressValue <- bitcoinAddress.value,
            self.bitcoinAddressAccountId <- account.getId().value
            ))
    }

    static func insertBitcoinAddress(bitcoinAddress: BitcoinAddress, masterPublicKey: MasterPublicKey) throws {
        guard let db = self.conn else {
            return
        }
        try db.run(self.bitcoinAddresses.insert(
            self.bitcoinAddressId <- bitcoinAddress.bitcoinAddressId.value,
            self.bitcoinAddressValue <- bitcoinAddress.value,
            self.bitcoinAddressMasterPublicKeyId <- masterPublicKey.masterPublicKeyId.value
            ))
    }

}