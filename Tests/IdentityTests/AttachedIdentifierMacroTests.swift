//
//  AttachedIdentifierMacroTests.swift
//  swift-identity
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

let testAttachedIdentifierMacro: [String: Macro.Type] = [
    "Identifier": AttachedIdentifierMacro.self
]
#endif

final class AttachedIdentifierMacroTests: XCTestCase {
    func testAttachedMacroSimpleUseExpansion() throws {
        #if canImport(IdentityMacros)
        assertMacroExpansion(
            """
            @Identifier<UUID>
            public struct ImageID: ResourceID, FileID, MediaID {}
            """,
            expandedSource: """
            public struct ImageID: ResourceID, FileID, MediaID {

                public init(rawValue: UUID) {
                    self.rawValue = rawValue
                }

                public typealias RawValue = UUID

                public var rawValue: UUID
            }

            extension ImageID: Identifier {
            }
            """,
            macros: testAttachedIdentifierMacro
        )
        #endif
    }

    func testAttachedMacroWithExtraAdoptions() throws {
        #if canImport(IdentityMacros)
        assertMacroExpansion(
            """
            @Identifier<UUID> struct ImageID: ResourceID, FileID, MediaID {}
            """,
            expandedSource: """
            struct ImageID: ResourceID, FileID, MediaID {

                init(rawValue: UUID) {
                    self.rawValue = rawValue
                }

                typealias RawValue = UUID

                var rawValue: UUID
            }

            extension ImageID: Identifier {
            }
            """,
            macros: testAttachedIdentifierMacro
        )
        #endif
    }
}

protocol SomeProtocol {}

protocol SomeOtherProtocol {}

// Type declared here to verify that attached macro actually works.
//
// Cannot be used in a local type.
struct TestStruct: Identifiable {
    @Identifier<UUID> struct TestID: SomeProtocol, SomeOtherProtocol {}

    var id: TestID
}
