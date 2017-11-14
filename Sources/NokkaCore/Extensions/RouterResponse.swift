import Foundation
import Kitura
import LoggerAPI

extension RouterResponse {
    /// Some of the middlewares end the response without passing to the next.
    /// Since the overriding function signature is not "throwing",
    /// we can't use `.end()` in any of the middlewares. Here, we just end and log
    /// if there are any socket errors (which is what we're supposed to do anyway)
    public func finish() {
        do {
            try self.end()      // only socket errors occur here
        } catch let err {
            Log.error("Error sending response: \(err)")
        }
    }
}
