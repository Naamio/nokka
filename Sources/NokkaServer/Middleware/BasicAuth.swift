import Kitura
import LoggerAPI
import NokkaCore
import SwiftyRequest

/// This expects the secret token in `Authorization` header for
/// requests to certain endpoints. Hence, it serves as a gate.
class BasicAuthMiddleware: RouterMiddleware {
    let authToken: String
    init(token: String) {
        authToken = token
    }

    func handle(request: RouterRequest,
                response: RouterResponse,
                next: @escaping () -> Void)
    {
        let header = request.headers["Authorization"] ?? "       "
        let idx = header.index(header.startIndex, offsetBy: 7)
        if authToken == header[idx...] {
            next()
        } else {
            Log.info("Authorization failed")
            response.statusCode = .unauthorized
            response.finish()
        }
    }
}
