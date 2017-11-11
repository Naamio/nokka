import Foundation

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

extension String {
    /// Helper function so that I don't have to type this beast all the time!
    func trim(chars: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: chars))
    }
}
