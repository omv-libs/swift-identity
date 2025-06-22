//
//  AttachedIdentifiableMacroTests.swift
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

let testAttachedIdentifiableMacro: [String: Macro.Type] = [
    "Identifiable": AttachedIdentifiableMacro.self
]
#endif

final class AttachedIdentifiableMacroTests: XCTestCase {
    func testAttachedMacroSimpleUseExpansion() throws {
        #if canImport(IdentityMacros)
        assertMacroExpansion(
            """
            @Identifiable<UUID>
            public struct TestStruct {
                private var value: Int
            }
            """,
            expandedSource: """
            public struct TestStruct {
                private var value: Int

                public struct ID: Identifier {
                    init(rawValue: UUID) {
                        self.rawValue = rawValue
                    }

                    var rawValue: UUID
                }

                public var id: ID
            }

            extension TestStruct: Identifiable {
            }
            """,
            macros: testAttachedIdentifiableMacro
        )
        #endif
    }

    func testAttachedMacroWithExtraAdoptions() throws {
        #if canImport(IdentityMacros)
        assertMacroExpansion(
            """
            @Identifiable<UUID>
            public struct TestStruct: Resource, Media {
                private var value: Int
            }
            """,
            expandedSource: """
            public struct TestStruct: Resource, Media {
                private var value: Int

                public struct ID: Identifier {
                    init(rawValue: UUID) {
                        self.rawValue = rawValue
                    }

                    var rawValue: UUID
                }

                public var id: ID
            }

            extension TestStruct: Identifiable {
            }
            """,
            macros: testAttachedIdentifiableMacro
        )
        #endif
    }
}

// Type declared here to verify that attached macro actually works, including embedded in another type.
//
// Compiler must be making an exception for extensions expanded from a macro as they are normally only allowed on global
// scope.
enum Namespace {
    @Identifiable<UUID>
    struct TestStruct {
        var value: Int
    }
}
