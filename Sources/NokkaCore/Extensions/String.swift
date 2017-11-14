import Foundation

// To throw errors with custom messages
extension String: Error {}

extension String {
    /// Helper function so that I don't have to type this beast all the time!
    public func trim(_ chars: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: chars))
    }

    /// Join two paths after properly trimming additional separators
    /// on both the components.
    public func joinPath(_ path: String) -> String {
        return self.trim("/") + "/" + path.trim("/")
    }
}
