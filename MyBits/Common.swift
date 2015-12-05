import Foundation

class GenericId: Hashable {
    var value: Int64
    init(value: Int64) {
        self.value = value
    }
    convenience init() {
        self.init(value: Int64(arc4random()))
    }
    var hashValue: Int {
        get {
            return value.hashValue
        }
    }
}
func ==(left: GenericId, right: GenericId) -> Bool {
    return left.value == right.value
}