import Foundation
import Merileva

extension ByteArray {
    /// This method is used on `ByteArray` (owned by Rust) sent through FFI.
    /// It lives only as long as the function call, and so this should be used
    /// only in sync functions.
    func asString() -> String? {
        let ptr = UnsafeBufferPointer(start: bytes, count: len)
        return String(bytes: ptr, encoding: String.Encoding.utf8)
    }

    /// Deallocate the allocated pointer.
    func deallocate() {
        UnsafeMutablePointer(mutating: bytes).deallocate(capacity: len)
    }
}

extension String {
    /// This method is used for sending Strings from Swift. Since its
    /// memory is auto-managed, it lives only as long as the owning scope
    /// (I think?!!)
    func asByteArray() -> ByteArray? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)

        stream.open()
        let _ = data.withUnsafeBytes({
            stream.write($0, maxLength: data.count)
        })

        stream.close()
        return ByteArray(bytes: buffer, len: data.count)
    }
}

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
        if let addr = addr.asByteArray() {
            set_naamio_host(addr)
        }
    }

    /* Plugin methods and related classes */

    private class RegistrationData {
        let data: RegisterRequest?
        let callback: (ByteArray) -> Void

        init(name: String, relUrl: String, endpoint: String,
             cb: @escaping (String) -> Void)
        {
            if let name = name.asByteArray(),
               let relUrl = relUrl.asByteArray(),
               let endpoint = endpoint.asByteArray()
            {
                data = RegisterRequest(name: name, rel_url: relUrl,
                                       endpoint: endpoint)
            } else {
                data = nil
            }

            callback = { (token) in
                if let token = token.asString() {
                    cb(token)
                }
            }
        }

        deinit {
            if let d = data {
                d.name.deallocate()
                d.rel_url.deallocate()
                d.endpoint.deallocate()
            }
        }
    }

    /// [async] Perform a plugin registration request.
    func registerPlugin(name: String, relUrl: String,
                        endpoint: String,
                        callback: @escaping (String) -> Void)
    {
        let data = RegistrationData(name: name, relUrl: relUrl,
                                    endpoint: endpoint, cb: callback)
        if var req = data.data {
            let opaque = Unmanaged.passUnretained(data).toOpaque()
            let dataPtr = UnsafeMutableRawPointer(opaque)

            register_plugin(dataPtr, ptr, &req, { (dataPtr, token) in
                if let dataPtr = dataPtr {
                    let data = Unmanaged<RegistrationData>.fromOpaque(dataPtr)
                                                          .takeUnretainedValue()
                    data.callback(token)
                }
            })
        } else {
            // Cannot create byte array?
        }
    }
}

let service = NaamioService(threads: 4)
service.setLogLevel(level: LogLevel.Info)
service.registerPlugin(name: "foo", relUrl: "/hey",
                       endpoint: "http://localhost:5000/",
                       callback: { (token) in
    print("Token: \(token)")
})

// Give time for the async Rust future to resolve. In reality, we'll be having
// an infinite loop, so this won't be necessary.
sleep(1)
