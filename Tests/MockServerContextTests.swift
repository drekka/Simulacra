//
//  Created by Derek Clarkson on 21/9/2022.
//

import Foundation
import Nimble
@testable import SimulcraCore
import XCTest

class MockServerContextTests: XCTestCase {

    var context: MockMockServerContext!

    override func setUp() {
        context = MockMockServerContext()
    }

    func testRequestTemplateData() {

        context.cache["abc"] = "def"
        let templateData = context.requestTemplateData(adding: ["xyz": 123])

        expect(templateData.count) == 2
        expect(templateData["abc"] as? String) == "def"
        expect(templateData["xyz"] as? Int) == 123
    }

    func testRequestTemplateDataOverridesMockServer() {

        context.cache["mockServer"] = "http://1.2.3.4:5555"
        let templateData = context.requestTemplateData(adding: ["mockServer": "http://127.0.0.1:9999"])

        expect(templateData.count) == 1
        expect(templateData["mockServer"] as? String) == "http://127.0.0.1:9999"
    }

    func testRequestTemplateDataUpdatesWhenSameKey() {

        context.cache["abc"] = "def"
        let templateData = context.requestTemplateData(adding: ["abc": 123])

        expect(templateData.count) == 1
        expect(templateData["abc"] as? Int) == 123
    }
}
