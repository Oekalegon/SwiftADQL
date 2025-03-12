import Foundation
import Parsing

/// A collection of parsers for value expressions.
public extension ADQLParser {
    // MARK: - Value Expression

    static let valueExpressionPrimary = OneOf {
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

    // MARK: - Numeric Expressions

    static let numericPrimary = OneOf {
        valueExpressionPrimary
        // TODO: numericValueFunction
    }

    static let factor = Parse {
        Optionally {
            OneOf {
                "+".map { 1.0 }
                "-".map { -1.0 }
            }
        }.map { $0 ?? 1.0 }
        numericPrimary
    }.map { output in
        let (sign, valueExpressionPrimary) = output
        return Factor.expression(sign: sign, value: valueExpressionPrimary)
    }

    static let term = Parse {
        factor
        Many {
            Whitespace()
            OneOf {
                Parse {
                    "*"
                    Whitespace()
                    factor
                }.map { (op: "*", rhs: $0) }

                Parse {
                    "/"
                    Whitespace()
                    factor
                }.map { (op: "/", rhs: $0) }
            }
        }
    }.map { lhs, operations in
        operations.reduce(Term.factor(lhs)) { result, operation in
            switch operation.op {
            case "*": Term.multiplication(result, operation.rhs)
            case "/": Term.division(result, operation.rhs)
            default: fatalError("Unexpected operator")
            }
        }
    }
}
