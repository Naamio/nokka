import Foundation
import LoggerAPI
import SwiftyRequest

/// A generic client for making HTTP requests.
public class HttpClient {

    public init() {}

    /// Prepare a request for the given URL and method.
    /// (also set the Bearer token, if given)
    public func prepareRequest(method: HTTPMethod, url: String,
                               auth: String? = nil) -> RestRequest
    {
        Log.info("\(method): \(url)")
        let req = RestRequest(method: method, url: url)
        if let a = auth {
            Log.debug("Setting bearer token")
            req.headerParameters["Authorization"] = "Bearer " + a
        }

        return req
    }

    /// Make a request with the given `RestRequest`, and expect
    /// JSON data in the response.
    public func request<D>(with: RestRequest,
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
}
