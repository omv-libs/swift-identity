//
//  Identifier+Macros.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/16/25.
//

import Foundation

/// A macro that declares an `Identifier` type.
///
/// Use this macro when you just need an ID that has no further sophistication beyond what this package offers.
/// - Parameters:
///  - Backing: The type that backs the ``Identifier`` type, its `RawValue`.
///  - name: The name of the new ``Identifier`` type. Must be a valid type identifier at compile time.
@freestanding(declaration, names: arbitrary)
public macro Identifier<Backing: Hashable & Codable & Sendable>(_ name: StaticString) = #externalMacro(
    module: "IdentityMacros",
    type: "FreestandingIdentifierMacro"
)

/// A macro that adds conformance to `Identifier` to its attachee.
///
/// The macro also deals with conformance of `RawRepresentable` by adding the appropiate `typealias`, stored property
/// and initializer. The initializer is _not_ failable.
///
/// You can use this macro for any ID types where you may need to implement some of the methods yourself or otherwise
/// extend their functionality, add stored properties and/or add nontrivial conformances.
/// - Parameter Backing: The type that backs the ``Identifier`` type, its `RawValue`.
@attached(member, names: named(RawValue), named(rawValue), named(init(rawValue:)))
@attached(extension, conformances: Identifier)
public macro Identifier<Backing: Hashable & Codable & Sendable>() = #externalMacro(
    module: "IdentityMacros",
    type: "AttachedIdentifierMacro"
)

/// A macro that adds conformance to `Identifiable` with a new `Identifier` type to its attachee.
///
/// The macro will declare an `ID` type conforming to ``Identifier`` and backed by the type used to call the macro, as
/// well as the corresponding `id` property.
///
/// This simplifies the typical case of an embedded ID type for a model type.
/// - Parameter Backing: The type that backs the ``Identifier`` type, its `RawValue`.
@attached(member, names: named(ID), named(id))
@attached(extension, conformances: Identifiable)
public macro Identifiable<Backing: Hashable & Codable & Sendable>() = #externalMacro(
    module: "IdentityMacros",
    type: "AttachedIdentifiableMacro"
)
