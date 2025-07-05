//
//  Identifier+UUID.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

public extension Identifier where RawValue == UUID {
    /// Simple factory method for `UUID`-based identifiers.
    ///
    /// For UUID-based ``Identifier`` types we either copy them around or generate unique ones on demand. This method
    /// takes care of the latter without having to actually deal with `UUID` itself. The explicit generation is also
    /// more readable.
    /// - Returns: A new unique value of the `UUID`-based identifier.
    static func unique() -> Self {
        .init(rawValue: UUID())!
    }
}

public extension Identifier where RawValue == UUID, Self: Encodable {
    /// Default `Encodable` implementation for `UUID`-backed ``Identifier`` types.
    ///
    /// Many REST APIs use `UUID` identifiers as `String` and usually expect a lowercase uuid string. Having this as the
    /// default encoding saves some additional work integrating `UUID`-backed ``Identifier`` types with REST data flows.
    /// - Parameter encoder: The encoder. Might occasionally be somthing other than `JSONEncoder`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.uuidString.lowercased())
    }
}
