//
//  IdentifiedValue.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/22/25.
//

import Foundation

/// Pairing of a value with an identifier.
///
/// Sometimes you just want to add an identifier to a thing, often because you can't easily manage them otherwise. A
/// common example would be `Error`, which is famously not `Equatable` but where you often want to know if you are
/// dealing with an error that you have already dealt with or not.
public protocol IdentifiedValue<ID, Value>: Identifiable {
    associatedtype Value

    var value: Value { get }
}

public extension IdentifiedValue where Value: Identifiable, Value.ID == ID {
    /// Default conformance implementation of `Identifiable.id` for an ``IdentifiedValue`` whose value already conforms
    /// to `Identifiable`.
    ///
    /// Conformance to ``IdentifiedValue`` must be explicitly added to use this, but it may come in handy if you want
    /// to use generic logic based on ``IdentifiedValue`` with an existing `Identifiable` type.
    var id: ID { value.id }
}

public extension IdentifiedValue where Value == Self {
    /// Default conformance implementation of ``IdentifiedValue.value`` for a type that already conforms to
    /// `Identifiable`.
    ///
    /// Conformance to ``IdentifiedValue`` must be explicitly added to use this, but it may come in handy if you want
    /// to use generic logic based on ``IdentifiedValue`` with an existing `Identifiable` type.
    var value: Value { self }
}
