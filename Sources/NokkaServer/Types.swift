public struct HttpResponse<T> {
    let data: T?
    let code: Int
    let headers: [AnyHashable: Any]
}

public struct RegistrationData: Codable {
    let name: String
    let relUrl: String
    let endpoint: String
}

public struct Token: Codable {
    let token: String
}
