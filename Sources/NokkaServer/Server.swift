import Foundation
import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

public class Server {
    public let router: Router
    public var endpoints: [String: AppletInfo]
    public let authToken: String

    public init() {
        router = Router()
        endpoints = [String: AppletInfo]()
        authToken = randomBase64(len: 64)

        router.post("/applets/register", middleware: BasicAuthMiddleware(auth: authToken))
        router.post("/applets/register", middleware: RegistrationMiddleware(server: self))
        router.all("/*", middleware: ForwardingMiddleware(server: self))
    }
}

public class AppletInfo {
    let name: String
    let url: String
    let token: String

    init(name: String, url: String, token: String) {
        self.name = name
        self.url = url
        self.token = token
    }
}
