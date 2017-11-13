public struct HttpResponse<T> {
    public let data: T?
    public let code: Int
    public let headers: [AnyHashable: Any]

    public init(data: T?, code: Int, headers: [AnyHashable: Any]) {
        self.data = data
        self.code = code
        self.headers = headers
    }
}

public struct RegistrationData: Codable {
    public let name: String
    public let relUrl: String
    public let endpoint: String

    public init(name: String, relUrl: String, endpoint: String) {
        self.name = name
        self.relUrl = relUrl
        self.endpoint = endpoint
    }
}

public struct Token: Codable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}
