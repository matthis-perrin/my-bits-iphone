import Foundation
import UIKit // For UIDevice

let API_VERSION = 1
let API_BASE_URL = "https://raccoonz.ninja/mybits/api/v\(API_VERSION)"

let SERVER_ERROR_DOMAIN = "ServerError"
struct ServerError {
    static var NO_DATA_RECEIVED = 0
    static var UNEXPECTED_JSON = 1
    static var JSON_SERIALIZATION_ERROR = 2
    static var REMOTE_ERROR = 3
}

func _getServerError(serverError: Int, _ message: String? = nil) -> NSError {
    var userInfo: [NSObject: AnyObject]? = nil
    if let message = message {
        userInfo = ["error": message]
    }
    return NSError(domain: SERVER_ERROR_DOMAIN, code: serverError, userInfo: userInfo)
}

func _postRequest(url: String, _ data: NSDictionary = NSDictionary(), _ callback: (NSDictionary?, NSError?) -> Void) {
    guard let url = NSURL(string: url) else {
        callback(nil, NSError(domain: SERVER_ERROR_DOMAIN, code: 0, userInfo: ["error": "Wrong URL format"]))
        return
    }
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: [])

    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        if let error = error {
            callback(nil, error)
            return
        }
        guard let data = data else {
            callback(nil, _getServerError(ServerError.NO_DATA_RECEIVED))
            return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
            if let error = json["error"] as? String {
                callback(nil, _getServerError(ServerError.REMOTE_ERROR, error))
            } else {
                callback(json, nil)
            }
        } catch {
            let dataAsString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            callback(nil, _getServerError(ServerError.JSON_SERIALIZATION_ERROR, "Received \(dataAsString)"))
        }
    }

    task.resume()
}

struct Server {

    static func generateAddresses(accountXpub: AccountXpub, start: Int, count: Int) {
        let url = API_BASE_URL + "/bitcoin/xpub?xpub=\(accountXpub.getMasterPublicKey().value)&start=\(start)&count=\(count)"
        let session = NSURLSession.sharedSession()

        if let url = NSURL(string: url) {
            let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                if let error = error {
                    NSLog("Error while generating addresses for an xpub: \(error.description).")
                    return
                } else if let data = data {
                    do {
                        let data = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers ) as! [String]
                        var addresses = [BitcoinAddress]()
                        for addressString in data {
                            addresses.append(BitcoinAddress(value: addressString))
                        }
                        try accountXpub.setAddresses(addresses, start: start)
                    } catch let error as NSError {
                        NSLog("Error while parsing addresses generated for an xpub: \(error.description). Received: \(String(data: data, encoding: NSUTF8StringEncoding)).")
                    }
                } else {
                    NSLog("No data or error received.")
                }
            }
            task.resume()
        } else {
            NSLog("Couldn't build url while generating addresses for an xpub: \(url)")
        }
    }

    static func registerUser(callback: (String?, NSError?) -> Void) {
        let url = API_BASE_URL + "/user/register"
        _postRequest(url) { json, error in
            if let json = json {
                if let userId = json["user_id"] as? NSNumber {
                    callback(userId.stringValue, nil)
                } else {
                    callback(nil, _getServerError(ServerError.UNEXPECTED_JSON, "Received \(json.description)"))
                }
            } else {
                callback(nil, error)
            }
        }
    }

    static func registerDevice(userId: String, _ callback: (String?, NSError?) -> Void) {
        let url = API_BASE_URL + "/user/\(userId)/device/register"
        // Device platform (device model)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let platform = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        // System version (iOS version)
        let systemVersion = UIDevice.currentDevice().systemVersion
        // App version (Version of this app)
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        // Push token (empty for now)
        let pushToken = ""

        // Perform the request
        let data = [
            "platform": platform,
            "system_version": systemVersion,
            "app_version": appVersion,
            "push_token": pushToken
        ]
        _postRequest(url, data) { json, error in
            if let json = json {
                if let deviceId = json["deviceId"] as? NSNumber {
                    callback(deviceId.stringValue, nil)
                } else {
                    callback(nil, _getServerError(ServerError.UNEXPECTED_JSON, "Received \(json.description)"))
                }
            } else {
                callback(nil, error)
            }
        }
    }

}