//
//  StronglyTypedIDMacrosTests.swift
//
//
//  Created by Óscar Morales Vivó on 9/21/23.
//

import MacroTesting
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import StronglyTypedID
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
            #StronglyTypedID("TestID", backing: UUID)

            var id: TestID
        }

        // If this builds we're good.
        _ = TestStruct.TestID.unique()
    }

    // Not quite a unit test but a check that the macro actually expands.
    func testBuildMacroWithAdoptions() throws {
        struct TestStruct: Identifiable {
            // Declaration has to happen in a different scope than creation. Within a local `struct` works.
            #StronglyTypedID("TestID", backing: UUID, adopts: SomeProtocol, SomeOtherProtocol)

            var id: TestID
        }

        // If this builds we're good.
        _ = TestStruct.TestID.unique()
    }

    func testMacroWithNoExtraAdoption() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID(\"ID\", backing: UUID)
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
            #StronglyTypedID(\"ImageID\", backing: UUID, adopts: ResourceID, FileID, MediaID)
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
