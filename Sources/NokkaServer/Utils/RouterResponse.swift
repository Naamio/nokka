import Foundation
import Kitura
import LoggerAPI

extension RouterResponse {
    func finish() {
        do {
            try self.end()      // only socket errors occur here
        } catch let err {
            Log.error("Error sending response: \(err)")
        }
    }
}