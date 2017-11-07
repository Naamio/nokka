import Foundation
import Merileva

/// Swift version of https://docs.rs/log/*/log/enum.LogLevelFilter.html
enum LogLevel: UInt8 {
    case Off    = 0
    case Error  = 1
    case Warn   = 2
    case Info   = 3
    case Debug  = 4
    case Trace  = 5
}

/// Swift wrapper class for the Rust struct. It takes care of all the dangerous
/// FFI calls and exposes safe methods outside.
class NaamioService {
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

    /// Set the Naamio host address (by default, it's "http://localhost:8000"
    /// Invalid URIs have no effect. Also, this is mutable at runtime.
    func setHost(addr: String) {
        set_naamio_host(addr)
    }

    /* Plugin methods and related classes */

    private class RegistrationData {
        var data: RegisterRequest
        let callback: (String) -> Void

        init(name: String, relUrl: String, endpoint: String,
             cb: @escaping (String) -> Void)
        {
            data = RegisterRequest(name: name, rel_url: relUrl,
                                   endpoint: endpoint)
            callback = cb
        }
    }

    /// [async] Perform a plugin registration request.
    func registerPlugin(name: String, relUrl: String,
                        endpoint: String,
                        callback: @escaping (String) -> Void)
    {
        let data = RegistrationData(name: name, relUrl: relUrl,
                                    endpoint: endpoint, cb: callback)
        let opaque = Unmanaged.passUnretained(data).toOpaque()
        let dataPtr = UnsafeMutableRawPointer(opaque)

        register_plugin(dataPtr, self.ptr, &data.data, { (dataPtr, token) in
            if let dataPtr = dataPtr, let token = token {
                let data = Unmanaged<RegistrationData>.fromOpaque(dataPtr)
                                                      .takeUnretainedValue()
                data.callback(String(cString: token))
            }
        })
    }
}

func testService() {
    let service = NaamioService(threads: 4)
    service.setHost(addr: "http://localhost:8000")
    service.setLogLevel(level: LogLevel.Info)
    service.registerPlugin(name: "foo", relUrl: "/hey",
                           endpoint: "http://localhost:5000/",
                           callback: { (token) in
        print("Token: \(token)")
    })

    // Give time for the async Rust future to resolve. In reality, we'll be having
    // an infinite loop, so this won't be necessary. But, removing this now, will
    // result in segfault.
    sleep(1)
}

testService()
