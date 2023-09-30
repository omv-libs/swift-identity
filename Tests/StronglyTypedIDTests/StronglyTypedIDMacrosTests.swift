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
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(StronglyTypedIDMacros)
@testable import StronglyTypedIDMacros

let testMacros: [String: Macro.Type] = [
    "StronglyTypedID": StronglyTypedIDMacro.self
]
#endif

final class StronglyTypedIDMacroTests: XCTestCase {
    func testMacroWithNoExtraAdoption() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID(ID, backing: UUID)
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
            #StronglyTypedID(ImageID, backing: UUID, adopts: ResourceID, FileID, MediaID)
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

    func testDiagnosticForWrongNumberOfParameters() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID(ImageID)
            """,
            expandedSource: "",
            diagnostics: [DiagnosticSpec(
                id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.unexpectedParameterCount"),
                message: "Unexpected parameter count, expected 2, got 1",
                line: 1,
                column: 1,
                severity: .error,
                highlight: "#StronglyTypedID(ImageID)",
                notes: [],
                fixIts: []
            )],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testDiagnosticForBadParameterLabels() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID(type: ImageID, potato: UUID, octopus: ResourceID, pie: MediaID)
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found \"type\" as the parameter label, expected no label.",
                    line: 1,
                    column: 18,
                    severity: .error,
                    highlight: "type",
                    notes: [],
                    fixIts: [.init(message: "Remove label")]
                ),
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found \"potato\" as the parameter label, expected \"backing\".",
                    line: 1,
                    column: 33,
                    severity: .error,
                    highlight: "potato",
                    notes: [],
                    fixIts: [.init(message: "Update \"potato\" to \"backing\"")]
                ),
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found \"octopus\" as the parameter label, expected \"adopts\".",
                    line: 1,
                    column: 47,
                    severity: .error,
                    highlight: "octopus",
                    notes: [],
                    fixIts: [.init(message: "Update \"octopus\" to \"adopts\"")]
                ),
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found \"pie\" as the parameter label, expected no label.",
                    line: 1,
                    column: 68,
                    severity: .error,
                    highlight: "pie",
                    notes: [],
                    fixIts: [.init(message: "Remove label")]
                )
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testDiagnosticForMissingParameterLabels() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacroExpansion(
            """
            #StronglyTypedID(ImageID, UUID, ResourceID, MediaID)
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found nothing as the parameter label, expected \"backing\".",
                    line: 1,
                    column: 27,
                    severity: .error,
                    highlight: "UUID",
                    notes: [],
                    fixIts: [.init(message: "Add the label \"backing:\"")]
                ),
                DiagnosticSpec(
                    id: SwiftDiagnostics.MessageID(domain: "StronglyTypedID", id: "Diagnostics.badParameterLabel"),
                    message: "Found nothing as the parameter label, expected \"adopts\".",
                    line: 1,
                    column: 33,
                    severity: .error,
                    highlight: "ResourceID",
                    notes: [],
                    fixIts: [.init(message: "Add the label \"adopts:\"")]
                ),
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testFixItsForBadParameterLabels() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacro(
            testMacros,
            applyFixIts: true
        ) {
            "#StronglyTypedID(ImageID, potato: UUID, octopus: ResourceID, pie: MediaID)"
        } matches: {
            "#StronglyTypedID(ImageID, backing: UUID, adopts: ResourceID, MediaID)"
        }
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testFixItsForMissingParameterLabels() throws {
#if canImport(StronglyTypedIDMacros)
        assertMacro(
            testMacros,
            applyFixIts: true
        ) {
            "#StronglyTypedID(ImageID, UUID, ResourceID, MediaID)"
        } matches: {
            "#StronglyTypedID(ImageID, backing: UUID, adopts: ResourceID, MediaID)"
        }
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
