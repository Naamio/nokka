@testable import NokkaClient
@testable import NokkaServer

import Dispatch
import Kitura
import NokkaCore
import SwiftyRequest
import XCTest

class TestAppletRegistration: XCTestCase {

    // Let's create some plugins. Since Naamio handles plugin registrations
    // just like any other plugin, this shouldn't be any different.

    // For now, we consider one plugin (Odin), and he owns all,
    // though this doesn't have to be the case.

    let odinBorson = AppletServer(port: 8000)
    let thorOdinson = AppletServer(port: 8001)
    let lokiLaufeyson = AppletServer(port: 8002)

    let odinHome = "http://0.0.0.0:8000"
    let thorHome = "http://0.0.0.0:8001"

    // Unlike AppletServer, AppletClients represent the client-side version of the plugin.
    // (they're not the plugins themselves, but they should be consistent)

    let thor = AppletClient(name: "Thor", address: "http://0.0.0.0:8001")
    let loki = AppletClient(name: "Loki", address: "http://0.0.0.0:8002")

    static var allTests: [(String, (TestAppletRegistration) -> () throws -> Void)] {
        return [
            ("SuccessfulRegistration", testSuccessfulRegistration),
            ("DuplicateRegistration", testDuplicateRegistration),
            ("InvalidRegistration", testInvalidRegistration),
            ("NonAuthenticatedRegistration", testNonAuthenticatedRegistration)
        ]
    }

    override func setUp() {
        super.setUp()

        odinBorson.createHTTPServer()
        thorOdinson.createHTTPServer()
        lokiLaufeyson.createHTTPServer()

        DispatchQueue(label: "Request queue").async() {
            Kitura.run()
        }
    }

    override func tearDown() {
        super.tearDown()

        Kitura.stop()
    }

    func testSuccessfulRegistration() {
        let thorWants = expectation(description: "Thor waits in queue")
        let lokiWants = expectation(description: "Loki waits in queue")

        thor.registerEndpoint(relUrl: "/asgard", hostUrl: odinHome,
                              token: odinBorson.authToken, callback: { token in
            XCTAssertNotNil(token, "Thor cannot access Asgard. He's angry now!")
            thorWants.fulfill()
        })

        loki.registerEndpoint(relUrl: "/jötunheimr", hostUrl: odinHome,
                              token: odinBorson.authToken, callback: { token in
            XCTAssertNotNil(token, "Loki cannot go to Jötunheimr. His rage is on you!")
            lokiWants.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testDuplicateRegistration() {
        let thorWants = expectation(description: "Thor waits in queue")
        let lokiWants = expectation(description: "Loki waits in queue")

        thor.registerEndpoint(relUrl: "/midgard", hostUrl: odinHome,
                              token: odinBorson.authToken,
                              endpoint: "/home", callback: { token in
            XCTAssertNotNil(token, "Thor's love is on Earth. You're not helping him!")
            thorWants.fulfill()
        })

        loki.registerEndpoint(relUrl: "/midgard", hostUrl: odinHome,
                              token: odinBorson.authToken,
                              endpoint: "/battlefield", callback: { token in
            XCTAssertNil(token, "You've let Loki into Earth!!!")
            lokiWants.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    private struct Foo: Codable {
        let foobar: String
    }

    func testInvalidRegistration() {
        let laufeyIntrusion = expectation(description: "Laufey intrudes Bifröst")
        let url = odinHome.joinPath(NokkaRoutes.appletRegistration)
        let client = HttpClient()
        let req = client.prepareRequest(method: HTTPMethod.post,
                                        url: url,
                                        auth: odinBorson.authToken)
        req.responseData(completionHandler: { resp in
            let response = resp.response!
            XCTAssertEqual(response.statusCode, 400,
                           "Laufey should've been kicked!")
            laufeyIntrusion.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    func testNonAuthenticatedRegistration() {
        let hammerLift = expectation(description: "Someone tries to lift Mjölnir")
        let url = thorHome.joinPath(NokkaRoutes.appletRegistration)
        let client = HttpClient()
        let req = client.prepareRequest(method: HTTPMethod.post, url: url)

        req.responseData(completionHandler: { resp in
            let response = resp.response!
            XCTAssertEqual(response.statusCode, 401,
                           "NOBODY CAN LIFT Mjölnir!!!")
            hammerLift.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
