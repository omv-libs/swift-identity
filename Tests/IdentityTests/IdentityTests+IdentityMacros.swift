//
//  IdentityTests+IdentityMacros.swift
//  swift-identity
//
//  Created by Óscar Morales Vivó on 6/21/25.
//

var canRunMacroTests: Bool {
    #if canImport(IdentityMacros)
    return true
    #else
    return false
    #endif
}
