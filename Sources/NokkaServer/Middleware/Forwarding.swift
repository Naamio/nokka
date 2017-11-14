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
        let url = request.urlURL.absoluteString
        // FIXME: This only supports exact matches. We should support
        // more generic matches (something like URL components?)
        if let plugin = self.app.endpoints[url] {
            Log.info("Found plugin for \(url): \(plugin)")
            // FIXME: We should use the plugin's unique auth token for sending
            // payload to plugin. Otherwise, anyone can send the payload.
            let req = self.client.prepareRequest(method: HTTPMethod.post,
                                                 url: plugin.url)
            req.responseData(completionHandler: { resp in
                let innerResp = resp.response!
                if let code = HTTPStatusCode(rawValue: innerResp.statusCode) {
                    response.statusCode = code
                }

                if let data = resp.data {
                    response.send(data: data)
                }
            })
        } else {
            Log.info("No matching plugins found for \(url)")
            response.statusCode = .notFound
        }

        response.finish()
    }
}
