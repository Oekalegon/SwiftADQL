import Foundation
import Parsing

public enum UnsignedLiteral: Equatable {
    case int(Int)
    case double(Double)
    case hexadecimal(UInt64)
    case string(String)
    case error
}

public enum Identifier: Equatable, CustomStringConvertible {
    case regular(String)
    case delimited(String)

    public var description: String {
        switch self {
        case let .regular(string):
            string
        case let .delimited(string):
            "\"\(string)\""
        }
    }
}

public struct Schema: Equatable, CustomStringConvertible {
    let catalog: Identifier?
    let unqualifiedSchema: Identifier

    public var description: String {
        if let catalog {
            "\(catalog).\(unqualifiedSchema)"
        } else {
            unqualifiedSchema.description
        }
    }
}

public enum Name: Equatable, CustomStringConvertible {
    case table(schema: Schema?, identifier: Identifier)
    case column(Identifier)
    case correlation(Identifier)

    public var description: String {
        switch self {
        case let .table(schema, identifier):
            if let schema {
                "\(schema).\(identifier)"
            } else {
                identifier.description
            }
        case let .column(identifier):
            identifier.description
        case let .correlation(identifier):
            identifier.description
        }
    }
}

public enum Qualifier: Equatable {
    case table(Name)
    case correlation(Name)
}

public struct ColumnReference: Equatable {
    let qualifier: Qualifier?
    let columnName: Name
}

public enum ValueExpressionPrimary: Equatable {
    case unsignedLiteral(UnsignedLiteral)
    case columnReference(ColumnReference)
    // TODO: Set Function Specification
    // TODO: Value Expression
}

public struct TokenLocation: CustomStringConvertible {
    public let line: Int
    public let column: Int

    public var description: String {
        "\(line):\(column)"
    }
}

// To get Position information from the parser, we need to define a custom parser.
public struct Position: Parser {
    public init() {}

    public func parse(_ input: inout Substring) throws -> TokenLocation {
        // Get the current position by looking at input's startIndex
        let text = input.base // Get the original string
        let currentIndex = input.startIndex

        // Count lines and columns up to current position
        var line = 1
        var column = 1

        for idx in text[..<currentIndex].indices {
            if text[idx] == "\n" {
                line += 1
                column = 1
            } else {
                column += 1
            }
        }

        return TokenLocation(line: line, column: column)
    }
}
