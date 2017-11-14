import NokkaCore

class HostAuth {
    /// The host URL on which the applet registers itself
    let url: String
    /// Secret token of host
    let token: String
    /// Token supplied by host on successful registration
    var registeredToken: String?

    init(url: String, token: String) {
        self.url = url
        self.token = token
    }
}

/// A type that imitates a generic applet. The applet's functionality
/// is exposed by this type's methods. Subsequent sub-classes add their own
/// methods. By default, this only supports registering applets.
open class AppletClient {
    let name: String
    let address: String
    let client = HttpClient()
    var endpoints = [String: HostAuth]()

    public init(name: String, address: String) {
        self.name = name
        self.address = address.trim("/")
    }

    /// Register this applet on another applet.
    /// - `relUrl`   - Parent applet's relative URL to which this applet registers
    /// - `hostUrl`  - Parent applet's host address.
    /// - `token`    - Parent applet's secret token
    /// - `endpoint` - Child applet's endpoint to which payloads should be sent
    public func registerEndpoint(relUrl: String, hostUrl: String,
                                 token: String, endpoint: String? = nil)
    {
        var e = address + "/"
        if let ep = endpoint {
            e += ep.trim("/")
        }

        endpoints[relUrl] = HostAuth(url: hostUrl, token: token)

        client.registerApplet(name: name, relUrl: relUrl,
                              endpoint: e, hostUrl: hostUrl,
                              token: token, callback: { authToken in
            self.endpoints[relUrl]!.registeredToken = authToken
        })
    }
}
