import Foundation

class GenericId: Hashable {
    var value: Int
    init(value: Int) {
        self.value = value
    }
    convenience init() {
        self.init(value: Int(arc4random()))
    }
    var hashValue: Int {
        get {
            return value
        }
    }
}
func ==(left: GenericId, right: GenericId) -> Bool {
    return left.value == right.value
}