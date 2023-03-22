//
//  StronglyTypedID+UUID.swift
//  
//
//  Created by Óscar Morales Vivó on 3/21/23.
//

import Foundation

public extension StronglyTypedID where RawValue == UUID {
    /**
     Simple factory method for `UUID`-based strongly typed IDs.

     For UUID-based Strongly typed IDs we can easily generate unique ones, this makes the job simpler. The use of a
     static method makes the use intention more explicit.
     - Returns: A new unique value of the `UUID`-based strongly typed ID.
     */
    static func unique() -> Self {
        return .init(rawValue: UUID())!
    }
}
