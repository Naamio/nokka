import Foundation
import LoggerAPI
import SwiftyRequest

extension RestRequest {
    /// A helper method to set the `Content-Length` header
    /// along with JSON serializing the given object to the `RestRequest`
    public func setJsonBody<S>(data: S) where S: Encodable {
        let jsonData = try! JSONEncoder().encode(data)
        self.headerParameters["Content-Length"] = String(format: "%d", jsonData.count)
        // Content-Type defaults to JSON
        Log.debug("Encoded JSON data: \(jsonData.count) bytes")
        self.messageBody = jsonData
    }
}
