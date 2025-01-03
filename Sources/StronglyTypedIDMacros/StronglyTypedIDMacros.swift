//
//  StronglyTypedIDMacros.swift
//
//
//  Created by Óscar Morales Vivó on 9/20/23.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct StronglyTypedIDMacrosTestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StronglyTypedIDMacro.self
    ]
}

public struct StronglyTypedIDMacro {}

// MARK: - DeclarationMacro Adoption

extension StronglyTypedIDMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = node.arguments
        guard arguments.count >= 2 else {
            // This should only happen due to toolset error or out of sync macro declaration so let's blow up.
            preconditionFailure("Unexpected argument count \(arguments.count). Toolset shouldn't have made it this far")
        }

        // Get the ID type name from the first parameter.
        let typeName = extractStringArgument(arguments[arguments.startIndex])

        // Grab the second parameter (backing type).
        let backingIndex = arguments.index(after: arguments.startIndex)
        let backingArgument = arguments[backingIndex].expression

        // Check if there's adoption arguments and return a simplified declaration if not.
        let firstAdoptionIndex = arguments.index(after: backingIndex)
        guard firstAdoptionIndex != arguments.endIndex else {
            // No adoptions, let's just return and build.
            let result =
                """
                struct \(typeName): StronglyTypedID {
                    var rawValue: \(backingArgument)
                }
                """
            return ["\(raw: result)"]
        }

        // Grab the adoptions identifiers.
        let adoptions = arguments[firstAdoptionIndex...].map { element in
            "\(element.expression)"
        }

        // Build up result.
        let result =
            """
            struct \(typeName): StronglyTypedID, \(adoptions.joined(separator: ", ")) {
                var rawValue: \(backingArgument)
            }
            """
        return ["\(raw: result)"]
    }

    private static func extractStringArgument(_ argument: LabeledExprSyntax) -> String {
        if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
            "\(stringLiteral.segments)"
        } else {
            // We're only supposed to call this with `StaticString` parameters, so if we're here it's toolset error or
            // out of sync macro declaration.
            preconditionFailure("Unexpected argument, toolset should only allow `StaticString` literals in")
        }
    }
}
