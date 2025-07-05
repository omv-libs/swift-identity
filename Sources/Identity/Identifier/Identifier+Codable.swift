//
//  Identifier+Codable.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

public extension Identifier {
    /// Default `Decodable` conformance.
    ///
    /// The default decoding of an ``Identifier`` type assumes the encoding is as in the matching default encoding
    /// implementation, where the raw value has been directly encoded with no coding key. This makes it easy to use
    /// ``Identifier`` types in the local decoded types for data received from non-typed environments, like most
    /// RESTful data replies.
    /// - Parameter decoder: The decoder used to decode the identifier. Occasionally it might be something other than an
    ///  instance of `JSONDecoder`.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(rawValue: container.decode(RawValue.self))!
    }
}

public extension Identifier {
    /// Default `Encodable` conformance.
    ///
    /// The default encoding of an ``Identifier`` type encodes the backing raw value directly, with no coding key. This
    /// allows for straight use of the encoded data on a receiving end where the identifier is not typed. Namely any
    /// RESTful communication with a JS-oriented backend (i.e. all of them).
    /// - Parameter encoder: The encoder used to encode the identifier. Occasionally it might be somethin gother than an
    /// instance of `JSONEncoder`.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
