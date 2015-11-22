import Foundation
import SQLite

class DB {

    private static let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    private static var conn: Connection?

    // Account table
    private static let accounts = Table("accounts")
    private static let accountId = Expression<Int>("accountId")
    private static let accountName = Expression<String>("accountName")

    static func initialize() throws {
        // Creating database connection
        conn = try Connection("\(path)/db.sqlite3")
        guard let db = conn else {
            return
        }

        // SQL queries logs
        db.trace { x in print(x) }

        // Creating account table
        try db.run(accounts.create(ifNotExists: true) { t in
            t.column(accountId, primaryKey: true)
            t.column(accountName)
        })
        try db.run(accounts.createIndex([accountId], unique: true, ifNotExists: true))
    }

    static func getAccounts() -> [Account] {
        guard let db = conn else {
            return []
        }
        var res = [Account]()
        for row in db.prepare(accounts) {
            res.append(Account(accountId: AccountId(value: row[accountId]), accountName: row[accountName]))
        }
        return res
    }

    static func insertAccount(account: Account) -> Bool {
        guard let db = conn else {
            return false
        }
        do {
            try db.run(accounts.insert(
                accountId <- account.getId().value,
                accountName <- account.getName()
            ))
        } catch {
            return false
        }
        return true
    }

}