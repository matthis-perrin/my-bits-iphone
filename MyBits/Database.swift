import Foundation
import SQLite

class DB {

    private static let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    private static var conn: Connection!
    static var useTestDB = false
    static var debug = true

    // Accounts table
    private static let accounts = Table("accounts")
    private static let accountId = Expression<Int64>("id")
    private static let accountName = Expression<String>("account_name")

    // Master Public Keys table
    private static let masterPublicKeys = Table("master_public_keys")
    private static let masterPublicKeyId = Expression<Int64>("id")
    private static let masterPublicKeyValue = Expression<String>("value")
    private static let masterPublicKeyAccountId = Expression<Int64?>("account_id")

    // Bitcoin Addresses table
    private static let bitcoinAddresses = Table("bitcoin_addresses")
    private static let bitcoinAddressId = Expression<Int64>("id")
    private static let bitcoinAddressValue = Expression<String>("value")
    private static let bitcoinAddressAccountId = Expression<Int64?>("account_id")
    private static let bitcoinAddressMasterPublicKeyId = Expression<Int64?>("master_public_key_id")

    static func empty() {
        let dbPath = DB.getDBPath()
        do {
            try NSFileManager().removeItemAtPath(dbPath)
        } catch {}
        log("Successful deletion of file \(dbPath)")
    }

    private static func getDBPath() -> String {
        let suffix = DB.useTestDB ? "-test" : ""
        return "\(DB.path)/db\(suffix).sqlite3"
    }

    static func initialize() {
        // Creating database connection
        let dbPath = DB.getDBPath()
        self.conn = try! Connection(dbPath)
        guard let db = self.conn else {
            return
        }
        log("Successful connection using file \(dbPath)")

        // SQL queries logs
//        db.trace { x in print(x + "\n") }

        do {
            // Creating accounts table
            try db.run(self.accounts.create(ifNotExists: true) { t in
                t.column(self.accountId, primaryKey: true)
                t.column(self.accountName)
                })

            // Creating master public keys table
            try db.run(self.masterPublicKeys.create(ifNotExists: true) { t in
                t.column(self.masterPublicKeyId, primaryKey: true)
                t.column(self.masterPublicKeyValue)
                t.column(self.masterPublicKeyAccountId)
                t.foreignKey(self.masterPublicKeyAccountId, references: self.accounts, self.accountId, delete: .Cascade)
                })

            // Creating bitcoin addresses table
            try db.run(self.bitcoinAddresses.create(ifNotExists: true) { t in
                t.column(self.bitcoinAddressId, primaryKey: true)
                t.column(self.bitcoinAddressValue)
                t.column(self.bitcoinAddressAccountId)
                t.column(self.bitcoinAddressMasterPublicKeyId)
                t.foreignKey(self.bitcoinAddressAccountId, references: self.accounts, self.accountId, delete: .Cascade)
                t.foreignKey(self.bitcoinAddressMasterPublicKeyId, references: self.masterPublicKeys, self.masterPublicKeyId, delete: .Cascade)
                })
            
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
        log("Found \(res.count) accounts")
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
        log("Found \(res.count) master public keys for account \(account.getName())")
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
        log("Found \(res.count) bitcoin addresses for account \(account.getName())")
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
        log("Found \(res.count) bitcoin addresses for master public key \(masterPublicKey.value)")
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
        log("Inserted account \(account.getName())")
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
        log("Inserted master public key \(masterPublicKey.value) for account \(account.getName())")
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
        log("Inserted bitcoin address \(bitcoinAddress.value) for account \(account.getName())")
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
        log("Inserted bitcoin address \(bitcoinAddress.value) for master public key \(masterPublicKey.value)")
    }

    private static func log(message: String) {
        if debug {
            NSLog("[Database] \(message)")
        }
    }

}