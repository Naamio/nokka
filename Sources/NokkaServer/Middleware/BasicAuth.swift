import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

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
