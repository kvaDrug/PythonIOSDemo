//
//  PythonRunnerProtocol.swift
//  PythonIOSDemo
//
//  Created by Uladzimir on 24.03.25.
//

import Foundation

protocol PythonRunnerProtocol {
    /// Runs python code string.
    func runSimpleString(_: String)
    
    /// Runs python code string, returning the string representation of the result.
    func run(_: String) -> String?
}

/// For previews and unit tests
final class MockPythonRunner: PythonRunnerProtocol {
    func runSimpleString(_ str: String) {
        print("mock python run:" + str)
    }
    func run(_ str: String) -> String? {
        return "mock python run:" + str
    }
}

extension PythonRunner: PythonRunnerProtocol {
}
