//
//  IdentityMacrosTestPlugin.swift
//  Identifier
//
//  Created by Óscar Morales Vivó on 6/8/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct IdentityMacrosTestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FreestandingIdentifierMacro.self,
        AttachedIdentifierMacro.self
    ]
}
