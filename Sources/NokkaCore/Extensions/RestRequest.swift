import Foundation
import LoggerAPI
import SwiftyRequest

extension RestRequest {
    /// A helper method to JSON serialize the given object to the `RestRequest`
    public func setJsonBody<S>(data: S) where S: Encodable {
        let jsonData = try! JSONEncoder().encode(data)
        // Content-Type defaults to JSON
        Log.debug("Encoded JSON data: \(jsonData.count) bytes")
        self.setData(data: jsonData)
    }

    /// Set the message body with the given data (along with the `Content-Length` header)
    public func setData(data: Data) {
        self.headerParameters["Content-Length"] = String(format: "%d", data.count)
        self.messageBody = data
    }
}
