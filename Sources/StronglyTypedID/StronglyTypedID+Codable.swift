//
//  StronglyTypedID+Codable.swift
//  
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

/**
 Default `Codable` implementation of a `StronglyTypedID` avoids using keyed encoding for `rawValue`. This makes it much
 easier to encode or decode to typical JSON backend data.
 */
public extension StronglyTypedID {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(RawValue.self))!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
