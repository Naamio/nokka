import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

class RegistrationMiddleware: RouterMiddleware {
    let server: Server
    init(server: Server) {
        self.server = server
    }

    func handle(request: RouterRequest,
                response: RouterResponse,
                next: @escaping () -> Void)
    {
        do {
            let data = try request.read(as: RegistrationData.self)
            Log.info("Incoming server: \(data)")
            if let _ = self.server.endpoints[data.relUrl] {
                response.statusCode = .forbidden
            } else {
                let token = randomBase64(len: 64)
                let p = AppletInfo(name: data.name, url: data.endpoint, token: token)
                self.server.endpoints[data.relUrl] = p
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
