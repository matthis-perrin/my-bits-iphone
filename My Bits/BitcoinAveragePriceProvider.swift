import Foundation

class BitcoinAveragePriceProvider: PriceProviderProtocol {

    func getPrice(currency: String, callback: (Double, NSDate) -> Void) {
        let url = NSURL(string: "https://api.bitcoinaverage.com/ticker/global/\(currency)/")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if (error != nil) {
                print("Error while downloading data:\n \(error)")
            } else {
                do {
                    // Try parsing some valid JSON
                    let parsed = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

                    // Bitcoin Average a use custom date format
                    let dateString = parsed["timestamp"] as! String
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "E, dd MMM YYYY HH:mm:ss Z"
                    let date = dateFormatter.dateFromString(dateString)!

                    let bid = parsed["bid"] as! Double
                    let ask = parsed["ask"] as! Double

                    callback((bid + ask) / 2, date)
                }
                catch let error as NSError {
                    print("Error while parsing data:\n \(error)")
                }
            }
        }

        task.resume()
    }

}