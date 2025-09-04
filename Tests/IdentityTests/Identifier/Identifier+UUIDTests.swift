//
//  Identifier+UUIDTests.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 9/3/25.
//

import Foundation
import Identity
import Testing

struct IdentifierUUIDTests {
    #Identifier<UUID>("TestID")

    @Test("Checks that it converts to lowercase string")
    func convertToLowercaseString() {
        let uuid = UUID()

        let testID = TestID(rawValue: uuid)

        #expect(String(describing: testID) == uuid.uuidString.lowercased())
    }

    @Test("Checks that it encodes to lowercase string")
    func encodeToLowercaseString() throws {
        let uuid = UUID()

        let testID = TestID(rawValue: uuid)

        let data = try JSONEncoder().encode([testID])
        let jsonString = String(data: data, encoding: .utf8)

        #expect(jsonString == "[\"\(uuid.uuidString.lowercased())\"]")
    }
}
