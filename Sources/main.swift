import Dispatch
import Foundation
import HeliumLogger
import Kitura
import LoggerAPI

Log.logger = HeliumLogger()
var service = NaamioService(threads: 4)
service.setLogLevel(level: LogLevel.Info)

// Let's create some plugins. Since Naamio handles plugin registrations
// just like any other plugin, this shouldn't be any different.
let odin = NaamioPlugin()
let thor = NaamioPlugin()
let loki = NaamioPlugin()

// For now, we consider one plugin, and Odin owns all,
// though this doesn't have to be the case.
let odinHome = "http://0.0.0.0:8000/plugins/register"
let odinSecret = odin.authToken

// Unlike the above, these represent the client-side version of the plugin.
// (they're not the plugins themselves, but they should be consistent)
let odinBorson = Plugin(name: "Odin",
                        address: "http://0.0.0.0:8000",
                        service: &service)
let thorOdinson = Plugin(name: "Thor",
                         address: "http://0.0.0.0:8001",
                         service: &service)
let lokiLaufeyson = Plugin(name: "Loki",
                           address: "http://0.0.0.0:8002",
                           service: &service)

DispatchQueue.global().async {
    sleep(5)
    print("Beginning registrations...")

    thorOdinson.registerEndpoint(relUrl: "/asgard", hostUrl: odinHome,
                                 token: odinSecret)
    // forward Odin's "/midgard" traffic to Thor's "/earth"
    thorOdinson.registerEndpoint(relUrl: "/midgard", hostUrl: odinHome,
                                 token: odinSecret, endpoint: "/earth")
    lokiLaufeyson.registerEndpoint(relUrl: "/jötunheimr", hostUrl: odinHome,
                                   token: odinSecret, endpoint: "/home")
}

Kitura.addHTTPServer(onPort: 8000, with: odin.router)
Kitura.addHTTPServer(onPort: 8001, with: thor.router)
Kitura.addHTTPServer(onPort: 8002, with: loki.router)
Kitura.run()
