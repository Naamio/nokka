import Foundation
import Kitura
import LoggerAPI
import SwiftyRequest

public class NaamioPlugin {
    let router: Router
    var endpoints: [String: PluginInfo]
    let authToken: String

    class PluginInfo {
        let name: String
        let url: String
        let token: String

        init(name: String, url: String, token: String) {
            self.name = name
            self.url = url
            self.token = token
        }
    }

    class BasicAuthMiddleware: RouterMiddleware {
        let auth: String
        init(auth: String) {
            self.auth = auth
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            let header = request.headers["Authorization"] ?? "       "
            let idx = header.index(header.startIndex, offsetBy: 7)
            if auth != header[idx...] {
                Log.info("Authorization failed")
                response.error = NSError(domain: "AuthFailure", code: 1, userInfo: [:])
            }

            next()
        }
    }

    class PluginRegistrationMiddleware: RouterMiddleware {
        let plugin: NaamioPlugin
        init(plugin: NaamioPlugin) {
            self.plugin = plugin
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            do {
                let data = try request.read(as: RegistrationData.self)
                if let _ = self.plugin.endpoints[data.relUrl] {
                    Log.error("Another plugin has already registered!")
                } else {
                    let token = randomBase64(len: 64)
                    let p = PluginInfo(name: data.name, url: data.endpoint, token: token)
                    self.plugin.endpoints[data.relUrl] = p
                    Log.info("Successfully registered \(p.name) for \(p.url)!")
                }
            } catch let err {
                Log.error("Cannot obtain JSON object from request: \(err)")
            }

            next()
        }
    }

    class ForwardingMiddleware: RouterMiddleware {
        let plugin: NaamioPlugin
        init(plugin: NaamioPlugin) {
            self.plugin = plugin
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            if let plugin = self.plugin.endpoints[request.urlURL.absoluteString] {
                Log.info("Found plugin: \(plugin)")
                // TODO: Proxy endpoint
            } else {
                Log.error("Nothing to forward to!")
            }

            next()
        }
    }

    init() {
        router = Router()
        endpoints = [String: PluginInfo]()
        authToken = randomBase64(len: 64)

        router.post("/plugins/register", middleware: BasicAuthMiddleware(auth: authToken))
        router.post("/plugins/register", middleware: PluginRegistrationMiddleware(plugin: self))
        router.all("/*", middleware: ForwardingMiddleware(plugin: self))
    }
}
