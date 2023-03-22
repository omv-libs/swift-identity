//
//  StronglyTypedID+Testing.swift
//  
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

/**
 Utilities for ease of testing with types that use `StronglyTypedID` types.
 */

/**
 We want to avoid accidental conversion from literals to strongly typed IDs, but this default implementation allows us
 to declare either `ExpressibleByStringLiteral` or `ExpressibleByStringInterpolation` conformance for a strongly typed
 ID type and have it automagically implemented. Useful for testing purposes where you may want to create dummy IDs with
 a known value.

 Not recommended to declare conformance outside of testing targets, especially with IDs where not every value for the
 `RawValue` type is a valid ID, since the implementation involves force unwrapping.
 */
public extension StronglyTypedID where Self: ExpressibleByStringLiteral, RawValue: ExpressibleByStringLiteral {
    init(stringLiteral: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: stringLiteral))!
    }
}

/**
 We want to avoid accidental conversion from literals to strongly typed IDs, but this default implementation allows us
 to declare `ExpressibleByIntegerLiteral` conformance and have it automagically implemented. Useful for testing purposes
 where you may want to create dummy IDs with a known value.

 Not recommended to declare conformance outside of testing targets, especially with IDs where not every value for the
 `RawValue` type is a valid ID, since the implementation involves force unwrapping.
 */
public extension StronglyTypedID where Self: ExpressibleByIntegerLiteral, RawValue: ExpressibleByIntegerLiteral {
    init(integerLiteral: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: integerLiteral))!
    }
}

/**
 We want to avoid accidental conversion from literals to strongly typed IDs, but this default implementation allows us
 to declare `ExpressibleByFloatLiteral` conformance and have it automagically implemented. Useful for testing purposes
 where you may want to create dummy IDs with a known value.

 Not recommended to declare conformance outside of testing targets, especially with IDs where not every value for the
 `RawValue` type is a valid ID, since the implementation involves force unwrapping.
 */
public extension StronglyTypedID where Self: ExpressibleByFloatLiteral, RawValue: ExpressibleByFloatLiteral {
    init(floatLiteral: RawValue.FloatLiteralType) {
        self.init(rawValue: RawValue(floatLiteral: floatLiteral))!
    }
}
