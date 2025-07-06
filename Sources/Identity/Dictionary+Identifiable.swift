//
//  Dictionary+Identifiable.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/21/25.
//

import Foundation

public extension Dictionary {
    /// Copy a sequence of identifiable values into a dictionary, keyed by ID.
    ///
    /// This initializer parallels `Dictionary(uniqueKeysWithValues:)` which means if any `id` is repeated the call will
    /// crash.
    /// - Parameters:
    ///   - identifiables: A sequence of identifiable values to use for the new dictionary. Every `.id` in identifiables
    ///   must be unique.
    init<S>(
        uniqueIdentifiableIDsWithValues identifiables: S
    ) where S: Sequence, S.Element: Identifiable, S.Element.ID == Key, S.Element == Value {
        self.init(uniqueKeysWithValues: identifiables.map { ($0.id, $0) })
    }

    /// Creates a new dictionary from the identifiable values in the given sequence, using a combining closure to
    /// determine the value for any duplicate ids.
    ///
    /// You use this initializer to create a dictionary when you have a sequence of identifiable values that might have
    /// duplicate ids. As the dictionary is built, the initializer calls the combine closure with the current and new
    /// values for any duplicate ids. Pass a closure as combine that returns the value to use in the resulting
    /// dictionary: The closure can choose between the two values, combine them to produce a new value, or even throw an
    /// error.
    /// - Parameters:
    ///   - identifiables: A sequence of identifiable values to use for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate ids that are encountered. The closure
    ///   returns the desired value for the final dictionary.
    init<S>(
        _ identifiables: S,
        uniquingIDsWith combine: (Value, Value) throws -> Value
    ) rethrows where S: Sequence, S.Element: Identifiable, S.Element.ID == Key, S.Element == Value {
        try self.init(identifiables.map { ($0.id, $0) }, uniquingKeysWith: combine)
    }

    /// Creates a new dictionary whose keys are the id values of the collection's identifiables and whose values are
    /// arrays of the elements that had that identifier.
    ///
    /// The arrays in the “values” position of the new dictionary each contain at least one element, with the elements
    /// in the same order as the source sequence if more than one.
    /// - Parameters identifiables: A sequence of identifiables to group into a dictionary.
    init<S>(
        groupingByID identifiables: S
    ) where Value == [S.Element], S: Sequence, S.Element: Identifiable, S.Element.ID == Key {
        self.init(grouping: identifiables, by: \.id)
    }
}
