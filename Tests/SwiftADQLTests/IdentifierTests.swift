import Foundation
import Parsing
import XCTest

@testable import SwiftADQL

final class IdentifierTests: XCTestCase {
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
                TableName(
                    catalog: Identifier.regular("my_catalog"),
                    schema: Identifier.regular("my_schema"),
                    table: Identifier.regular("my_table")
                )
            )
        }
        do {
            var input = "my_schema.my_table"[...]
            let result = try ADQLParser.tableName.parse(&input)
            XCTAssertEqual(
                result,
                TableName(
                    catalog: nil,
                    schema: Identifier.regular("my_schema"),
                    table: Identifier.regular("my_table")
                )
            )
        }
        do {
            var input = "my_table"[...]
            let result = try ADQLParser.tableName.parse(&input)
            XCTAssertEqual(
                result,
                TableName(
                    catalog: nil,
                    schema: nil,
                    table: Identifier.regular("my_table")
                )
            )
        }
    }

    func testColumnName() throws {
        do {
            var input = "my_column"[...]
            let result = try ADQLParser.columnName.parse(&input)
            XCTAssertEqual(result, Identifier.regular("my_column"))
        }
    }

    func testColumnReference() throws {
        do {
            var input = "my_table.my_column"[...]
            let result = try ADQLParser.columnReference.parse(&input)
            XCTAssertEqual(
                result,
                ColumnReference(
                    tableName: TableName(
                        catalog: nil,
                        schema: nil,
                        table: Identifier.regular("my_table")
                    ),
                    columnName: Identifier.regular("my_column")
                )
            )
        }
        do {
            var input = "my_schema.my_table.my_column"[...]
            let result = try ADQLParser.columnReference.parse(&input)
            XCTAssertEqual(
                result,
                ColumnReference(
                    tableName: TableName(
                        catalog: nil,
                        schema: Identifier.regular("my_schema"),
                        table: Identifier.regular("my_table")
                    ),
                    columnName: Identifier.regular("my_column")
                )
            )
        }
        do {
            var input = "my_catalog.my_schema.my_table.my_column"[...]
            let result = try ADQLParser.columnReference.parse(&input)
            XCTAssertEqual(
                result,
                ColumnReference(
                    tableName: TableName(
                        catalog: Identifier.regular("my_catalog"),
                        schema: Identifier.regular("my_schema"),
                        table: Identifier.regular("my_table")
                    ),
                    columnName: Identifier.regular("my_column")
                )
            )
        }
    }
}
