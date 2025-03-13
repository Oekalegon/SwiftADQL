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

public struct TableName: Equatable, CustomStringConvertible {
    public let catalog: Identifier?
    public let schema: Identifier?
    public let table: Identifier

    public var description: String {
        var components: [String] = []
        if let catalog {
            components.append(catalog.description)
        }
        if let schema {
            components.append(schema.description)
        }
        components.append(table.description)
        return components.joined(separator: ".")
    }
}

public struct ColumnReference: Equatable {
    let tableName: TableName?
    let columnName: Identifier

    public var description: String {
        var components: [String] = []
        if let tableName {
            components.append(tableName.description)
        }
        components.append(columnName.description)
        return components.joined(separator: ".")
    }
}

public indirect enum ValueExpression: Equatable {
    case numericValueExpression(NumericValueExpression)
    case stringValueExpression  // TODO: Add String Value Expression
    case booleanValueExpression // TODO: Add Boolean Value Expression
    case geometryValueExpression // TODO: Add Geometry Value Expression
}

public enum ValueExpressionPrimary: Equatable {
    case unsignedLiteral(UnsignedLiteral)
    case columnReference(ColumnReference)
    // TODO: Set Function Specification
    case expression(ValueExpression)
}

// MARK: - Set Functions

public enum SetFunctionSpecification: Equatable {
    case countAll
    case general(SetFunction, SetQuantifier?) // TODO: Add Value Expression
}

/// A type that represents a set function.
public enum SetFunction: Equatable {
    case count
    case average
    case maximum
    case minimum
    case sum
}

/// A type that represents a set quantifier.
public enum SetQuantifier: Equatable {
    case distinct
    case all
}

// MARK: - Numeric Expressions

public enum NumericPrimary: Equatable {
    case expression(ValueExpressionPrimary)
    case function // TODO: Add numeric value function
}

public enum Factor: Equatable {
    case expression(sign: Double, value: ValueExpressionPrimary)
    case function(sign: Double) // TODO: Add numeric value function
    // TODO: Set Function Specification
}

public indirect enum Term: Equatable {
    case factor(Factor)
    case multiplication(Term, Factor)
    case division(Term, Factor)
}

public indirect enum NumericValueExpression: Equatable {
    case term(Term)
    case bitwiseNot(NumericValueExpression)
    case bitwiseAnd(NumericValueExpression, NumericValueExpression)
    case bitwiseOr(NumericValueExpression, NumericValueExpression)
    case bitwiseXor(NumericValueExpression, NumericValueExpression)
    case addition(NumericValueExpression, NumericValueExpression)
    case subtraction(NumericValueExpression, NumericValueExpression)
}

// MARK: - Cursor position

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
