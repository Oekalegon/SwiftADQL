import _StringProcessing
import Foundation
import Parsing

// Custom error type for parsing
public enum ParseError: Error {
    case expectedInput(String)
}

public actor ADQLParser {
    /// The default initializer for the ADQL parser
    public init() {}

    /*
     /// Parse an ADQL query
     ///
     /// - Parameter query: The ADQL query to parse
     /// - Returns: The parsed ADQL query
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
     */
}
