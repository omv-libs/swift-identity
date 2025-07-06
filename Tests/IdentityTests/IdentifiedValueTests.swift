//
//  IdentifiedValueTests.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 7/6/25.
//

import Identity
import Testing

struct IdentifiedValueTests {
    struct TestStruct: IdentifiedValue, Equatable {
        var id: Int

        var name: String

        var double: Double
    }

    @Test func identifiableConformingToIdentifiedValue() {
        let testStruct = TestStruct(id: 7, name: "Arthur", double: 1.0)
        let testAsIdentifiedValue: any IdentifiedValue<Int, TestStruct> = testStruct

        #expect(testAsIdentifiedValue.id == testStruct.id)
        #expect(testAsIdentifiedValue.value == testStruct)
    }
}
