import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

/// This takes care of all incoming plugin registrations.
class RegistrationMiddleware: RouterMiddleware {
    let app: AppletServer
    // Since the handler is a class which updates the endpoints,
    // we need access the server class. So, we're storing it as a member.
    init(app: AppletServer) {
        self.app = app
    }

    func handle(request: RouterRequest,
                response: RouterResponse,
                next: @escaping () -> Void)
    {
        do {
            let data = try request.read(as: RegistrationData.self)
            Log.info("Incoming applet: \(data)")
            if let _ = self.app.endpoints[data.relUrl] {
                response.statusCode = .forbidden
            } else {
                let token = randomBase64(len: 64)
                let p = AppletInfo(name: data.name, url: data.endpoint, token: token)
                self.app.endpoints[data.relUrl] = p
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
