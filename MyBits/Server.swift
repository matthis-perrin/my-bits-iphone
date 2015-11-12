import Foundation
import UIKit // For UIDevice

let API_VERSION = 1
let API_BASE_URL = "https://raccoonz.ninja/api/v\(API_VERSION)"

let SERVER_ERROR_DOMAIN = "ServerError"
struct ServerError {
    static var NO_DATA_RECEIVED = 0
    static var UNEXPECTED_JSON = 1
    static var JSON_SERIALIZATION_ERROR = 2
    static var REMOTE_ERROR = 3
}

func _getServerError(serverError: Int, message: String? = nil) -> NSError {
    let userInfo: [NSObject: AnyObject]? = message == nil ? nil : ["error": message!]
    return NSError(domain: SERVER_ERROR_DOMAIN, code: serverError, userInfo: userInfo)
}

func _postRequest(url: String, data: NSDictionary, callback: (json: NSDictionary?, error: NSError?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: [])

    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) {(data, response, error) in
        if (error != nil) {
            callback(json: nil, error: error)
            return
        }
        if (data == nil) {
            callback(json: nil, error: _getServerError(ServerError.NO_DATA_RECEIVED))
            return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
            if let error = json["error"] as! String? {
                callback(json: nil, error: _getServerError(ServerError.REMOTE_ERROR, message: error))
            } else {
                callback(json: json, error: nil)
            }
        } catch {
            let dataAsString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            callback(json: nil, error: _getServerError(ServerError.JSON_SERIALIZATION_ERROR, message: "Received \(dataAsString)"))
        }
    }

    task.resume()
}

struct Server {

    static func registerUser(callback: (userId: String?, error: NSError?) -> Void) {
        let url = API_BASE_URL + "/user/register"
        _postRequest(url, data: NSDictionary(), callback: { json, error in
            if (json != nil) {
                if let userId = json!["user_id"] as! String? {
                    NSLog(json!.description)
                    callback(userId: userId, error: nil)
                } else {
                    callback(userId: nil, error: _getServerError(ServerError.UNEXPECTED_JSON, message: "Received \(json!.description)"))
                }
            } else {
                callback(userId: nil, error: error)
            }
        })
    }

    static func registerDevice(userId: String, callback: (deviceId: String?, error: NSError?) -> Void) {
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
        _postRequest(url, data: data, callback: { json, error in
            if (json != nil) {
                if let deviceId = json!["deviceId"] as! String? {
                    NSLog(json!.description)
                    callback(deviceId: deviceId, error: nil)
                } else {
                    callback(deviceId: nil, error: _getServerError(ServerError.UNEXPECTED_JSON, message: "Received \(json!.description)"))
                }
            } else {
                callback(deviceId: nil, error: error)
            }
        })
    }

}