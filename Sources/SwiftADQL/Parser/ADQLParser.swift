import _StringProcessing
import Foundation
import Parsing

// Custom error type for parsing
public enum ParseError: Error {
    case expectedInput(String)
}

public actor ADQLParser {
    // MARK: - Identifiers

    /// A parser that parses a regular identifier.
    ///
    /// A regular identifier is a sequence of letters, numbers, and underscores,
    /// starting with a letter.
    ///
    /// For instance:
    /// * `my_identifier` is a valid regular identifier
    /// * `my-identifier` is not a valid regular identifier
    /// * `123identifier` is not a valid regular identifier
    public static let regularIdentifier: AnyParser<Substring, Identifier> = Parse {
        Prefix<Substring>(1...) { $0.isLetter && $0.isASCII }
        Prefix<Substring> { ($0.isLetter || $0.isNumber || $0 == "_") && $0.isASCII }
    }.map { parts in
        Identifier.regular(String("\(parts.0)\(parts.1)"))
    }.eraseToAnyParser()

    /// A parser that parses a delimited identifier, which is a sequence of characters
    /// enclosed in double quotes.
    ///
    /// The identifier is contained between double quotes, and may contain escaped
    /// double quotes (represented by two consecutive double quotes).
    ///
    /// For instance:
    /// * `"hello"` is a valid non-double-quoted delimited identifier
    /// * `"a quote ""hello world"""` is a valid non-double-quoted delimited identifier
    /// * `"hello""` is not a valid non-double-quoted delimited identifier
    public static let delimitedIdentifier: AnyParser<Substring, Identifier> = Parse {
        "\""
        Many {
            OneOf {
                // Case 1: Two consecutive single quotes ('') representing one quote
                Parse {
                    "\""
                    "\""
                }.map { "\"" }

                // Case 2: Any character that's not a double quote
                Prefix(1) { $0 != "\"" }.map { String($0) }
            }
        }.map { parts in
            Identifier.delimited(parts.joined())
        }
        "\""
    }.eraseToAnyParser()

    /// A parser that parses an identifier.
    ///
    /// The identifier can be a regular identifier or a delimited identifier.
    /// BNF:
    /// ```
    /// identifier ::= <regularIdentifier> | <delimitedIdentifier>
    /// ```
    public static let identifier: AnyParser<Substring, Identifier> = OneOf {
        regularIdentifier
        delimitedIdentifier
    }.eraseToAnyParser()

    /// A parser that parses a schema.
    ///
    /// A schema is an identifier optionally preceded by a catalog name.
    /// BNF:
    /// ```
    /// schema ::= [<catalog> "."] <identifier>
    /// ```
    public static let schema: AnyParser<Substring, Schema> = Parse {
        Optionally {
            identifier
            "."
        }
        identifier
    }.map { catalog, unqualifiedSchema in
        Schema(catalog: catalog, unqualifiedSchema: unqualifiedSchema)
    }.eraseToAnyParser()

    /// A parser that parses a table name.
    ///
    /// A table can be composed of one to three identifiers:
    /// * Optionally, a catalog identifier
    /// * Optionally, a schema identifier
    /// * A table identifier
    ///
    /// If the table name has a catalog, a schema is mandatory.
    /// If the table name has a schema, a table identifier is mandatory.
    ///
    /// For instance:
    /// * `my_catalog.my_schema.my_table` is a valid table name
    /// * `my_schema.my_table` is a valid table name
    /// * `my_table` is a valid table name
    ///
    /// Table names can also use delimited identifiers.
    /// For instance:
    /// * `"my catalog"."my schema"."my table"` is a valid table name
    /// * `"my schema"."my table"` is a valid table name
    /// * `"my table"` is a valid table name
    ///
    /// BNF:
    /// ```
    /// tableName ::= [<catalog> "."] [<schema> "."] <identifier>
    /// ```
    public static let tableName: AnyParser<Substring, Name> = Parse {
        Optionally {
            schema
            "."
        }
        identifier
    }.map { schema, identifier in
        Name.table(schema: schema, identifier: identifier)
    }.eraseToAnyParser()

    /// A parser that parses a column name.
    ///
    /// A column name is an identifier.
    ///
    /// BNF:
    /// ```
    /// columnName ::= <identifier>
    /// ```
    public static let columnName: AnyParser<Substring, Name> = Parse {
        identifier
    }.map { identifier in
        Name.column(identifier)
    }.eraseToAnyParser()

    /// A parser that parses a correlation name.
    ///
    /// A correlation name is an identifier.
    ///
    /// BNF:
    /// ```
    /// correlationName ::= <identifier>
    /// ```
    public static let correlationName: AnyParser<Substring, Name> = Parse {
        identifier
    }.map { identifier in
        Name.correlation(identifier)
    }.eraseToAnyParser()

    /// A parser that parses a qualifier.
    ///
    /// A qualifier can be a table name or a correlation name.
    ///
    /// BNF:
    /// ```
    /// qualifier ::= <tableName> | <correlationName>
    /// ```
    public static let qualifier: AnyParser<Substring, Qualifier> = OneOf {
        tableName.map { Qualifier.table($0) }
        correlationName.map { Qualifier.correlation($0) }
    }.eraseToAnyParser()

    /// A parser that parses a column reference.
    ///
    /// A column reference contains at least a column name.
    /// It may optionally be prefixed by a qualifier, which can be a table name or a correlation name.
    ///
    /// BNF:
    /// ```
    /// columnReference ::= [<qualifier> "."] <columnName>
    /// ```
    public static let columnReference: AnyParser<Substring, ColumnReference> = Parse {
        Optionally {
            qualifier
            "."
        }
        columnName
    }.map { qualifier, columnName in
        ColumnReference(qualifier: qualifier, columnName: columnName)
    }.eraseToAnyParser()

    // MARK: - Literals

    /// A parser that parses a non-quoted SQL-style string.
    ///
    /// The string is contained between single quotes, and may contain escaped
    /// single quotes (represented by two consecutive single quotes).
    ///
    /// For instance:
    /// * `'hello'` is a valid non-quoted string
    /// * `'isn''t'` is a valid non-quoted string
    /// * `'hello'` is not a valid non-quoted string
    public static let nonQuotedString: AnyParser<Substring, String> = Many {
        OneOf {
            // Case 1: Two consecutive single quotes ('') representing one quote
            Parse {
                "'"
                "'"
            }.map { "'" }

            // Case 2: Any character that's not a single quote
            Prefix(1) { $0 != "'" }.map { String($0) }
        }
    }.map { parts in
        parts.joined()
    }.eraseToAnyParser()

    /// Parses a hexadecimal literal
    ///
    /// BNF:
    /// ```
    /// hexadecimal ::= "0x" [0-9a-fA-F]+
    /// ```
    public static let hexadecimal = Parse {
        "0x"
        Prefix(while: { $0.isHexDigit })
    }.map { substring in
        UInt64(substring, radix: 16)
    }

    /// Parses a double literal
    ///
    /// BNF:
    /// ```
    /// doubleLiteral ::= [0-9]+ "." [0-9]+
    /// ```
    public static let doubleLiteral: AnyParser<Substring, UnsignedLiteral> = Parse {
        Prefix<Substring> { $0.isNumber }
        "."
        Prefix<Substring> { $0.isNumber }
    }.map { integers, decimals in
        UnsignedLiteral.double(Double(String(integers) + "." + String(decimals))!)
    }.eraseToAnyParser()

    /// Parses an unsigned literal
    ///
    /// BNF:
    /// ```
    /// unsignedLiteral ::=
    ///     <unsignedNumericLiteral>
    ///     | <generalLiteral>
    /// ```
    /// where:
    /// ```
    /// unsignedNumericLiteral ::=
    ///     <exact_numeric_literal>
    ///     | <approximate_numeric_literal>
    ///     | <unsigned_hexadecimal>
    /// ```
    /// where `exact_numeric_literal` and `approximate_numeric_literal` are in effect
    /// numerical values (doubles or integers, `approximate_numeric_literal` being a
    /// double with an exponent, e.g. "1.23e-4"), and `unsigned_hexadecimal` is a
    /// hexadecimal number (e.g. "0x1A").
    public static let unsignedLiteral: AnyParser<Substring, UnsignedLiteral> = OneOf {
        hexadecimal.map { $0 != nil ? UnsignedLiteral.hexadecimal($0!) : UnsignedLiteral.error }
        doubleLiteral
        Int.parser().map { UnsignedLiteral.int($0) }
        Parse {
            "'"
            nonQuotedString
            "'"
        }.map { UnsignedLiteral.string($0) }
    }.eraseToAnyParser()

    // MARK: - Value Expression

    public static let valueExpressionPrimary = OneOf {
        unsignedLiteral.map { ValueExpressionPrimary.unsignedLiteral($0) }
        columnReference.map { ValueExpressionPrimary.columnReference($0) }
        // TODO: Set Function Specification
        // TODO: Value Expression
        /*
         Parse {
             "("
             valueExpression
             ")"
         }
         */
    }.eraseToAnyParser()

    /// The default initializer for the ADQL parser
    public init() {}

    /*
     /// Parse an ADQL query
     ///
     /// - Parameter query: The ADQL query to parse
     /// - Returns: The parsed ADQL query
     public func parse(_ query: String) -> Result<String, Error> {
         do {
             var input = query[...]
             let result = try ADQLParser.select.parse(&input)
             print(result)
             print(input)
             return .success(String(describing: result))
         } catch {
             return .failure(error)
         }
     }
     */
}
