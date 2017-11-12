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
                    callback: @escaping (HttpResponse<D>) -> Void)
        where D: Decodable
    {
        with.responseData(completionHandler: { resp in
            var d: D? = nil
            // We're not performing any substitutions, so this will exist
            let response = resp.response!

            do {
                if let data = resp.data {
                    d = try JSONDecoder().decode(D.self, from: data)
                } else {
                    throw "Empty body"
                }
            } catch let err {
                Log.error("Cannot get JSON data: \(err)")
            }

            let r = HttpResponse(data: d, code: response.statusCode,
                                 headers: response.allHeaderFields)
            callback(r)
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
        request(with: req, callback: { (response: HttpResponse<Token>) in
            if response.code == 200 {
                if let t = response.data {
                    callback(t.token)
                } else {
                    Log.error("Failed to get token for plugin registration")
                }
            } else if response.code == 401 {
                Log.error("Auth failed with server")
            } else if response.code == 403 {
                Log.error("Server has forbidden us!")
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
