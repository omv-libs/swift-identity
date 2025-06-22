//
//  Identifier+Comparable.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/21/25.
//

import Foundation

public extension Identifier where Self: Comparable, RawValue: Comparable {
    /// Default `Comparable` conformance.
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
