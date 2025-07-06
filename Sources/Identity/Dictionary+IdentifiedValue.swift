//
//  Dictionary+IdentifiedValue.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/28/25.
//

import Foundation

public extension Dictionary {
    /// Maps a sequence of identified values to a dictionary.
    ///
    /// This initializer parallels `Dictionary(uniqueKeysWithValues:)` which means if any `id` is repeated the call will
    /// crash.
    /// - Parameters:
    ///   - identifiedValues: A sequence of ``Identified`` values to use for the new dictionary. Every `.id` in
    ///   identifiedValues must be unique.
    init<S>(
        uniqueIdentifiedIDsWithValues identifiedValues: S
    ) where S: Sequence, S.Element: IdentifiedValue<Key, Value> {
        self.init(uniqueKeysWithValues: identifiedValues.map { ($0.id, $0.value) })
    }

    /// Creates a new dictionary by mapping the ``Identified`` value ids to their values in the given sequence, using a
    /// combining closure to determine the `value` to use for any duplicate ids.
    ///
    /// You use this initializer to create a dictionary when you have a sequence of ``Identified`` values that might
    /// have duplicate ids. As the dictionary is built, the initializer calls the combine closure with the current and
    /// new values for any duplicate ids. Pass a closure as combine that returns the value to use in the resulting
    /// dictionary: The closure can choose between the two values, combine them to produce a new value, or even throw an
    /// error.
    /// - Parameters:
    ///   - identifiedValues: A sequence of ``Identified`` values to map to the new dictionary.
    ///   - combine: A closure that is called with the `value` for any duplicate ids that are encountered. The closure
    ///   returns the desired value for the final dictionary.
    init<S>(
        _ identifiedValues: S,
        uniquingValueForIDWith combine: (Value, Value) throws -> Value
    ) rethrows where S: Sequence, S.Element: IdentifiedValue<Key, Value> {
        try self.init(identifiedValues.map { ($0.id, $0.value) }, uniquingKeysWith: combine)
    }
}

public extension Dictionary where Value: Collection {
    /// Creates a new dictionary whose keys are the id values of the collection's identifiables and whose values are
    /// arrays of the elements that had that identifier.
    ///
    /// The arrays in the “values” position of the new dictionary each contain at least one element, with the elements
    /// in the same order as the source sequence if more than one.
    /// - Parameters identifiedValues: A sequence of identifiables to group into a dictionary.
    init<S, E>(
        groupingValuesByID identifiedValues: S
    ) where S: Sequence, S.Element: IdentifiedValue<Key, E>, Key == S.Element.ID, Value == [E] {
        var iterator = identifiedValues.lazy.map(\.id).makeIterator()
        self.init(grouping: identifiedValues.lazy.map(\.value), by: { _ in iterator.next()! })
    }
}
