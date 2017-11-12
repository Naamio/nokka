import Foundation
import LoggerAPI
import SwiftyRequest

public class NaamioClient {
    func prepareRequest(method: HTTPMethod, url: String,
                        auth: String?) -> RestRequest
    {
        Log.info("\(method): \(url)")
        let req = RestRequest(method: method, url: url)
        if let a = auth {
            Log.debug("Setting bearer token")
            req.headerParameters["Authorization"] = "Bearer " + a
        }

        return req
    }

    func request<D>(with: RestRequest,
                    callback: @escaping (D?) -> Void)
        where D: Decodable
    {
        with.responseData(completionHandler: { response in
            if let data = response.data {
                let d = try? JSONDecoder().decode(D.self, from: data)
                callback(d)
            } else {
                callback(nil)
            }
        })
    }

    func registerPlugin(name: String, relUrl: String,
                        endpoint: String, hostUrl: String,
                        token: String, callback: @escaping (String) -> Void)
    {
        let req = prepareRequest(method: HTTPMethod.post, url: hostUrl, auth: token)
        let d = RegistrationData(name: name, relUrl: relUrl, endpoint: endpoint)
        Log.info("Registering plugin \(name) (relUrl: \(relUrl), endpoint: \(endpoint))")
        req.setJsonBody(data: d)
        request(with: req, callback: { (token: Token?) in
            if let t = token {
                callback(t.token)
            } else {
                Log.error("Failed to get token for plugin registration")
            }
        })
    }
}

public class Plugin {
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
    private let client: NaamioClient
    private var endpoints = [String: HostAuth]()

    init(name: String, address: String, client: NaamioClient) {
        self.name = name
        self.client = client
        self.address = address.trim(chars: "/")
    }

    func registerEndpoint(relUrl: String, hostUrl: String,
                          token: String, endpoint: String? = nil) {
        var e = address + "/"
        if let ep = endpoint {
            e += ep.trim(chars: "/")
        }

        endpoints[relUrl] = HostAuth(url: hostUrl, token: token)

        client.registerPlugin(name: name, relUrl: relUrl,
                              endpoint: e, hostUrl: hostUrl,
                              token: token, callback: { authToken in
            self.endpoints[relUrl]!.registeredToken = authToken
        })
    }
}
