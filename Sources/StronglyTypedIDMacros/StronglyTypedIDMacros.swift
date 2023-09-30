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

// MARK: - Constants

private extension StronglyTypedIDMacro {
    static let backingParameterLabel = "backing"

    static let adoptsParameterLabel = "adopts"
}

// MARK: - DeclarationMacro Adoption

extension StronglyTypedIDMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard node.argumentList.count >= 2 else {
            // This should only happen due to a toolset error but still...
            context.diagnose(.init(node: node, message: Diagnostics.unexpectedParameterCount(node.argumentList.count)))
            return []
        }

        var diagnostics = [Diagnostic]()
        let argumentList = node.argumentList

        // Check first parameter (ID name).
        let typeNameIndex = argumentList.startIndex
        diagnostics.append(contentsOf: validateLabelLessIdentifierArgument(argument: argumentList[typeNameIndex]))

        // Check second parameter (backing type).
        let backingIndex = argumentList.index(after: argumentList.startIndex)
        let backingArgument = argumentList[backingIndex]
        diagnostics.append(contentsOf: validateLabeledIdentifierArgument(
            argument: backingArgument,
            expectedLabel: backingParameterLabel)
        )

        // Check if there's adoption arguments and return a simplified declaration if not.
        let firstAdoptionIndex = argumentList.index(after: backingIndex)
        let endIndex = argumentList.endIndex
        guard firstAdoptionIndex != endIndex else {
            // No adoptions, let's just return and build.
            if diagnostics.isEmpty {
                let result =
                    """
                    struct \(argumentList[typeNameIndex].expression): StronglyTypedID {
                        var rawValue: \(backingArgument.expression)
                    }
                    """
                return ["\(raw: result)"]
            } else {
                for diagnostic in diagnostics {
                    context.diagnose(diagnostic)
                }
                return []
            }
        }

        // Check adopts argument label
        let adoptsArgument = argumentList[firstAdoptionIndex]
        diagnostics.append(contentsOf: validateLabeledIdentifierArgument(
            argument: adoptsArgument,
            expectedLabel: adoptsParameterLabel)
        )

        // Validate any further adoption arguments, if any.
        for nextAdoptionArgument in argumentList[argumentList.index(after: firstAdoptionIndex)...] {
            diagnostics.append(contentsOf: validateLabelLessIdentifierArgument(argument: nextAdoptionArgument))
        }

        if diagnostics.isEmpty {
            // Build up adoptions.
            let adoptions = argumentList[firstAdoptionIndex...].map { element in
                "\(element.expression)"
            }

            // Build up result.
            let result =
                """
                struct \(argumentList[typeNameIndex].expression): StronglyTypedID, \(adoptions.joined(separator: ", ")) {
                    var rawValue: \(backingArgument.expression)
                }
                """
            return ["\(raw: result)"]
        } else {
            for diagnostic in diagnostics {
                context.diagnose(diagnostic)
            }
            return []
        }
    }
}

// MARK: - Diagnostics

extension StronglyTypedIDMacro {
    enum Diagnostics: DiagnosticMessage {
        case unexpectedParameterCount(Int)
        case badParameterLabel(badLabel: TokenSyntax?, expectedLabel: TokenSyntax?)
        case expressionIsNotTypeIdentifier(ExprSyntax)

