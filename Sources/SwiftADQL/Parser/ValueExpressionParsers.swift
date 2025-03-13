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
        Parse {
            "("
            Lazy {
                valueExpression.map { ValueExpressionPrimary.expression($0) }
            }
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
        // Term is our base building block
        let termExpr = term.map { NumericValueExpression.term($0) }

        // Define our precedence levels

        // Level 0: Basic term or NOT expression
        let notExpr = Parse {
            "~"
            Whitespace()
            termExpr
        }.map { NumericValueExpression.bitwiseNot($0) }

        let baseExpr = OneOf {
            notExpr
            termExpr
        }.eraseToAnyParser()

        // Level 1: Bitwise AND
        let andExpr = Parse {
            baseExpr
            Many {
                Parse {
                    Whitespace()
                    "&"
                    Whitespace()
                    baseExpr
                }
            }
        }.map { left, rights in
            rights.reduce(left) { result, right in
                NumericValueExpression.bitwiseAnd(result, right)
            }
        }.eraseToAnyParser()

        // Level 2: Bitwise XOR
        let xorExpr = Parse {
            andExpr
            Many {
                Parse {
                    Whitespace()
                    "^"
                    Whitespace()
                    andExpr
                }
            }
        }.map { left, rights in
            rights.reduce(left) { result, right in
                NumericValueExpression.bitwiseXor(result, right)
            }
        }.eraseToAnyParser()

        // Level 3: Bitwise OR
        let orExpr = Parse {
            xorExpr
            Many {
                Parse {
                    Whitespace()
                    "|"
                    Whitespace()
                    xorExpr
                }
            }
        }.map { left, rights in
            rights.reduce(left) { result, right in
                NumericValueExpression.bitwiseOr(result, right)
            }
        }.eraseToAnyParser()

        // Level 4: Addition/Subtraction
        let addSubExpr = Parse {
            orExpr
            Many {
                OneOf {
                    Parse {
                        Whitespace()
                        "+"
                        Whitespace()
                        orExpr
                    }.map { ("+", $0) }

                    Parse {
                        Whitespace()
                        "-"
                        Whitespace()
                        orExpr
                    }.map { ("-", $0) }
                }
            }
        }.map { left, operations in
            operations.reduce(left) { result, operation in
                let (ops, right) = operation
                switch ops {
                case "+": return NumericValueExpression.addition(result, right)
                case "-": return NumericValueExpression.subtraction(result, right)
                default: fatalError("Unexpected operator: \(ops)")
                }
            }
        }

        return addSubExpr.eraseToAnyParser()
    }()

    // MARK: - Bitwise Expressions

    // Bitwise expressions are now handled directly in numericValueExpression
}
