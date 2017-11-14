import Foundation
import LoggerAPI
import NokkaCore
import SwiftyRequest

extension HttpClient {
    /// This is used internally (by `AppletClient`) for registering
    /// an applet.
    public func registerApplet(name: String, relUrl: String,
                               endpoint: String, hostUrl: String,
                               token: String,
                               callback: @escaping (String) -> Void)
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
