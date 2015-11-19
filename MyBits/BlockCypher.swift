import Foundation

struct BlockCypher {

    static func loadTransactions(forAddress: BitcoinAddress) {
        let url = NSURL(string: "https://api.blockcypher.com/v1/btc/main/addrs/\(forAddress.value)/full")
        let session = NSURLSession.sharedSession()

        if let url = url {
            let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
                if let error = error {
                    NSLog("Error while loading transaction for address \(forAddress.value): \(error.description).")
                    return
                } else if let data = data {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        let txsJson = jsonData["txs"] as! [NSDictionary]
                        for txJson in txsJson {
                            let _ = BitcoinTx.loadFromJson(txJson)
                        }
                    } catch let error as NSError {
                        NSLog("Error while parsing transactions for address \(forAddress.value): \(error.description). Received: \(data).")
                    }
                } else {
                    NSLog("Not data or error received.")
                }
            }
            task.resume()
        } else {
            NSLog("Couldn't build url for address \(forAddress.value).")
        }
    }

}