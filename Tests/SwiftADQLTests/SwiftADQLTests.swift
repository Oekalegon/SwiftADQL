import Foundation
import XCTest

@testable import SwiftADQL

final class ADQLTests: XCTestCase {
    func testSimbadIDQuery() async throws {
        // Get the URL for the test bundle
        guard let url = Bundle.module.url(
            forResource: "simbad-id-query",
            withExtension: "adql",
            subdirectory: "Resources"
        ) else {
            XCTFail("Could not find simbad-id-query.adql in Resources")
            return
        }

        // Read the contents of the file
        let adqlQuery = try String(contentsOf: url, encoding: .utf8)

        // Print the query for debugging
        print("Loaded ADQL query: \(adqlQuery)")

        // Create a parser instance
        let parser = ADQLParser()

        // Call the parse method (this doesn't do anything yet, but demonstrates usage)
        parser.parse(query: adqlQuery)

        // Now you can use the query string for your test
        XCTAssertFalse(adqlQuery.isEmpty)

        // Add more assertions based on what you want to test with this query
        // For example, you might want to parse it and verify the structure
        // or execute it against your ADQL implementation
    }
}
