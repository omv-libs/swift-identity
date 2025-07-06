//
//  Identifier.swift
//  swift-identity
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
    /// Identifier conforming types use only their raw values for their conversion to strings. This makes them easy to
    /// use as values passed to logging and reporting methods.
    var description: String {
        String(describing: rawValue)
    }
}
