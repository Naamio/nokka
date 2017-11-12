import Foundation
import LoggerAPI
import RandomKit
import SwiftyRequest

/// Base64-encoded random string of given length
func randomBase64(len: Int) -> String {
    return Xoroshiro.withThreadLocal({ (prng: inout Xoroshiro) -> String in
        let a = String.random(ofLength: len, using: &prng)
        let base64 = Data(a.utf8).base64EncodedString()
        let idx = base64.index(base64.startIndex, offsetBy: len)
        return String(base64[..<idx])
    })
}

extension String {
    /// Helper function so that I don't have to type this beast all the time!
    func trim(chars: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: chars))
    }
}

extension RestRequest {
    func setJsonBody<S>(data: S) where S: Encodable {
        let jsonData = try! JSONEncoder().encode(data)
        self.headerParameters["Content-Length"] = String(format: "%d", jsonData.count)
        // Content-Type defaults to JSON
        Log.debug("Encoded JSON data: \(jsonData.count) bytes")
        self.messageBody = jsonData
    }
}
