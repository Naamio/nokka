struct HttpResponse<T> {
    let data: T?
    let code: Int
    let headers: [AnyHashable: Any]
}

struct RegistrationData: Codable {
    let name: String
    let relUrl: String
    let endpoint: String
}

struct Token: Codable {
    let token: String
}
