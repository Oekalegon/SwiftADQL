import Foundation

/// An identifier
public enum Identifier {
    case table(String)
    case column(String)
    case asterisk
}

/// A quantifier used in e.g. a SELECT statement.
///
/// Either ``DISTINCT`` or ``ALL``.
public enum SetQuantifier {
    /// DISTINCT
    case distinct
    /// ALL
    case all
    /// No quantifier
    case none
}

/// A limit used in e.g. a SELECT statement.
///
/// Either a limit value or no limit.
public enum SetLimit {
    /// A limit value
    case limit(Int)
    /// No limit
    case none
}

/// The ADQL SELECT statement in a query.
public struct Select: CustomStringConvertible {
    /// The identifiers to select
    public var columnIdentifiers: [Identifier]

    /// The quantifier to use
    public var quantifier: SetQuantifier

    /// The limit to use
    public var limit: SetLimit

    public var tableExpression: TableExpression

    public var description: String {
        """
        SELECT \(quantifier) \(limit) \(columnIdentifiers)
            \(tableExpression)
        """
    }
}

/// A FROM clause in an ADQL query.
public struct FromClause: CustomStringConvertible {
    /// The tables to select from
    public var tables: [Identifier]

    /// The description of the FROM clause
    public var description: String {
        "FROM \(tables)"
    }
}

/// A table expression in an ADQL query.
public struct TableExpression: CustomStringConvertible {
    /// The FROM clause
    public var fromClause: FromClause

    /// The description of the table expression
    public var description: String {
        "TABLE EXPRESSION: \(fromClause)"
    }
}
