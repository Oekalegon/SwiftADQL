import Foundation
import Parsing

/// A collection of parsers for functions.
public extension ADQLParser {
    // MARK: - Functions

    /// A parser that parses a general set function.
    ///
    /// BNF:
    /// ```
    /// <general_set_function> ::=
    ///     <set_function_type> ( [<set_quantifier>] <value_expression>)
    /// ```
    static let generalSetFunction = Parse {
        OneOf {
            "AVG".map { SetFunction.average }
            "COUNT".map { SetFunction.count }
            "MAX".map { SetFunction.maximum }
            "MIN".map { SetFunction.minimum }
            "SUM".map { SetFunction.sum }
        }
        Whitespace()
        "("
        Whitespace()
        Optionally {
            OneOf {
                "DISTINCT".map { SetQuantifier.distinct }
                "ALL".map { SetQuantifier.all }
            }
            Whitespace()
        }
        // TODO: valueExpression
        Whitespace()
        ")"
    }.eraseToAnyParser()

    /// A parser that parses a set function specification.
    ///
    /// BNF:
    /// ```
    /// <set_function_specification> ::=
    ///     COUNT ( * )
    ///     <general_set_function>
    /// ```
    static let setFunctionSpecification = OneOf {
        Parse {
            "COUNT"
            Whitespace()
            "("
            Whitespace()
            "*"
            Whitespace()
            ")"
        }.map { SetFunctionSpecification.countAll }
        Parse {
            generalSetFunction
        }.map { SetFunctionSpecification.general($0, $1) } // TODO: Add Value Expression
    }
}
