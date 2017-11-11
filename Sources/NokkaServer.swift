import Foundation
import Kitura
import LoggerAPI
import RandomKit

public class NaamioPlugin {
    let authMiddleware: BasicAuthMiddleware

    class BasicAuthMiddleware: RouterMiddleware {
        let auth: String

        init() {
            let threadLocal = Xoroshiro.threadLocal
            let a = String.random(ofLength: 64, using: &threadLocal.pointee)
            let base64 = Data(a.utf8).base64EncodedString()
            let idx = base64.index(base64.startIndex, offsetBy: a.count)
            auth = String(base64[..<idx])
        }

        func handle(request: RouterRequest,
                    response: RouterResponse,
                    next: @escaping () -> Void)
        {
            if auth != request.headers["Authorization"] {
                Log.info("Authorization failed")
                //
            }

            next()
        }
    }

    init() {
        authMiddleware = BasicAuthMiddleware()
    }

    func authToken() -> String {
        return authMiddleware.auth
    }
}
