//
//  PythonIOSDemoApp.swift
//  PythonIOSDemo
//
//  Created by Vladimir Kelin on 26.03.25.
//

import SwiftUI

@main
struct PythonIOSDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(runner: PythonRunner.shared())
                .onAppear {
                    PythonRunner.shared().helloWorld()
                    PythonRunner.shared().globalVarDemo()
                }
        }
    }
}

