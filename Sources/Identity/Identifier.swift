//
//  Identifier.swift
//
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

/// A protocol for easy declaration of identifier types based on typical primitive values.
///
/// The protocol groups all the expected ease of dev use behaviors so the ID can be used as dictionary keys,
/// encoded/decoded, and logged or reported out as just its raw value.
///
/// The protocol has been tested as working with `RawValue` as a `String`, `URL`, `UUID`, integer types and value types
/// that conform to `Hashable`, `Codable` and `Sendable`.
///
/// Floating point types should work as long as encoding/decoding doesn't lose precision, but that's not a potential
/// issue specific to this package.
public protocol Identifier: RawRepresentable, Codable, CustomStringConvertible, Hashable, Sendable
    where RawValue: Codable & Hashable & Sendable {}

// MARK: - Default `CustomStringConvertible` Conformance

public extension Identifier {
    /// Default `CustomStringConvertible` conformance.
    ///
    /// Strongly typed IDs use only their raw values for their conversion to strings. This makes them easy to use as
    /// values passed to logging and reporting methods.
    var description: String {
        String(describing: rawValue)
    }
}

// MARK: - Default `Comparable` Conformance

public extension Identifier where Self: Comparable, RawValue: Comparable {
    /// Default `Equatable` conformance.
    ///
    /// Most of the time IDs should not be treated as comparable as they specify uniqueness, not sort order. But if
    /// convenient or required this default implementation will take care of the matter. You still need to declare it
    /// on your specific ID type as `MyIDType: Comparable`.
    ///
    /// Swift warnings may happen if you do that outside of the module where you declare a given identifier type, i.e.
    /// its associated testing target. They should be safe to ignore as long as you control the type.
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
