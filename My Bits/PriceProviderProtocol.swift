import Foundation

protocol PriceProviderProtocol {

    func getPrice(currency: String, callback: (Double, NSDate) -> Void)

}
