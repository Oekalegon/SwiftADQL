import Foundation
import Parsing
import XCTest

@testable import SwiftADQL

final class ADQLTests: XCTestCase {
    func testUnsignedLiteral() async throws {
        let result = try ADQLParser.unsignedLiteral.parse("123")
        XCTAssertEqual(result, .int(123))
        print(result)
    }

    func testIntLiteralParsing() throws {
        var input = "123"[...]
        let result = try ADQLParser.unsignedLiteral.parse(&input)
        XCTAssertEqual(result, UnsignedLiteral.int(123))
    }

    // Add more tests for other literal types
    func testDoubleLiteralParsing() throws {
        do {
            var input = "123.45"[...]
            let result = try ADQLParser.unsignedLiteral.parse(&input)
            XCTAssertEqual(result, UnsignedLiteral.double(123.45))
        }
        do {
            var input = ".45"[...]
            let result = try ADQLParser.unsignedLiteral.parse(&input)
            XCTAssertEqual(result, UnsignedLiteral.double(0.45))
        }
    }

    func testStringLiteralParsing() throws {
        var input = "'hello'"[...]
        let result = try ADQLParser.unsignedLiteral.parse(&input)
        XCTAssertEqual(result, UnsignedLiteral.string("hello"))
    }

    func testStringWithEscapedQuotes() throws {
        var input = "'isn''t'"[...]
        let result = try ADQLParser.unsignedLiteral.parse(&input)
        XCTAssertEqual(result, UnsignedLiteral.string("isn't"))
    }

    func testHexadecimalLiteralParsing() throws {
        var input = "0x1A"[...]
        let result = try ADQLParser.unsignedLiteral.parse(&input)
        XCTAssertEqual(result, UnsignedLiteral.hexadecimal(26))
    }

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

    // Test that numbers with decimal points are parsed as doubles, not ints
    func testNumberFormats() throws {
        // Test that integers are parsed as Int
        do {
            var input = "123"[...]
            let result = try ADQLParser.unsignedLiteral.parse(&input)
            XCTAssertEqual(result, UnsignedLiteral.int(123))
        }

        // Test that decimal numbers are parsed as Double
        do {
            var input = "123.45"[...]
            let result = try ADQLParser.unsignedLiteral.parse(&input)
            XCTAssertEqual(result, UnsignedLiteral.double(123.45))
        }

        // Test that numbers with only the decimal part are parsed as Double
        do {
            var input = "0.45"[...]
            let result = try ADQLParser.unsignedLiteral.parse(&input)
            XCTAssertEqual(result, UnsignedLiteral.double(0.45))
        }
    }

    func testRegularIdentifier() throws {
        do {
            var input = "my_identifier15"[...]
            let result = try ADQLParser.regularIdentifier.parse(&input)
            XCTAssertEqual(result, Identifier.regular("my_identifier15"))
        }

        // This should fail because hyphens are not allowed in identifiers
        do {
            var input = "my-identifier"[...]
            _ = try ADQLParser.regularIdentifier.parse(&input)
            // The first part will match an identifier, but the second part will not
            // which means not all input was consumed.
            // So we test if there is any input left
            XCTAssertFalse(input.isEmpty)
        }

        do {
            // Now this should fail because the input does not even
            // start with an identifier.
            var input = "023_21Lala"[...]
            _ = try ADQLParser.regularIdentifier.parse(&input)
            XCTFail("Parsing should have failed with an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testDelimitedIdentifier() throws {
        do {
            var input = "\"hello\""[...]
            let result = try ADQLParser.delimitedIdentifier.parse(&input)
            XCTAssertEqual(result, Identifier.delimited("hello"))
        }
        do {
            var input = "\"hello world\""[...]
            let result = try ADQLParser.delimitedIdentifier.parse(&input)
            XCTAssertEqual(result, Identifier.delimited("hello world"))
        }
        do {
            var input = "\"hello \"\"world\"\"\""[...]
            let result = try ADQLParser.delimitedIdentifier.parse(&input)
            XCTAssertEqual(result, Identifier.delimited("hello \"world\""))
        }
        do {
            var input = "\"hello\" world\""[...]
            _ = try ADQLParser.delimitedIdentifier.parse(&input)
            // The first part will match an identifier, but the second part will not
            // which means not all input was consumed.
            // So we test if there is any input left
            XCTAssertFalse(input.isEmpty)
        }
        do {
            var input = "\"hello\"\""[...]
            _ = try ADQLParser.delimitedIdentifier.parse(&input)
            XCTFail("Parsing should have failed with an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testTableName() throws {
        do {
            var input = "my_catalog.my_schema.my_table"[...]
            let result = try ADQLParser.tableName.parse(&input)
            XCTAssertEqual(
                result,
                Name.table(
                    schema: Schema(
                        catalog: Identifier.regular("my_catalog"),
                        unqualifiedSchema: Identifier.regular("my_schema")
                    ),
                    identifier: Identifier.regular("my_table")
                )
            )
        }
        do {
            var input = "my_schema.my_table"[...]
            let result = try ADQLParser.tableName.parse(&input)
            XCTAssertEqual(
                result,
                Name.table(
                    schema: Schema(
                        catalog: nil,
                        unqualifiedSchema: Identifier.regular("my_schema")
                    ),
                    identifier: Identifier.regular("my_table")
                )
            )
        }
        do {
            var input = "my_table"[...]
            let result = try ADQLParser.tableName.parse(&input)
            XCTAssertEqual(result, Name.table(schema: nil, identifier: Identifier.regular("my_table")))
        }
    }

    func testColumnName() throws {
        do {
            var input = "my_column"[...]
            let result = try ADQLParser.columnName.parse(&input)
            XCTAssertEqual(result, Name.column(Identifier.regular("my_column")))
        }
    }

    func testColumnReference() throws {
        do {
            var input = "my_table.my_column"[...]
            let result = try ADQLParser.columnReference.parse(&input)
            XCTAssertEqual(
                result,
                ColumnReference(
                    qualifier: Qualifier.table(
                        Name.table(
                            schema: nil,
                            identifier: Identifier.regular("my_table")
                        )
                    ),
                    columnName: Name.column(Identifier.regular("my_column"))
                )
            )
        }
        do {
            var input = "my_schema.my_table.my_column"[...]
            let result = try ADQLParser.columnReference.parse(&input)
            XCTAssertEqual(
                result,
                ColumnReference(
                    qualifier: Qualifier.table(
                        Name.table(
                            schema: Schema(
                                catalog: nil,
                                unqualifiedSchema: Identifier.regular("my_schema")
                            ),
                            identifier: Identifier.regular("my_table")
                        )
                    ),
                    columnName: Name.column(Identifier.regular("my_column"))
                )
            )
        }
    }
}
