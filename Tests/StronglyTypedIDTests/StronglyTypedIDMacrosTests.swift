//
//  StronglyTypedIDMacrosTests.swift
//
//
//  Created by Óscar Morales Vivó on 9/21/23.
//

import StronglyTypedID
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(StronglyTypedIDMacros)
@testable import StronglyTypedIDMacros

let testMacros: [String: Macro.Type] = [
    "StronglyTypedID": StronglyTypedIDMacro.self
]
#endif

protocol SomeProtocol {}

protocol SomeOtherProtocol {}

final class StronglyTypedIDMacroTests: XCTestCase {
    // Not quite a unit test but a check that the macro actually expands.
    func testBuildSimpleMacro() throws {
        struct TestStruct: Identifiable {
            // Declaration has to happen in a different scope than creation. Within a local `struct` works.
            #StronglyTypedID<UUID>("TestID")

            var id: TestID
        }

        // If this builds we're good.
        _ = TestStruct.TestID.unique()
    }

    // Not quite a unit test but a check that the macro actually expands.
    func testBuildMacroWithAdoptions() throws {
        struct TestStruct: Identifiable {
            // Declaration has to happen in a different scope than creation. Within a local `struct` works.
            #StronglyTypedID<UUID, SomeProtocol, SomeOtherProtocol>("TestID")

            var id: TestID
        }

        // If this builds we're good.
        _ = TestStruct.TestID.unique()
    }

    func testMacroWithNoExtraAdoption() throws {
        #if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID<UUID>(\"ID\")
            """,
            expandedSource: """
            struct ID: StronglyTypedID {
                var rawValue: UUID
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithExtraAdoptions() throws {
        #if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID<UUID, ResourceID, FileID, MediaID>(\"ImageID\")
            """,
            expandedSource: """
            struct ImageID: StronglyTypedID, ResourceID, FileID, MediaID {
                var rawValue: UUID
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
