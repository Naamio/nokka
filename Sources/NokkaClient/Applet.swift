public class AppletClient {
    private class HostAuth {
        let url: String
        let token: String
        var registeredToken: String?

        init(url: String, token: String) {
            self.url = url
            self.token = token
        }
    }

    private let name: String
    private let address: String
    private let client: Client
    private var endpoints = [String: HostAuth]()

    public init(name: String, address: String, client: Client) {
        self.name = name
        self.client = client
        self.address = address.trim(chars: "/")
    }

    public func registerEndpoint(relUrl: String, hostUrl: String,
                          token: String, endpoint: String? = nil) {
        var e = address + "/"
        if let ep = endpoint {
            e += ep.trim(chars: "/")
        }

        endpoints[relUrl] = HostAuth(url: hostUrl, token: token)

        client.registerApplet(name: name, relUrl: relUrl,
                              endpoint: e, hostUrl: hostUrl,
                              token: token, callback: { authToken in
            self.endpoints[relUrl]!.registeredToken = authToken
        })
    }
}