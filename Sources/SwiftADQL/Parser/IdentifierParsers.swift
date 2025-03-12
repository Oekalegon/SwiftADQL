import Foundation
import Parsing

/// A collection of parsers for column, table, and other identifiers.
public extension ADQLParser {
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
    static let regularIdentifier: AnyParser<Substring, Identifier> = Parse {
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
    static let delimitedIdentifier: AnyParser<Substring, Identifier> = Parse {
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
    static let identifier: AnyParser<Substring, Identifier> = OneOf {
        regularIdentifier
        delimitedIdentifier
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
    static let tableName: AnyParser<Substring, TableName> = Parse {
        Many(1...) {
            identifier
        } separator: {
            "."
        }
    }.map { identifiers in
        let tableName = identifiers.last!
        let catalog = identifiers.count > 2 ? identifiers[identifiers.count - 3] : nil
        let schema = identifiers.count > 1 ? identifiers[identifiers.count - 2] : nil
        return TableName(catalog: catalog, schema: schema, table: tableName)
    }.eraseToAnyParser()

    /// A parser that parses a column name.
    ///
    /// A column name is an identifier.
    ///
    /// BNF:
    /// ```
    /// columnName ::= <identifier>
    /// ```
    static let columnName = Parse {
        identifier
    }

    /// A parser that parses a correlation name.
    ///
    /// A correlation name is an identifier.
    ///
    /// BNF:
    /// ```
    /// correlationName ::= <identifier>
    /// ```
    static let correlationName = Parse {
        identifier
    }

    /// A parser that parses a column reference.
    ///
    /// A column reference contains at least a column name.
    /// It may optionally be prefixed by a qualifier, which can be a table name or a correlation name.
    ///
    /// BNF:
    /// ```
    /// columnReference ::= [<qualifier> "."] <columnName>
    /// ```
    static let columnReference: AnyParser<Substring, ColumnReference> = Parse {
        Many(1...) {
            identifier
        } separator: {
            "."
        }
    }.map { identifiers in
        let columnName = identifiers.last!
        let catalog = identifiers.count > 3 ? identifiers[identifiers.count - 4] : nil
        let schema = identifiers.count > 2 ? identifiers[identifiers.count - 3] : nil
        let tableName = identifiers.count > 1 ? identifiers[identifiers.count - 2] : nil
        let table = tableName != nil ? TableName(catalog: catalog, schema: schema, table: tableName!) : nil
        return ColumnReference(tableName: table, columnName: columnName)
    }.eraseToAnyParser()
}
