import Foundation
import Parsing
import XCTest

@testable import SwiftADQL

final class ADQLTests: XCTestCase {
    /*
     func testGaiaAreaQuery() async throws {
         // Get the URL for the test bundle
         guard let url = Bundle.module.url(
             forResource: "gaia-area-query",
             withExtension: "adql",
             subdirectory: "Resources"
         ) else {
             XCTFail("Could not find gaia-area-query.adql in Resources")
             return
         }

         // Read the contents of the file
         let adqlQuery = try String(contentsOf: url, encoding: .utf8)

         // Print the query for debugging
         print("Loaded ADQL query: \(adqlQuery)")

         // Create a parser instance
         let parser = ADQLParser()

         // Call the parse method (this doesn't do anything yet, but demonstrates usage)
         let result = await parser.parse(adqlQuery)
         print(result)

         // Now you can use the query string for your test
         XCTAssertFalse(adqlQuery.isEmpty)

         // Add more assertions based on what you want to test with this query
         // For example, you might want to parse it and verify the structure
         // or execute it against your ADQL implementation
     }

     func testSimbadAreaQuery() async throws {
         // Get the URL for the test bundle
         guard let url = Bundle.module.url(
             forResource: "simbad-area-query-join",
             withExtension: "adql",
             subdirectory: "Resources"
         ) else {
             XCTFail("Could not find simbad-area-query.adql in Resources")
             return
         }

         // Read the contents of the file
         let adqlQuery = try String(contentsOf: url, encoding: .utf8)

         // Print the query for debugging
         print("Loaded ADQL query: \(adqlQuery)")

         // Create a parser instance
         let parser = ADQLParser()

         // Call the parse method (this doesn't do anything yet, but demonstrates usage)
         let result = await parser.parse(adqlQuery)
         print(result)

         // Now you can use the query string for your test
         XCTAssertFalse(adqlQuery.isEmpty)

         // Add more assertions based on what you want to test with this query
         // For example, you might want to parse it and verify the structure
     }

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
         let result = await parser.parse(adqlQuery)
         print(result)

         // Now you can use the query string for your test
         XCTAssertFalse(adqlQuery.isEmpty)

         // Add more assertions based on what you want to test with this query
         // For example, you might want to parse it and verify the structure
         // or execute it against your ADQL implementation
     }

     func testBasicQueries() async throws {
         let parser = ADQLParser()

         do {
             let query = "SELECT * FROM stars;"
             let result = await parser.parse(query)
             print(result)
         }

         do {
             let query = "SELECT name, ra, dec FROM stars;"
             let result = await parser.parse(query)
             print(result)
         }

         do {
             let query = "SELECT COUNT(*) FROM galaxies;"
             let result = await parser.parse(query)
             print(result)
         }
     }
     */
}
