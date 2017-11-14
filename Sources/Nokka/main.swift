import Dispatch
import Foundation
import HeliumLogger
import Kitura
import LoggerAPI
import NokkaCore
import NokkaClient
import NokkaServer

Log.logger = HeliumLogger(.info)

// Let's create some plugins. Since Naamio handles plugin registrations
// just like any other plugin, this shouldn't be any different.
let odin = AppletServer(port: 8000)
let thor = AppletServer(port: 8001)
let loki = AppletServer(port: 8002)

// For now, we consider one plugin, and Odin owns all,
// though this doesn't have to be the case.
let odinHome = "http://0.0.0.0:8000/"
let odinSecret = odin.authToken

// Unlike the above, these represent the client-side version of the plugin.
// (they're not the plugins themselves, but they should be consistent)
let thorOdinson = AppletClient(name: "Thor", address: "http://0.0.0.0:8001")
let lokiLaufeyson = AppletClient(name: "Loki", address: "http://0.0.0.0:8002")

DispatchQueue.global().async {
    sleep(3)    // Wait for the servers to come up.
    Log.info("Beginning registrations...")

    thorOdinson.registerEndpoint(relUrl: "/asgard", hostUrl: odinHome,
                                 token: odinSecret)
    // forward Odin's "/midgard" traffic to Thor's "/earth"
    thorOdinson.registerEndpoint(relUrl: "/midgard", hostUrl: odinHome,
                                 token: odinSecret, endpoint: "/home")
    lokiLaufeyson.registerEndpoint(relUrl: "/jötunheimr", hostUrl: odinHome,
                                   token: odinSecret)
    // Loki tries to cheat
    lokiLaufeyson.registerEndpoint(relUrl: "/midgard", hostUrl: odinHome,
                                   token: odinSecret, endpoint: "/earth")
}

odin.createHTTPServer()
thor.createHTTPServer()
loki.createHTTPServer()

Kitura.run()
