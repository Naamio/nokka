@testable import NokkaClient
@testable import NokkaServer

import Dispatch
import Kitura
import KituraNet
import NokkaCore
import SwiftyRequest
import XCTest

class TestAppletForwarding: XCTestCase {
    let zeus = AppletServer(port: 8000)
    let athena = AppletServer(port: 8001)

    let zeusHome = "http://0.0.0.0:8000"
    let athenaHome = "http://0.0.0.0:8001"

    let athenaCaller = AppletClient(name: "Athena", address: "http://0.0.0.0:8001")

    static var allTests: [(String, (TestAppletForwarding) -> () throws -> Void)] {
        return [
            ("SuccessfulForward", testSuccessfulForward),
        ]
    }

    struct AthenaSecret: Codable {
        let message: String
    }

    override func setUp() {
        super.setUp()

        zeus.createHTTPServer()
        zeus.initializeForwarding()

        athena.router.post("/dad") { req, resp, next in
            let _ = try! req.read(as: AthenaSecret.self)
            resp.statusCode = HTTPStatusCode.OK
            resp.send(json: AthenaSecret(message: "On the way!"))
                .finish()
        }

        athena.createHTTPServer()

        DispatchQueue(label: "Request queue").async() {
            Kitura.run()
        }
    }

    override func tearDown() {
        super.tearDown()

        Kitura.stop()
    }

    func testSuccessfulForward() {
        func callForHelp() {
            let lightningBolt = expectation(description: "Zeus transfers message packet")
            let client = HttpClient()
            let req = client.prepareRequest(method: HTTPMethod.post,
                                            url: zeusHome.joinPath("/athena"))
            req.setJsonBody(data: AthenaSecret(message: "Help!"))
            client.request(with: req, callback: { (response: HttpResponse<AthenaSecret>) in
                XCTAssertEqual(response.code, 200,
                               "Athena's message hasn't arrived!")
                XCTAssertEqual(response.data!.message, "On the way!",
                               "Athena's message has been tampered!")
                lightningBolt.fulfill()
            })
        }

        let athenaDemands = expectation(description: "Athena asks Zeus to notify her")
        athenaCaller.registerEndpoint(relUrl: "/athena", hostUrl: zeusHome,
                                      token: zeus.authToken,
                                      endpoint: "/dad", callback: { token in
            XCTAssertNotNil(token, "Athena is the daughter of Zeus! He can't deny!!!")
            athenaDemands.fulfill()
            callForHelp()
        })

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
