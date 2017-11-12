struct RegistrationData: Codable {
    let name: String
    let relUrl: String
    let endpoint: String
}

struct Token: Codable {
    let token: String
}
