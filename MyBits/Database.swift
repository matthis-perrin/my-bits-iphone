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
    private static let accountName = Expression<String>("name")
    private static let accountCreatedAt = Expression<Int64>("created_at")

    // Master Public Keys table
    private static let masterPublicKeys = Table("master_public_keys")
    private static let masterPublicKeyId = Expression<Int64>("id")
    private static let masterPublicKeyValue = Expression<String>("value")
    private static let masterPublicKeyAccountId = Expression<Int64?>("account_id")
    private static let masterPublicKeyCreatedAt = Expression<Int64>("created_at")

    // Bitcoin Addresses table
    private static let bitcoinAddresses = Table("bitcoin_addresses")
    private static let bitcoinAddressId = Expression<Int64>("id")
    private static let bitcoinAddressValue = Expression<String>("value")
    private static let bitcoinAddressAccountId = Expression<Int64?>("account_id")
    private static let bitcoinAddressMasterPublicKeyId = Expression<Int64?>("master_public_key_id")
    private static let bitcoinAddressCreatedAt = Expression<Int64>("created_at")
    private static let bitcoinAddressUpdatedAt = Expression<Int64?>("updated_at")

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
        empty()
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
                t.column(self.accountCreatedAt)
                })

            // Creating master public keys table
            try db.run(self.masterPublicKeys.create(ifNotExists: true) { t in
                t.column(self.masterPublicKeyId, primaryKey: true)
                t.column(self.masterPublicKeyValue)
                t.column(self.masterPublicKeyAccountId)
                t.column(self.masterPublicKeyCreatedAt)
                t.foreignKey(self.masterPublicKeyAccountId, references: self.accounts, self.accountId, delete: .Cascade)
                })

            // Creating bitcoin addresses table
            try db.run(self.bitcoinAddresses.create(ifNotExists: true) { t in
                t.column(self.bitcoinAddressId, primaryKey: true)
                t.column(self.bitcoinAddressValue)
                t.column(self.bitcoinAddressAccountId)
                t.column(self.bitcoinAddressMasterPublicKeyId)
                t.column(self.bitcoinAddressCreatedAt)
                t.column(self.bitcoinAddressUpdatedAt)
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
        for row in db.prepare(self.accounts.order(self.accountCreatedAt.asc)) {
            res.append(Account(
                accountId: AccountId(value: row[self.accountId]),
                accountName: row[self.accountName],
                accountCreationTimestamp: row[self.accountCreatedAt]))
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
                .select(self.masterPublicKeyId, self.masterPublicKeyValue, self.masterPublicKeyCreatedAt)
                .filter(self.masterPublicKeyAccountId == account.getId().value)
        )
        for row in rows {
            res.append(MasterPublicKey(
                masterPublicKeyId: MasterPublicKeyId(value: row[self.masterPublicKeyId]),
                value: row[self.masterPublicKeyValue],
                creationTimestamp: row[self.masterPublicKeyCreatedAt]))
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
                .select(self.bitcoinAddressId, self.bitcoinAddressValue, self.bitcoinAddressCreatedAt, self.bitcoinAddressUpdatedAt)
                .filter(self.bitcoinAddressAccountId == account.getId().value)
        )
        for row in rows {
            res.append(BitcoinAddress(
                bitcoinAddressId: BitcoinAddressId(value: row[self.bitcoinAddressId]),
                value: row[self.bitcoinAddressValue],
                creationTimestamp: row[self.bitcoinAddressCreatedAt],
                updateTimestamp: row[self.bitcoinAddressUpdatedAt]))
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
                .select(self.bitcoinAddressId, self.bitcoinAddressValue, self.bitcoinAddressCreatedAt, self.bitcoinAddressUpdatedAt)
                .filter(self.bitcoinAddressMasterPublicKeyId == masterPublicKey.masterPublicKeyId.value)
        )
        for row in rows {
            res.append(BitcoinAddress(
                bitcoinAddressId: BitcoinAddressId(value: row[self.bitcoinAddressId]),
                value: row[self.bitcoinAddressValue],
                creationTimestamp: row[self.bitcoinAddressCreatedAt],
                updateTimestamp: row[self.bitcoinAddressUpdatedAt]))
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
            self.accountName <- account.getName(),
            self.accountCreatedAt <- account.getCreationTimestamp()
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
            self.masterPublicKeyAccountId <- account.getId().value,
            self.masterPublicKeyCreatedAt <- masterPublicKey.creationTimestamp
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
            self.bitcoinAddressAccountId <- account.getId().value,
            self.bitcoinAddressCreatedAt <- bitcoinAddress.creationTimestamp,
            self.bitcoinAddressUpdatedAt <- bitcoinAddress.updateTimestamp
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
            self.bitcoinAddressMasterPublicKeyId <- masterPublicKey.masterPublicKeyId.value,
            self.bitcoinAddressCreatedAt <- bitcoinAddress.creationTimestamp,
            self.bitcoinAddressUpdatedAt <- bitcoinAddress.updateTimestamp
            ))
        log("Inserted bitcoin address \(bitcoinAddress.value) for master public key \(masterPublicKey.value)")
    }

    static func bitcoinAddressUpdate(bitcoinAddress: BitcoinAddress) throws {
        guard let db = self.conn else {
            return
        }
        try db.run(self.bitcoinAddresses.filter(self.bitcoinAddressValue == bitcoinAddress.value).update(self.bitcoinAddressUpdatedAt <- bitcoinAddress.updateTimestamp))
        log("Updated bitcoin address \(bitcoinAddress.value) with update timestamp \(bitcoinAddress.updateTimestamp)")
    }

    private static func log(message: String) {
        if debug {
            NSLog("[Database] \(message)")
        }
    }

}