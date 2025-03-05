import Foundation

public enum Identifier {
    case table(String)
    case column(String)
}

public struct Select {
    public var identifiers: [Identifier]
    public var from: Identifier
}
