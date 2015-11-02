import Foundation

protocol PriceProviderProtocol {

    func getPrice(callback: (Double, NSDate) -> Void)

}
