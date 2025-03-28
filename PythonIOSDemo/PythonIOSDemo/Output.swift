//
//  Output.swift
//  PythonIOSDemo
//
//  Created by Uladzimir Kelin on 28.03.25.
//

import Foundation

/// Identifiable output strings, for presentation in SwiftUI.
struct Output: Identifiable {
    var text: String
    var timestamp = Date()
    
    var id: Date { timestamp }
}
