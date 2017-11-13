public class AppletClient {
    class HostAuth {
        let url: String
        let token: String
        var registeredToken: String?

        init(url: String, token: String) {
            self.url = url
            self.token = token
        }
    }

    let name: String
    let address: String
    let client = Client()
    var endpoints = [String: HostAuth]()

    public init(name: String, address: String) {
        self.name = name
        self.address = address.trim(chars: "/")
    }

    public func registerEndpoint(relUrl: String, hostUrl: String,
                                 token: String, endpoint: String? = nil)
    {
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
