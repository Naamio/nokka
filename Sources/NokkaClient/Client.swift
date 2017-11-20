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
                               callback: @escaping (String?) -> Void)
    {
        let url = hostUrl.joinPath(NokkaRoutes.appletRegistration)
        let req = prepareRequest(method: HTTPMethod.post, url: url, auth: token)
        let data = RegistrationData(name: name, relUrl: relUrl, endpoint: endpoint)

        Log.info("Registering plugin \(name) (relUrl: \(relUrl), endpoint: \(endpoint))")
        req.setJsonBody(data: data)

        request(with: req, callback: { (response: HttpResponse<Token>) in
            if response.code == 200 {
                if let t = response.data {
                    return callback(t.token)
                } else {
                    Log.error("Failed to get token for plugin registration")
                }
            } else {
                Log.error("Registration failed: (code: \(response.code))")
            }

            callback(nil)
        })
    }
}
