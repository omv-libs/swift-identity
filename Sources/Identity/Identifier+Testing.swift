//
//  Identifier+Testing.swift
//
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

/// Utilities for improved ease of testing when dealing with ``Identifier`` conforming types.

public extension Identifier where Self: ExpressibleByStringLiteral, RawValue: ExpressibleByStringLiteral {
    /// Default  `ExpressibleByStringLiteral` conformance implementation.
    ///
    /// We normally want to avoid accidental conversion from string literals to string-based ``Identifier`` types, but
    /// often this behavior is awfully convenient for the purpose of ease of writing tests where specific, hardcoded
    /// identifier values are desirable.
    ///
    /// You still need to explicitly declare `ExpressibleByStringLiteral` conformance but this implementation will take
    /// care of its implementation when you do so.
    ///
    /// - Warning: Conformance to `ExpressibleByStringLiteral` is not recommended outside of testing targets, especially
    /// for ``Identifier`` types where not every possible value of its `RawValue` type is a valid ID.
    /// - Parameter stringLiteral: A string literal used to initialize the identifier.
    init(stringLiteral: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: stringLiteral))!
    }
}

public extension Identifier where Self: ExpressibleByIntegerLiteral, RawValue: ExpressibleByIntegerLiteral {
    /// Default  `ExpressibleByIntegerLiteral` conformance implementation.
    ///
    /// We normally want to avoid accidental conversion from integer literals to integer-based ``Identifier`` types, but
    /// often this behavior is awfully convenient for the purpose of ease of writing tests where specific, hardcoded
    /// identifier values are desirable.
    ///
    /// You still need to explicitly declare `ExpressibleByIntegerLiteral` conformance but this implementation will take
    /// care of its implementation when you do so.
    ///
    /// - Warning: Conformance to `ExpressibleByIntegerLiteral` is not recommended outside of testing targets,
    /// especially for ``Identifier`` types where not every possible value of its `RawValue` type is a valid ID.
    /// - Parameter integerLiteral: An integer literal used to initialize the identifier.
    init(integerLiteral: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: integerLiteral))!
    }
}

/**
 We want to avoid accidental conversion from literals to ``Identifier`` types, but this default implementation allows us
 to declare `ExpressibleByFloatLiteral` conformance and have it automagically implemented. Useful for testing purposes
 where you may want to create dummy IDs with a known value.

 Not recommended to declare conformance outside of testing targets, especially with IDs where not every value for the
 `RawValue` type is a valid ID, since the implementation involves force unwrapping.
 */
public extension Identifier where Self: ExpressibleByFloatLiteral, RawValue: ExpressibleByFloatLiteral {
    /// Default  `ExpressibleByFloatLiteral` conformance implementation.
    ///
    /// We normally want to avoid accidental conversion from floating point literals to floating point-based
    /// ``Identifier`` types, but often this behavior is awfully convenient for the purpose of ease of writing tests
    /// where specific, hardcoded identifier values are desirable.
    ///
    /// You still need to explicitly declare `ExpressibleByFloatLiteral` conformance but this implementation will take
    /// care of its implementation when you do so.
    ///
    /// - Warning: Conformance to `ExpressibleByFloatLiteral` is not recommended outside of testing targets,
    /// especially for ``Identifier`` types where not every possible value of its `RawValue` type is a valid ID.
    /// - Parameter floatLiteral: A floating point literal used to initialize the identifier.
    init(floatLiteral: RawValue.FloatLiteralType) {
        self.init(rawValue: RawValue(floatLiteral: floatLiteral))!
    }
}
