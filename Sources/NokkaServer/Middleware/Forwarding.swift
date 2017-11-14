import Foundation
import Kitura
import KituraNet
import LoggerAPI
import NokkaCore
import SwiftyRequest

/// This forwards all incoming requests to matching plugins.
class ForwardingMiddleware: RouterMiddleware {
    let app: AppletServer
    let client: HttpClient
    // We need the applet because we need to update the endpoints.
    init(app: AppletServer) {
        self.app = app
        self.client = app.client
    }

    func handle(request: RouterRequest,
                response: RouterResponse,
                next: @escaping () -> Void)
    {
        // FIXME: Check for root URL
        let url = NSURL(string: request.urlURL.absoluteString)!
        let path = url.path!
        // FIXME: This only supports exact matches. We should support
        // more generic matches (something like URL components?)
        if let plugin = self.app.endpoints[path] {
            Log.info("Found plugin for \(path): \(plugin)")
            // FIXME: We should use the plugin's unique auth token for sending
            // payload to plugin. Otherwise, anyone can send the payload.
            let req = self.client.prepareRequest(method: HTTPMethod.post,
                                                 url: plugin.url)
            var data = Data()
            do {
                try request.read(into: &data)
            } catch let err {
                Log.error("Cannot read request data: \(err)")
                response.statusCode = .internalServerError
                return response.finish()
            }

            req.setData(data: data)
            req.responseData(completionHandler: { resp in
                let innerResp = resp.response!
                if let code = HTTPStatusCode(rawValue: innerResp.statusCode) {
                    response.statusCode = code
                }

                if let data = resp.data {
                    response.send(data: data)
                }

                response.finish()
            })
        } else {
            Log.info("No matching plugins found for \(path)")
            response.statusCode = .notFound
            response.finish()
        }
    }
}
