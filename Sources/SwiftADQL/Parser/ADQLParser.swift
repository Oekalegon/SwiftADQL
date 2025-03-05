import Foundation
import Parsing

public actor ADQLParser {
    // The first character of an identifier must be a letter or underscore
    private static let firstChar = First<Substring>().filter { $0.isLetter || $0 == "_" }
    // The rest of the characters of an identifier must be letters, underscores, or digits
    private static let restChars = Prefix<Substring> { $0.isLetter || $0 == "_" || $0.isNumber || $0 == "." }

    /// An identifier is a sequence of one or more characters that match the firstChar and restChars predicates
    private static let identifier = Parse {
        firstChar
        restChars
    }.map { String($0) + String($1) }

    /// A column identifier
    private static let columnIdentifier = Parse {
        identifier
    }.map { Identifier.column($0) }

    /// The asterisk identifier is a single asterisk
    private static let asterisk = Parse { "*" }.map { [Identifier.asterisk] }

    /// The table identifier
    private static let tableIdentifier = Parse {
        identifier
    }.map { Identifier.table($0) }

    /// A list of column identifiers (or a `*` wildcard)
    ///
    /// It returns an array of identifiers
    ///
    /// BNF:
    /// ```
    /// <select_list> ::=
    ///     <asterisk>
    ///   | <select_sublist> [ { <comma> <select_sublist> }... ]
    /// ```
    private static let columnList = Parse {
        Many {
            columnIdentifier
            Optionally {
                ","
                Whitespace()
            }
        }
    }.map { $0.map(\.0) }

    /// A list of table identifiers
    ///
    /// It returns an array of identifiers
    ///
    /// BNF:
    /// ```
    /// <table_list> ::=
    ///     <table_identifier> [ { <comma> <table_identifier> }... ]
    /// ```
    private static let tableList = Parse {
        Many {
            tableIdentifier
            Optionally {
                ","
                Whitespace()
            }
        }
    }.map { $0.map(\.0) }

    /// A quantifier used in a SELECT statement.
    ///
    /// Either ``DISTINCT`` or ``ALL``.
    ///
    /// BNF:
    /// ```
    /// <set_quantifier> ::= DISTINCT | ALL
    /// ```
    private static let setQuantifier = OneOf {
        Parse {
            "DISTINCT"
            Whitespace()
        }.map { SetQuantifier.distinct }

        Parse {
            "ALL"
            Whitespace()
        }.map { SetQuantifier.all }

        // No keyword case
        Always<Substring, SetQuantifier>(SetQuantifier.none)
    }

    /// A limit used in a SELECT statement.
    ///
    /// Either a limit value or no limit.
    ///
    /// BNF:
    /// ```
    /// <set_limit> ::= LIMIT <integer>
    /// ```
    private static let setLimit = OneOf {
        Parse {
            "LIMIT"
            Whitespace()
            Int.parser()
            Whitespace()
        }.map { SetLimit.limit($0) }

        // No keyword case
        Always<Substring, SetLimit>(SetLimit.none)
    }

    /// A SELECT query
    ///
    /// BNF:
    /// ```
    /// <select_query> ::=
    ///     SELECT
    ///         [ <set_quantifier> ]
    ///         [ <set_limit> ]
    ///         <select_list>
    ///         <table_expression>
    /// ```
    private static let select = Parse {
        "SELECT"
        Whitespace()
        setQuantifier
        setLimit
        OneOf {
            // Either a `*` wildcard
            asterisk
            // Or a list of column identifiers
            columnList
        }
        Whitespace()
        tableExpression
    }
    .map { (quantifier: SetQuantifier, limit: SetLimit, columns: [Identifier], tableExpression: TableExpression) in
        Select(
            columnIdentifiers: columns,
            quantifier: quantifier,
            limit: limit,
            tableExpression: tableExpression
        )
    }

    /// A FROM clause
    ///
    /// BNF:
    /// ```
    /// <from_clause> ::=
    ///     FROM <table_reference>
    ///     [ { <comma> <table_reference> }... ]
    /// ```
    private static let fromClause = Parse {
        "FROM"
        Whitespace()
        tableList
    }.map { (tables: [Identifier]) in
        FromClause(tables: tables)
    }

    /// A table expression
    ///
    /// BNF:
    /// ```
    /// <table_expression> ::=
    ///     <from_clause>
    ///     [ <where_clause> ]
    ///     [ <group_by_clause> ]
    ///     [ <having_clause> ]
    ///     [ <order_by_clause> ]
    ///     [ <offset_clause> ]
    /// ```
    private static let tableExpression = Parse {
        fromClause
    }.map { TableExpression(fromClause: $0) }

    /// The default initializer for the ADQL parser
    public init() {}

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
}
