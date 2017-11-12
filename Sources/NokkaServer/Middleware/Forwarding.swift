import Kitura
import LoggerAPI
import SwiftyRequest

class ForwardingMiddleware: RouterMiddleware {
    let server: Server
    init(server: Server) {
        self.server = server
    }

    func handle(request: RouterRequest,
                response: RouterResponse,
                next: @escaping () -> Void)
    {
        // TODO: Plugin proxy
        response.statusCode = .OK

        if let _ = self.server.endpoints[request.urlURL.absoluteString] {
            Log.info("Found server: \(server)")
        } else {
            Log.error("Nothing to forward to!")
        }

        response.finish()
    }
}