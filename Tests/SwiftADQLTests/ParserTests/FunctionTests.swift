import Foundation
import Parsing
import XCTest

@testable import SwiftADQL

final class FunctionTests: XCTestCase {
    func testGeneralSetFunction() async throws {
        do {
            // TODO: Add Value Expression
            let result = try ADQLParser.generalSetFunction.parse("AVG ( )")
            XCTAssertEqual(result.0, .average)
            XCTAssertNil(result.1)
            print(result)
        }
        do {
            // TODO: Add Value Expression
            let result = try ADQLParser.generalSetFunction.parse("MAX (DISTINCT )")
            XCTAssertEqual(result.0, .maximum)
            XCTAssertEqual(result.1, .distinct)
            print(result)
        }
    }

    func testSetFunctionSpecification() async throws {
        do {
            let result = try ADQLParser.setFunctionSpecification.parse("COUNT ( * )")
            XCTAssertEqual(result, .countAll)
            print(result)
        }
        do {
            let result = try ADQLParser.setFunctionSpecification.parse("AVG ( )")
            XCTAssertEqual(result, .general(.average, nil))
            print(result)
        }
        do {
            let result = try ADQLParser.setFunctionSpecification.parse("MAX (DISTINCT )")
            XCTAssertEqual(result, .general(.maximum, .distinct))
            print(result)
        }
    }
}
