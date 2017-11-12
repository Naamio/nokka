import Foundation
import Kitura
import LoggerAPI
import SwiftyRequest

public class Applet {
    let router: Router
    var endpoints: [String: AppletInfo]
    let authToken: String

    class AppletInfo {
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
            if auth == header[idx...] {
                next()
            } else {
                Log.info("Authorization failed")
                response.statusCode = .unauthorized
                response.finish()
            }
        }
    }

    class AppletRegistrationMiddleware: RouterMiddleware {
        let applet: Applet
        init(applet: Applet) {
            self.applet = applet
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            do {
                let data = try request.read(as: RegistrationData.self)
                Log.info("Incoming applet: \(data)")
                if let _ = self.applet.endpoints[data.relUrl] {
                    response.statusCode = .forbidden
                } else {
                    let token = randomBase64(len: 64)
                    let p = AppletInfo(name: data.name, url: data.endpoint, token: token)
                    self.applet.endpoints[data.relUrl] = p
                    Log.info("Successfully registered \(p.name) for \(p.url)")
                    response.statusCode = .OK
                    response.send(json: Token(token: token))
                }
            } catch let err {
                Log.error("Cannot obtain JSON object from request: \(err)")
                response.statusCode = .badRequest
            }

            response.finish()
        }
    }

    class ForwardingMiddleware: RouterMiddleware {
        let applet: Applet
        init(applet: Applet) {
            self.applet = applet
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            // TODO: Plugin proxy
            response.statusCode = .OK

            if let applet = self.applet.endpoints[request.urlURL.absoluteString] {
                Log.info("Found applet: \(applet)")
            } else {
                Log.error("Nothing to forward to!")
            }

            response.finish()
        }
    }

    init() {
        router = Router()
        endpoints = [String: AppletInfo]()
        authToken = randomBase64(len: 64)

        router.post("/applets/register", middleware: BasicAuthMiddleware(auth: authToken))
        router.post("/applets/register", middleware: AppletRegistrationMiddleware(applet: self))
        router.all("/*", middleware: ForwardingMiddleware(applet: self))
    }
}
