import Foundation
import Merileva

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
    private let service: UnsafePointer<NaamioService>
    private var endpoints = [String: HostAuth]()

    init(name: String, address: String,
         service: UnsafePointer<NaamioService>) {
        self.name = name
        self.service = service
        self.address = address.trim(chars: "/")
    }

    func registerEndpoint(relUrl: String, hostUrl: String, token: String) {
        self.registerEndpoint(relUrl: relUrl, hostUrl: hostUrl,
                              token: token, endpoint: nil)
    }

    func registerEndpoint(relUrl: String, hostUrl: String,
                          token: String, endpoint: String?) {
        var e = address + "/"
        if let ep = endpoint {
            e += ep.trim(chars: "/")
        }

        var data = RegistrationData(name: name, rel_url: relUrl, endpoint: e)
        var req = RequestRequirements(url: hostUrl, token: token)
        endpoints[relUrl] = HostAuth(url: hostUrl, token: token)

        service.pointee.registerPlugin(req: &req, data: &data, callback: {(authToken) in
            self.endpoints[relUrl]!.registeredToken = authToken
        })
    }
}

/// Swift wrapper class for the Rust struct. It takes care of all the dangerous
/// FFI calls and exposes safe methods outside.
public class NaamioService {
    /// We treat complex Rust structs as opaque structs.
    private let ptr: OpaquePointer

    /// Initialize the Rust struct and get the pointer.
    init(threads: UInt8) {
        ptr = create_service(threads)
    }

    /// Kindly ask Rust to deallocate the FFI-owned struct.
    /// Swift should never try this!
    deinit {
        drop_service(ptr)
    }

    /// Set the log level. Note that this can be initialized only once.
    /// Further calls have no effect.
    func setLogLevel(level: LogLevel) {
        set_log_level(level.rawValue)
    }

    /* Plugin methods and related classes */

    // Swift doesn't allow us to cast closures to pointers, and
    // we can't pass capturing closures to C function pointers.
    // So, we workaround by storing the callback  into a class
    // and casting it as a void pointer (which should be freed later).

    // NOTE: I'm still unsure whether it's the right way, but I'm
    // quite sure that we shouldn't do async stuff in these callback closures.
    // Because, the FFI values passed to the callbacks are owned by Rust,
    // and it deallocates them immediately after the function call)

    typealias RegistrationClosure = ObjectWrapper<((String) -> Void)>

    /// [async] Perform a plugin registration request to a specified URL.
    func registerPlugin(req: UnsafeMutablePointer<RequestRequirements>,
                        data: UnsafeMutablePointer<RegistrationData>,
                        callback: @escaping (String) -> Void)
    {
        let cb = ObjectWrapper(obj: callback)
        let opaque = Unmanaged.passUnretained(cb).toOpaque()
        let cbPtr = UnsafeMutableRawPointer(opaque)

        register_plugin(cbPtr, self.ptr, req,
                        data, { (cbPtr, token) in
            if let cbPtr = cbPtr, let token = token {
                let d = Unmanaged<RegistrationClosure>.fromOpaque(cbPtr)
                                                      .takeUnretainedValue()
                d.object(String(cString: token))
            }
        })
    }
}
