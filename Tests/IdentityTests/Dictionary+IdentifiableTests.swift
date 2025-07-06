//
//  Dictionary+IdentifiableTests.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 7/6/25.
//

import Identity
import Testing

struct Dictionary_IdentifiableTests {
    struct TestStruct: Identifiable, Equatable {
        var id: Int

        var name: String

        var double: Double
    }

    @Test("Verify basic contract of Dictionary initializer") func uniqueIdentifiableIDsWithValues() {
        let luggagePassword: [TestStruct] = [
            .init(id: 1, name: "One", double: 1.0),
            .init(id: 2, name: "Two", double: 2.0),
            .init(id: 3, name: "Three", double: 3.0),
            .init(id: 4, name: "Four", double: 4.0),
            .init(id: 5, name: "Five", double: 5.0)
        ]

        let expectedDictionary = [
            1: luggagePassword[0],
            2: luggagePassword[1],
            3: luggagePassword[2],
            4: luggagePassword[3],
            5: luggagePassword[4]
        ]

        let luggageDictionary = Dictionary(uniqueIdentifiableIDsWithValues: luggagePassword)

        #expect(luggageDictionary == expectedDictionary)
    }

    #if compiler(>=6.2)
    @Test("Calling with non-unique Identifiable IDs will crash") func nonUniqueIdentifiableIDsWithValues() async {
        await #expect(processExitsWith: .failure) {
            // As of Xcode 26 beta 2 declaring this outside the block crashes the compiler.
            let countToThree: [TestStruct] = [
                .init(id: 1, name: "One", double: 1.0),
                .init(id: 1, name: "One", double: 1.0),
                .init(id: 2, name: "Two", double: 2.0),
                .init(id: 2, name: "Two", double: 2.0),
                .init(id: 5, name: "Five", double: 5.0),
                .init(id: 3, name: "Three", double: 3.0)
            ]

            _ = Dictionary(uniqueIdentifiableIDsWithValues: countToThree)
        }
    }
    #endif

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChoosingOlder() {
        let countToThree: [TestStruct] = [
            .init(id: 1, name: "One", double: 1.0),
            .init(id: 1, name: "Uno", double: 1.0),
            .init(id: 2, name: "Two", double: 2.0),
            .init(id: 2, name: "Dos", double: 2.0),
            .init(id: 5, name: "Five", double: 5.0),
            .init(id: 3, name: "Three", double: 3.0)
        ]

        let expectedDictionary = [
            1: countToThree[0],
            2: countToThree[2],
            5: countToThree[4],
            3: countToThree[5]
        ]

        let dictionaryCount = Dictionary(countToThree) { old, _ in old }
        #expect(dictionaryCount == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChoosingNewer() {
        let countToThree: [TestStruct] = [
            .init(id: 1, name: "One", double: 1.0),
            .init(id: 1, name: "Uno", double: 1.0),
            .init(id: 2, name: "Two", double: 2.0),
            .init(id: 2, name: "Dos", double: 2.0),
            .init(id: 5, name: "Five", double: 5.0),
            .init(id: 3, name: "Three", double: 3.0)
        ]

        let expectedDictionary = [
            1: countToThree[1],
            2: countToThree[3],
            5: countToThree[4],
            3: countToThree[5]
        ]

        let dictionaryCount = Dictionary(countToThree) { _, new in new }
        #expect(dictionaryCount == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChangingOutput() {
        let countToThree: [TestStruct] = [
            .init(id: 1, name: "One", double: 1.0),
            .init(id: 1, name: "Uno", double: 11.0),
            .init(id: 2, name: "Two", double: 2.0),
            .init(id: 2, name: "Dos", double: 22.0),
            .init(id: 5, name: "Five", double: 5.0),
            .init(id: 3, name: "Three", double: 3.0)
        ]

        let expectedDictionary = [
            1: .init(id: 1, name: "One - Uno", double: 12.0),
            2: .init(id: 2, name: "Two - Dos", double: 24.0),
            5: countToThree[4],
            3: countToThree[5]
        ]

        let dictionaryCount = Dictionary(countToThree) { old, new in
            .init(id: old.id, name: "\(old.name) - \(new.name)", double: old.double + new.double)
        }
        #expect(dictionaryCount == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary grouping initializer")
    func collectionWithGroupingByID() {
        let countToThree: [TestStruct] = [
            .init(id: 1, name: "One", double: 1.0),
            .init(id: 1, name: "Uno", double: 11.0),
            .init(id: 2, name: "Two", double: 2.0),
            .init(id: 2, name: "Dos", double: 22.0),
            .init(id: 5, name: "Five", double: 5.0),
            .init(id: 3, name: "Three", double: 3.0)
        ]

        let expectedDictionary = [
            1: [countToThree[0], countToThree[1]],
            2: [countToThree[2], countToThree[3]],
            5: [countToThree[4]],
            3: [countToThree[5]]
        ]

        let dictionaryCount = Dictionary(groupingByID: countToThree)
        #expect(dictionaryCount == expectedDictionary)
    }
}
