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
    public var id: ID

    public var value: Value
}

extension Identified: Identifiable {}

extension Identified: IdentifiedValue {}

public typealias AsIdentified<Value: Identifiable> = Identified<Value.ID, Value>
