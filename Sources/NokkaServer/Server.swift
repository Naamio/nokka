import Foundation
import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

public struct AppletInfo {
    /// Name of the applet
    public let name: String
    /// URL to which we should forward the traffic
    public let url: String
    /// Token assigned to the applet on registration.
    /// Only the registered applet can unregister itself.
    /// This token will be used for validating that.
    public let token: String
}

open class AppletServer {
    public let router = Router()
    public var endpoints = [String: AppletInfo]()
    public let authToken = randomBase64(len: 64)
    public let client = HttpClient()
    public let port: Int

    public init(port: Int) {
        self.port = port
        /// Routes that should be initialized before all routes
        router.post(NokkaRoutes.appletRegistration,
                    middleware: BasicAuthMiddleware(token: authToken))
        router.post(NokkaRoutes.appletRegistration,
                    middleware: RegistrationMiddleware(app: self))
    }

    public func initializeForwarding() {
        router.all("/*", middleware: ForwardingMiddleware(app: self))
    }

    public func createHTTPServer() {
        Kitura.addHTTPServer(onPort: port, with: router)
    }
}
