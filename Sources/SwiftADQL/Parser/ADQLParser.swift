import Foundation
import Parsing

public actor ADQLParser {
    private static let firstChar = First<Substring>().filter { $0.isLetter || $0 == "_" }
    private static let restChars = Prefix<Substring> { $0.isLetter || $0 == "_" || $0.isNumber || $0 == "." }

    private static let identifier = Parse {
        firstChar
        restChars
    }.map { String($0) + String($1) }

    private static let columnIdentifier = Parse {
        identifier
    }.map { Identifier.column($0) }

    private static let tableIdentifier = Parse {
        identifier
    }.map { Identifier.table($0) }

    private static let select = Parse {
        "SELECT"
        Whitespace()
        Many {
            columnIdentifier
            Optionally {
                ","
                Whitespace()
            }
        }
        Whitespace()
        "FROM"
        Whitespace()
        tableIdentifier
    }
    .map { (columns: [(Identifier, ()?)], table: Identifier) in
        let identifiers = columns.map(\.0)
        return Select(identifiers: identifiers, from: table)
    }

    public init() {}

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
