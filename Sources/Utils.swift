import Foundation
import RandomKit

/// Swift version of https://docs.rs/log/*/log/enum.LogLevelFilter.html
enum LogLevel: UInt8 {
    case Off    = 0
    case Error  = 1
    case Warn   = 2
    case Info   = 3
    case Debug  = 4
    case Trace  = 5
}

class ObjectWrapper<T> {
    let object: T
    init(obj: T) {
        object = obj
    }
}

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
