@testable import Nokka
import XCTest

class TestServer: XCTestCase {

    let server:NaamioPlugin = NaamioPlugin()

    static var allTests: [(String, (TestServer) -> () throws -> Void)] {
        return [
            ("testServerStartup", testServerStartup)
        ]
    }
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testServerStartup() {
        // Set up server for this test
        
    }
}