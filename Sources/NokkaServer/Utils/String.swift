import Foundation 
// To throw errors with custom messages
extension String: Error {}

extension String {
    /// Helper function so that I don't have to type this beast all the time!
    func trim(chars: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: chars))
    }
}