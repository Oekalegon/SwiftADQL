import Foundation
import Parsing

/// A collection of parsers for value expressions.
public extension ADQLParser {
    // MARK: - Value Expression

    static let valueExpression = OneOf {
        numericValueExpression.map { ValueExpression.numericValueExpression($0) }
        // TODO: String Value Expression
        // TODO: Boolean Value Expression
        // TODO: Geometry Value Expression
    }

    static let valueExpressionPrimary = OneOf {
        unsignedLiteral.map { ValueExpressionPrimary.unsignedLiteral($0) }
        columnReference.map { ValueExpressionPrimary.columnReference($0) }
        // TODO: Set Function Specification
        // TODO: Value Expression
        Parse {
            "("
            valueExpression.map { ValueExpressionPrimary.expression($0) }
            ")"
        }
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

    static let numericValueExpression: AnyParser<Substring, NumericValueExpression> = {
        // Create a reference we can update later
        var exprRef: AnyParser<Substring, NumericValueExpression>!

        // Term parser (lowest level)
        let termExpr = term.map { NumericValueExpression.term($0) }

        // Apply unary NOT to basic expressions - this gives NOT higher precedence
        let unaryExpr = OneOf {
            Parse {
                "~"
                Whitespace()
                termExpr
            }.map { NumericValueExpression.bitwiseNot($0) }
            termExpr
        }

        // Helper function to create binary operation parsers with the specified operators
        func makeBinaryOpParser(
            leftParser: AnyParser<Substring, NumericValueExpression>,
            operators: [(String, (NumericValueExpression, NumericValueExpression) -> NumericValueExpression)]
        ) -> AnyParser<Substring, NumericValueExpression> {
            Parse {
                leftParser
                Many {
                    Parse {
                        Whitespace()
                        OneOf {
                            // Create a parser for each operator string
                            for (ops, _) in operators {
                                Parse { ops }.map { ops }
                            }
                        }
                        Whitespace()
                        leftParser
                    }.map { ops, right in
                        (op: ops, right: right)
                    }
                }
            }.map { left, operations -> NumericValueExpression in
                operations.reduce(left) { result, operation in
                    let foundOp = operators.first { $0.0 == operation.op }!
                    return foundOp.1(result, operation.right)
                }
            }.eraseToAnyParser()
        }

        // Build precedence levels, starting with unary expression as the base
        // Level 1: Bitwise AND
        let bitwiseAndExpr = makeBinaryOpParser(
            leftParser: unaryExpr.eraseToAnyParser(),
            operators: [("&", { NumericValueExpression.bitwiseAnd($0, $1) })]
        )

        // Level 2: Bitwise XOR
        let bitwiseXorExpr = makeBinaryOpParser(
            leftParser: bitwiseAndExpr,
            operators: [("^", { NumericValueExpression.bitwiseXor($0, $1) })]
        )

        // Level 3: Bitwise OR
        let bitwiseOrExpr = makeBinaryOpParser(
            leftParser: bitwiseXorExpr,
            operators: [("|", { NumericValueExpression.bitwiseOr($0, $1) })]
        )

        // Level 4: Addition and Subtraction
        let additiveExpr = makeBinaryOpParser(
            leftParser: bitwiseOrExpr,
            operators: [
                ("+", { NumericValueExpression.addition($0, $1) }),
                ("-", { NumericValueExpression.subtraction($0, $1) }),
            ]
        )

        // Complete the cycle - the final expression parser is the additive expression
        exprRef = additiveExpr

        return additiveExpr
    }()

    // MARK: - Bitwise Expressions

    // Bitwise expressions are now handled directly in numericValueExpression
}
