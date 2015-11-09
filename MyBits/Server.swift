import Foundation
import Alamofire

let API_VERSION = 1
let API_BASE_URL = "http://raccoonz.ninja/api/v\(API_VERSION)"

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

func _extractJson(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> (json: [String: AnyObject]?, error: NSError?) {
    if (error != nil) {
        return (nil, error)
    }
    if (data == nil) {
        return (nil, _getServerError(ServerError.NO_DATA_RECEIVED))
    }
    do {
        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
        if let error = json["error"] as! String? {
            return (nil, _getServerError(ServerError.REMOTE_ERROR, message: error))
        } else {
            return (json, nil)
        }
    } catch {
        let dataAsString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        return (nil, _getServerError(ServerError.JSON_SERIALIZATION_ERROR, message: "Received \(dataAsString)"))
    }
}

struct Server {

    static func registerUser(callback: (userId: String?, error: NSError?) -> Void) {
        let url = API_BASE_URL + "/user/register"
        Alamofire.request(.POST, url).response { request, response, data, error in
            let (json, error) = _extractJson(request, response: response, data: data, error: error)
            if (json != nil) {
                if let userId = json!["user_id"] as! String? {
                    callback(userId: userId, error: nil)
                } else {
                    let dataAsString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    callback(userId: nil, error: _getServerError(ServerError.UNEXPECTED_JSON, message: "Received \(dataAsString)"))
                }
            } else {
                callback(userId: nil, error: error)
            }
        }
    }
}