import Foundation
import LoggerAPI
import SwiftyRequest

extension RestRequest {
    public func setJsonBody<S>(data: S) where S: Encodable {
        let jsonData = try! JSONEncoder().encode(data)
        self.headerParameters["Content-Length"] = String(format: "%d", jsonData.count)
        // Content-Type defaults to JSON
        Log.debug("Encoded JSON data: \(jsonData.count) bytes")
        self.messageBody = jsonData
    }
}
