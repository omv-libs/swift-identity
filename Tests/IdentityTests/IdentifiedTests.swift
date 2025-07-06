//
//  IdentifiedTests.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 7/4/25.
//

import Identity
import Testing

struct IdentifiedTests {
    struct TestStruct: Identifiable, Equatable {
        var id: Int

        var name: String

        var double: Double
    }

    @Test func asIdentifierInitializerFlow() {
        let testStruct = TestStruct(id: 7, name: "Arthur", double: 1.0)
        let identifiedTestStruct = AsIdentified(testStruct)

        #expect(identifiedTestStruct.id == testStruct.id)
        #expect(identifiedTestStruct.value == testStruct)
    }

    @Test func asIdentifierFlow() {
        let testStruct = TestStruct(id: 7, name: "Arthur", double: 1.0)
        let identifiedTestStruct = testStruct.asIdentified()

        #expect(identifiedTestStruct.id == testStruct.id)
        #expect(identifiedTestStruct.value == testStruct)
    }
}
