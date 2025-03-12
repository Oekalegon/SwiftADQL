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
}
