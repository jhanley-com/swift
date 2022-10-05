//
//  ContentView.swift
//  hex-gui
//
//  Created by John Hanley on 10/4/22.
//

import SwiftUI

struct ContentView: View {
    @State private var text = ""

    var body: some View {
        let myFont = Font
            .system(size:14)
            .monospaced()
            
        VStack {
            TextEditor(text: .constant(self.text))
                .font(myFont)
                .frame(minWidth: 700, minHeight: 500)

            HStack {
                // Open button.
                Button(action: {
                    let openURL = showOpenPanel()
                    if openURL != nil {
                        text = processFile(openURL)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Open")
                    }
                    .frame(width: 80)
                })
            }
            .padding(20)
        }
    }
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()

        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
