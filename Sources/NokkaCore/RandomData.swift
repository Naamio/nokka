import Foundation
import RandomKit

/// Base64-encoded random string of given length
public func randomBase64(len: Int) -> String {
    return Xoroshiro.withThreadLocal({ (prng: inout Xoroshiro) -> String in
        let a = String.random(ofLength: len, using: &prng)
        let base64 = Data(a.utf8).base64EncodedString()
        let idx = base64.index(base64.startIndex, offsetBy: len)
        return String(base64[..<idx])
    })
}
