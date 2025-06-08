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
        let backingTypeName = extractTypeArgument(backingArgument)

        // Check if there's adoption arguments and return a simplified declaration if not.
        let firstAdoptionIndex = arguments.index(after: backingIndex)
        guard firstAdoptionIndex != arguments.endIndex else {
            // No adoptions, let's just return and build.
            let result =
                """
                struct \(typeName): StronglyTypedID {
                    var rawValue: \(backingTypeName)
                }
                """
            return ["\(raw: result)"]
        }

        // Grab the adoptions identifiers.
        let adoptions = arguments[firstAdoptionIndex...].map { element in
            extractTypeArgument(element.expression)
        }

        // Build up result.
        let result =
            """
            struct \(typeName): StronglyTypedID, \(adoptions.joined(separator: ", ")) {
                var rawValue: \(backingTypeName)
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

    private static func extractTypeArgument(_ argument: ExprSyntax) -> String {
        let memberAccess = argument.as(MemberAccessExprSyntax.self)
        let declName = argument.as(DeclReferenceExprSyntax.self)

        if let memberAccess, memberAccess.declName.baseName.text == "self" {
            if let name = memberAccess.base?.description {
                return name
            } else {
                preconditionFailure("No backing type specified")
            }
        } else if let declName {
            return declName.baseName.text
        } else {
            preconditionFailure("Arguments specifying types must be in the form of `T.self`")
        }
    }
}
