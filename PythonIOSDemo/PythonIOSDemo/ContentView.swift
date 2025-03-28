//
//  ContentView.swift
//  PythonIOSDemo
//
//  Created by Uladzimir Kelin on 24.03.25.
//

import SwiftUI

/// The view will show the interpreter UI:
/// - prompt input and "Run" button to run a command.
/// - log of recent inputs and outputs.
struct ContentView: View {
    let runner: PythonRunnerProtocol
    
    @State var prompt: String = ""
    
    @State var outputs = [Output]()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            ForEach(outputs, id: \.timestamp) { output in
                Text(output.text)
                    .foregroundColor(Color(white: 0.2))
            }
            TextField("Input command:", text: $prompt)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            HStack {
                Spacer()
                Button("Run", action: run)
                    .font(.headline)
            }
        }
        .padding()
    }
    
    func run() {
        // Preprocess prompt
        prompt = prompt
        // String input support
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "‘", with: "'")
        
        var newOutputs = [Output(text: ">>> " + prompt)]
        if let runResult = runner.run(prompt),
           // Ingore actions without output, like assignments
           runResult != "None" {
            newOutputs.append(Output(text: runResult))
        }
        outputs = (outputs + newOutputs).suffix(20)
        prompt = ""
    }
}

#Preview {
    let previewOutputs = [
        Output(text: "3", timestamp: Date() + 0),
        Output(text: "5", timestamp: Date() + 1),
        Output(text: "Hello world!", timestamp: Date() + 0),
    ]
    ContentView(runner: MockPythonRunner(), prompt: "print()", outputs: previewOutputs)
}
