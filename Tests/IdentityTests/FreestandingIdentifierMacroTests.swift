//
//  FreestandingIdentifierMacroTests.swift
//
//
//  Created by Óscar Morales Vivó on 9/21/23.
//

import Foundation
import Identity
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(IdentityMacros)
@testable import IdentityMacros

let testFreestandingMacros: [String: Macro.Type] = [
    "Identifier": FreestandingIdentifierMacro.self
]
#endif

final class FreestandingIdentifierMacroTests: XCTest {
    // Not quite a unit test but a check that the macro actually expands.
    func testBuildSimpleFreestandingMacro() throws {
        struct TestStruct: Identifiable {
            // Declaration has to happen in a different scope than creation. Within a local `struct` works.
            #Identifier<UUID>("TestID")

            var id: TestID
        }

        // If this builds we're good.
        _ = TestStruct.TestID.unique()
    }

    func testFreestandingMacroExpansion() throws {
        #if canImport(IdentityMacros)
        assertMacroExpansion(
            """
            #Identifier<UUID>(\"ID\")
            """,
            expandedSource: """
            struct ID: Identifier {
                var rawValue: UUID
            }
            """,
            macros: testFreestandingMacros
        )
        #endif
    }
}
