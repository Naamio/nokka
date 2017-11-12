import Foundation
import LoggerAPI
import NokkaCore
import SwiftyRequest

/// # Client
public class Client {

    public init() {}

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

    func registerApplet(name: String, relUrl: String,
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
