import KeychainAccess


let keychain = Keychain(service: "com.raccoonzninja.mybits")
let USER_ID_KEY = "user_id"

struct UserKeychain {

    static func getUserId() throws -> String? {
        return try keychain.get(USER_ID_KEY)
    }
    static func setUserId(userId: String) throws {
        try keychain.set(userId, key: USER_ID_KEY)
    }

}
