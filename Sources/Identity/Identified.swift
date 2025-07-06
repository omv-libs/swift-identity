//
//  Identified.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/22/25.
//

import Foundation

/// An `id` and `value` pair.
///
/// Use this when you just need to throw an `id` on a thing.
public struct Identified<ID: Hashable, Value> {
    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }

    public var id: ID

    public var value: Value
}

extension Identified: Identifiable {}

extension Identified: IdentifiedValue {}

extension Identified: Equatable where Value: Equatable {}

extension Identified: Hashable where Value: Hashable {}

/// Simple typealias in case you need to use an already `Identifiable` type with `Identified` APIs.
public typealias AsIdentified<Value: Identifiable> = Identified<Value.ID, Value>

public extension AsIdentified where Value: Identifiable, ID == Value.ID {
    init(_ value: Value) {
        self.init(id: value.id, value: value)
    }
}

public extension Identifiable {
    func asIdentified() -> AsIdentified<Self> {
        .init(self)
    }
}
