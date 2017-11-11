import Foundation
import HeliumLogger
import LoggerAPI

Log.logger = HeliumLogger()
let service = NaamioService(threads: 4)
service.setLogLevel(level: LogLevel.Info)

// Give time for the async Rust future to resolve. In reality, we'll be having
// an infinite loop, so this won't be necessary. But, removing this now, will
// result in segfault.
sleep(1)
