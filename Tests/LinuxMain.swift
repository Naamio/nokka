import XCTest

@testable import NokkaTests

XCTMain([
    testCase(TestAppletRegistration.allTests),
    testCase(TestAppletForwarding.allTests)
])