        var message: String {
            switch self {
            case let .unexpectedParameterCount(count):
                "Unexpected parameter count, expected 2, got \(count)"
            case let .badParameterLabel(badLabel, expectedLabel):
                "Found \(badLabel.map { "\"\($0)\"" } ?? "nothing") as the parameter label, expected \(expectedLabel.map { "\"\($0)\"" } ?? "no label")."
            case let .expressionIsNotTypeIdentifier(expression):
                "Expression \(expression) is not a type identifier"
            }
        }

        var diagnosticID: SwiftDiagnostics.MessageID {
            let caseID = {
                switch self {
                case .unexpectedParameterCount:
                    return "unexpectedParameterCount"
                case .badParameterLabel:
                    return "badParameterLabel"
                case .expressionIsNotTypeIdentifier:
                    return "expressionIsNotTypeIdentifier"
                }
            }()
            return MessageID(domain: "StronglyTypedID", id: "\(Self.self).\(caseID)")
        }

        var severity: SwiftDiagnostics.DiagnosticSeverity {
            return .error
        }
    }

    private static func validateLabelLessIdentifierArgument(argument: LabeledExprSyntax) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()

        if let argumentLabel = argument.label, !argumentLabel.text.isEmpty {
            var fixedArgument = argument
            fixedArgument.label = nil
            fixedArgument.colon = nil
            diagnostics.append(.init(
                node: argumentLabel,
                message: Diagnostics.badParameterLabel(badLabel: argumentLabel, expectedLabel: nil),
                fixIt: .init(
                    message: FixIts.removeLabel,
                    changes: [FixIt.Change.replace(oldNode: Syntax(argument), newNode: Syntax(fixedArgument))]
                )
            ))
        }

        if !argument.expression.is(DeclReferenceExprSyntax.self) {
            diagnostics.append(.init(
                node: argument.expression,
                message: Diagnostics.expressionIsNotTypeIdentifier(argument.expression)
            ))
        }

        return diagnostics
    }

    private static func validateLabeledIdentifierArgument(
        argument: LabeledExprSyntax,
        expectedLabel: String
    ) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        let argumentExpression = argument.expression

        if let argumentLabel = argument.label {
            if argumentLabel.text != expectedLabel {
                // There is a label but it's wrong.
                var fixedArgument = argument
                fixedArgument.label?.tokenKind = .identifier(expectedLabel)
                diagnostics.append(.init(
                    node: argumentLabel,
                    message: Diagnostics.badParameterLabel(
                        badLabel: argumentLabel,
                        expectedLabel: TokenSyntax(stringLiteral: expectedLabel)
                    ),
                    fixIt: .init(
                        message: FixIts.updateLabel(
                            oldValue: argumentLabel.text,
                            newValue: expectedLabel
                        ),
                        changes: [FixIt.Change.replace(
                            oldNode: Syntax(argument),
                            newNode: Syntax(fixedArgument)
                        )]
                    )
                ))
            }
        } else {
            // There is no label and there should be one.
            var fixedArgument = argument
            fixedArgument.label = "\(raw: expectedLabel)"
            fixedArgument.colon = TokenSyntax(.colon, trailingTrivia: " ", presence: .present)
            diagnostics.append(.init(
                node: argumentExpression,
                message: Diagnostics.badParameterLabel(
                    badLabel: nil,
                    expectedLabel: TokenSyntax(stringLiteral: expectedLabel)
                ),
                fixIt: .init(
                    message: FixIts.addLabel(newValue: expectedLabel),
                    changes: [FixIt.Change.replace(oldNode: Syntax(argument), newNode: Syntax(fixedArgument))]
                )
            ))
        }

        if !argumentExpression.is(DeclReferenceExprSyntax.self) {
            diagnostics.append(.init(
                node: argumentExpression,
                message: Diagnostics.expressionIsNotTypeIdentifier(argumentExpression)
            ))
        }

        return diagnostics
    }}

// MARK: - FixIts

extension StronglyTypedIDMacro {
    enum FixIts: FixItMessage {
        case removeLabel
        case addLabel(newValue: String)
        case updateLabel(oldValue: String, newValue: String)

        var message: String {
            switch self {
            case .removeLabel:
                "Remove label"
            case let .addLabel(newValue):
                "Add the label \"\(newValue):\""
            case let .updateLabel(fromLabel, toLabel):
                "Update \"\(fromLabel)\" to \"\(toLabel)\""
            }
        }

        private static let diagnosticDomain = "com.oscarmv.StronglyTypedID"

        var fixItID: SwiftDiagnostics.MessageID {
            switch self {
            case .removeLabel:
                .init(domain: Self.diagnosticDomain, id: "removeLabel")
            case let .addLabel(newValue):
                .init(domain: Self.diagnosticDomain, id: "addLabel-\(newValue)")
            case let .updateLabel(_, newValue):
                .init(domain: Self.diagnosticDomain, id: "updateLabelTo-\(newValue)")
            }
        }
    }
}
