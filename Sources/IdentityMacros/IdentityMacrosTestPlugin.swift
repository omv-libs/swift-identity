//
//  IdentityMacrosTestPlugin.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/8/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct IdentityMacrosTestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AttachedIdentifiableMacro.self,
        AttachedIdentifierMacro.self,
        FreestandingIdentifierMacro.self
    ]
}

extension DeclModifierSyntax {
    var isNeededAccessLevelModifier: Bool {
        switch name.tokenKind {
        case .keyword(.public): true
        default: false
        }
    }
}
