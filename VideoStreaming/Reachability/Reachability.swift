import Foundation
import SystemConfiguration
import UIKit

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

    var checkReachability: Bool {
        if Reachability.isConnectedToNetwork() {
            return true
        }
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return false }
        let alertController = UIAlertController(title: "No Network", message: "Please check your internet connection", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController.present(alertController, animated: true, completion: nil)
        return false
    }
}
