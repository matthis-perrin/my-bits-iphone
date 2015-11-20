import UIKit

protocol PrivacyProtocol: class {

    func privacyDidChange()

}

class PrivacyStore {

    private static var delegates = [PrivacyProtocol]()
    private static var hideAmounts = true

    static func getPrivacy() -> Bool {
        return PrivacyStore.hideAmounts
    }

    static func setPrivacy(showAmounts: Bool) {
        PrivacyStore.hideAmounts = showAmounts
        PrivacyStore.delegates.forEach({ delegate in delegate.privacyDidChange() })
    }

    static func register(delegate: PrivacyProtocol) {
        PrivacyStore.delegates.append(delegate)
    }

    static func unregister(delegate: PrivacyProtocol) {
        PrivacyStore.delegates = PrivacyStore.delegates.filter({
            d in return d !== delegate
        })
    }

}