import ReachabilitySwift

class InternetService {

    private static var reachability: Reachability?
    private static var reachable = false

    static func start() {
        reachability = try! Reachability.reachabilityForInternetConnection()

        reachability?.whenReachable = { reachability in
            reachable = true
        }

        reachability?.whenUnreachable = { reachability in
            reachable = false
        }

        try! reachability?.startNotifier()
    }

    static func hasConnection() -> Bool {
        return reachable
    }

}