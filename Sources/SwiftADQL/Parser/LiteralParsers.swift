import Foundation
import Parsing

/// A collection of parsers for literal values..
public extension ADQLParser {
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
    static let nonQuotedString: AnyParser<Substring, String> = Many {
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
    static let hexadecimal = Parse {
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
    static let doubleLiteral: AnyParser<Substring, UnsignedLiteral> = Parse {
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
    static let unsignedLiteral: AnyParser<Substring, UnsignedLiteral> = OneOf {
        hexadecimal.map { $0 != nil ? UnsignedLiteral.hexadecimal($0!) : UnsignedLiteral.error }
        doubleLiteral
        Int.parser().map { UnsignedLiteral.int($0) }
        Parse {
            "'"
            nonQuotedString
            "'"
        }.map { UnsignedLiteral.string($0) }
    }.eraseToAnyParser()
}
