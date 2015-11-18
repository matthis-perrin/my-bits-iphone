import UIKit

protocol PrivacyProtocol: class {

    func privacyDidChange()

}

class PrivacyStore {

    private static var _delegates = [PrivacyProtocol]()
    private static var hideAmounts = true

    static func getPrivacy() -> Bool {
        return self.hideAmounts
    }

    static func getPrivacyColor() -> UIColor {
        return self.getPrivacy() ? UIColor.blackColor() : UIColor.redColor()
    }

    static func setPrivacy(showAmounts: Bool) {
        self.hideAmounts = showAmounts
        self._delegates.forEach({ delegate in delegate.privacyDidChange() })
    }

    static func register(delegate: PrivacyProtocol) {
        self._delegates.append(delegate)
    }

    static func unregister(delegate: PrivacyProtocol) {
        self._delegates = self._delegates.filter({
            d in return d !== delegate
        })
    }

}