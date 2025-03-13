import Parsing
import XCTest

@testable import SwiftADQL

final class ValueExpressionTests: XCTestCase {
    func testTermParsing() throws {
        do {
            let input = "1 * 2 * 3"
            let result = try ADQLParser.term.parse(input)
            print("RESULT:\(result)")
            XCTAssertEqual(
                result,
                Term.multiplication(
                    Term.multiplication(
                        Term.factor(
                            Factor.expression(sign: 1.0, value: .unsignedLiteral(UnsignedLiteral.int(1)))
                        ),
                        Factor.expression(sign: 1.0, value: .unsignedLiteral(UnsignedLiteral.int(2)))
                    ),
                    Factor.expression(sign: 1.0, value: .unsignedLiteral(UnsignedLiteral.int(3)))
                )
            )
        }
        do {
            let input = "1 * column * -3"
            let result = try ADQLParser.term.parse(input)
            print("RESULT:\(result)")
            XCTAssertEqual(
                result,
                Term.multiplication(
                    Term.multiplication(
                        Term.factor(
                            Factor.expression(sign: 1.0, value: .unsignedLiteral(UnsignedLiteral.int(1)))
                        ),
                        Factor.expression(
                            sign: 1.0,
                            value: .columnReference(
                                ColumnReference(tableName: nil, columnName: Identifier.regular("column"))
                            )
                        )
                    ),
                    Factor.expression(sign: -1.0, value: .unsignedLiteral(UnsignedLiteral.int(3)))
                )
            )
        }
    }

    func testNumericValueExpressionBasic() throws {
        // Test simple term
        do {
            let input = "42"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Basic term: \(result)")

            let expectedFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let expectedTerm = Term.factor(expectedFactor)
            XCTAssertEqual(result, NumericValueExpression.term(expectedTerm))
        }

        // Test column reference
        do {
            let input = "column_name"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Column term: \(result)")

            let columnRef = ColumnReference(tableName: nil, columnName: .regular("column_name"))
            let expectedFactor = Factor.expression(sign: 1.0, value: .columnReference(columnRef))
            let expectedTerm = Term.factor(expectedFactor)
            XCTAssertEqual(result, NumericValueExpression.term(expectedTerm))
        }
    }

    func testNumericValueExpressionBitwise() throws {
        // Test bitwise NOT
        do {
            let input = "~42"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Bitwise NOT: \(result)")

            let factor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let term = Term.factor(factor)
            let expr = NumericValueExpression.term(term)
            XCTAssertEqual(result, NumericValueExpression.bitwiseNot(expr))
        }

        // Test bitwise AND
        do {
            let input = "42 & 7"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Bitwise AND: \(result)")

            let leftFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let leftTerm = Term.factor(leftFactor)
            let leftExpr = NumericValueExpression.term(leftTerm)

            let rightFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(7)))
            let rightTerm = Term.factor(rightFactor)
            let rightExpr = NumericValueExpression.term(rightTerm)

            XCTAssertEqual(result, NumericValueExpression.bitwiseAnd(leftExpr, rightExpr))
        }

        // Test bitwise OR
        do {
            let input = "42 | 7"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Bitwise OR: \(result)")

            let leftFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let leftTerm = Term.factor(leftFactor)
            let leftExpr = NumericValueExpression.term(leftTerm)

            let rightFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(7)))
            let rightTerm = Term.factor(rightFactor)
            let rightExpr = NumericValueExpression.term(rightTerm)

            XCTAssertEqual(result, NumericValueExpression.bitwiseOr(leftExpr, rightExpr))
        }

        // Test bitwise XOR
        do {
            let input = "42 ^ 7"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Bitwise XOR: \(result)")

            let leftFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let leftTerm = Term.factor(leftFactor)
            let leftExpr = NumericValueExpression.term(leftTerm)

            let rightFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(7)))
            let rightTerm = Term.factor(rightFactor)
            let rightExpr = NumericValueExpression.term(rightTerm)

            XCTAssertEqual(result, NumericValueExpression.bitwiseXor(leftExpr, rightExpr))
        }
    }

    func testNumericValueExpressionArithmetic() throws {
        // Test addition
        do {
            let input = "5 + 3"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Addition: \(result)")

            let leftFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(5)))
            let leftTerm = Term.factor(leftFactor)
            let leftExpr = NumericValueExpression.term(leftTerm)

            let rightFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(3)))
            let rightTerm = Term.factor(rightFactor)
            let rightExpr = NumericValueExpression.term(rightTerm)

            XCTAssertEqual(result, NumericValueExpression.addition(leftExpr, rightExpr))
        }

        // Test subtraction
        do {
            let input = "5 - 3"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Subtraction: \(result)")

            let leftFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(5)))
            let leftTerm = Term.factor(leftFactor)
            let leftExpr = NumericValueExpression.term(leftTerm)

            let rightFactor = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(3)))
            let rightTerm = Term.factor(rightFactor)
            let rightExpr = NumericValueExpression.term(rightTerm)

            XCTAssertEqual(result, NumericValueExpression.subtraction(leftExpr, rightExpr))
        }
    }

    func testNumericValueExpressionComplex() throws {
        // Test complex expression with multiple operations
        do {
            let input = "5 + 3 * 2"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Complex expression: \(result)")

            // Build the expected AST for 5 + (3 * 2)
            let factor5 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(5)))
            let term5 = Term.factor(factor5)
            let expr5 = NumericValueExpression.term(term5)

            let factor3 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(3)))
            let factor2 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(2)))
            let mult = Term.multiplication(Term.factor(factor3), factor2)
            let exprMult = NumericValueExpression.term(mult)

            XCTAssertEqual(result, NumericValueExpression.addition(expr5, exprMult))
        }

        do {
            let input = "~42 & 10"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Mixed bitwise operations: \(result)")

            // Create the AST for ~42 (NOT applied to 42)
            let factor42 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(42)))
            let term42 = Term.factor(factor42)
            let expr42 = NumericValueExpression.term(term42)
            let not42 = NumericValueExpression.bitwiseNot(expr42)

            // Create the AST for 10
            let factor10 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(10)))
            let term10 = Term.factor(factor10)
            let expr10 = NumericValueExpression.term(term10)

            // Create the final AST for ~42 & 10 with correct precedence: (~42) & 10
            XCTAssertEqual(result, NumericValueExpression.bitwiseAnd(not42, expr10))
        }
        do {
            let input = "(5 + 3) * 2"
            let result = try ADQLParser.numericValueExpression.parse(input)
            print("Complex expression: \(result)")

            let factor5 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(5)))
            let term5 = Term.factor(factor5)
            let expr5 = NumericValueExpression.term(term5)

            let factor3 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(3)))
            let term3 = Term.factor(factor3)
            let expr3 = NumericValueExpression.term(term3)

            let factor2 = Factor.expression(sign: 1.0, value: .unsignedLiteral(.int(2)))
            let term2 = Term.factor(factor2)

            // In ValueExpressionPrimary the parenthesized expr becomes a primary
            let addExpr = NumericValueExpression.addition(expr5, expr3)
            let addPrimary = ValueExpressionPrimary.expression(.numericValueExpression(addExpr))

            // Then this becomes a factor with sign 1.0
            let addFactor = Factor.expression(sign: 1.0, value: addPrimary)

            // Then this gets multiplied by 2
            let mult = Term.multiplication(Term.factor(addFactor), factor2)
            let exprMult = NumericValueExpression.term(mult)

            XCTAssertEqual(result, exprMult)
        }
    }
}
