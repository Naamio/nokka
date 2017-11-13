import Foundation
import Kitura
import LoggerAPI

extension RouterResponse {
    public func finish() {
        do {
            try self.end()      // only socket errors occur here
        } catch let err {
            Log.error("Error sending response: \(err)")
        }
    }
}
