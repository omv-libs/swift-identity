//
//  Dictionary+IdentifiedValueTests.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 7/6/25.
//

import Identity
import Testing

struct Dictionary_IdentifedValueTests {
    struct TestStruct: Equatable {
        var name: String

        var occupation: String

        var age: Int
    }

    @Test("Verify basic contract of Dictionary initializer") func uniqueIdentifiedIDsWithValues() {
        let americanArray: [Identified<Int, TestStruct>] = [
            .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
            .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
            .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
            .init(id: 4, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
            .init(id: 5, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
        ]

        let expectedDictionary = [
            1: americanArray[0].value,
            2: americanArray[1].value,
            3: americanArray[2].value,
            4: americanArray[3].value,
            5: americanArray[4].value
        ]

        let americanDictionary = Dictionary(uniqueIdentifiedIDsWithValues: americanArray)

        #expect(americanDictionary == expectedDictionary)
    }

    #if compiler(>=6.2)
    @Test("Calling with non-unique Identifiable IDs will crash") func nonUniqueIdentifiedIDsWithValues() async {
        await #expect(processExitsWith: .failure) {
            // As of Xcode 26 beta 2 declaring this outside the block crashes the compiler.
            let americanArray: [Identified<Int, TestStruct>] = [
                .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
                .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
                .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
                .init(id: 4, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
                .init(id: 3, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
            ]

            _ = Dictionary(uniqueIdentifiedIDsWithValues: americanArray)
        }
    }
    #endif

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChoosingOlder() {
        let americanArray: [Identified<Int, TestStruct>] = [
            .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
            .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
            .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
            .init(id: 2, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
            .init(id: 3, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
        ]

        let expectedDictionary = [
            1: americanArray[0].value,
            2: americanArray[1].value,
            3: americanArray[2].value
        ]

        let americanDictionary = Dictionary(americanArray, uniquingValueForIDWith: { old, _ in old })
        #expect(americanDictionary == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChoosingNewer() {
        let americanArray: [Identified<Int, TestStruct>] = [
            .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
            .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
            .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
            .init(id: 2, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
            .init(id: 3, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
        ]

        let expectedDictionary = [
            1: americanArray[0].value,
            2: americanArray[3].value,
            3: americanArray[4].value
        ]

        let americanDictionary = Dictionary(americanArray, uniquingValueForIDWith: { _, new in new })
        #expect(americanDictionary == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary initializer, choosing older element")
    func collectionWithDuplicateIDsChangingOutput() {
        let americanArray: [Identified<Int, TestStruct>] = [
            .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
            .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
            .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
            .init(id: 2, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
            .init(id: 3, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
        ]

        let expectedDictionary = [
            1: americanArray[0].value,
            2: .init(name: "Dave Stephen Eubanks-Tran", occupation: "Convention Beekeeper", age: 47),
            3: .init(name: "Ronald Will Davidson-Burress", occupation: "Unemployed Folder", age: 35)
        ]

        let americanDictionary = Dictionary(americanArray, uniquingValueForIDWith: { old, new in
            let oldNameComponents = old.name.components(separatedBy: " ")
            let newNameComponents = new.name.components(separatedBy: " ")
            let oldOccupationComponents = old.occupation.components(separatedBy: " ")
            let newOccupationComponents = new.occupation.components(separatedBy: " ")
            return .init(
                name: "\(oldNameComponents[0]) \(newNameComponents[0]) \(oldNameComponents[1])-\(newNameComponents[1])",
                occupation: "\(oldOccupationComponents[0]) \(newOccupationComponents[1])",
                age: (old.age + new.age) / 2
            )
        })
        #expect(americanDictionary == expectedDictionary)
    }

    @Test("Verify basic contract of Dictionary grouping initializer")
    func collectionWithGroupingByID() {
        let americanArray: [Identified<Int, TestStruct>] = [
            .init(id: 1, value: .init(name: "Laura Cunningham", occupation: "Systems Analyst", age: 35)),
            .init(id: 2, value: .init(name: "Dave Eubanks", occupation: "Convention Enthusiast", age: 65)),
            .init(id: 3, value: .init(name: "Ronald Davidson", occupation: "Unemployed", age: 33)),
            .init(id: 2, value: .init(name: "Stephen Tran", occupation: "Amateur Beekeeper", age: 30)),
            .init(id: 3, value: .init(name: "Will Burress", occupation: "Playfield Folder", age: 38))
        ]

        let expectedDictionary = [
            1: [americanArray[0].value],
            2: [americanArray[1].value, americanArray[3].value],
            3: [americanArray[2].value, americanArray[4].value]
        ]

        let americanDictionary = Dictionary(groupingValuesByID: americanArray)
        #expect(americanDictionary == expectedDictionary)
    }
}
