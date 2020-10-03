//
//  ContentView.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/09/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var command = ""
    @State private var outputText = [String]()
    @State private var parser = Parser()
    
    let formatter = SwiftUIFormatter()
    
    var body: some View {
        VStack {
            ScrollView(.vertical , showsIndicators: true) {
                ForEach(outputText, id: \.self) { text in
                    formatter.format(text).frame(maxWidth: .infinity, alignment: .leading)
                }
            }
                
            HStack {
                TextField("Command: ", text: $command)
                Button("OK", action: parseCommand)
            }
        }.frame(minWidth: 600, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
        .padding()
        .onAppear {
            setupWorld()
            outputText = [parser.welcome()]
        }
    }
    
    func parseCommand() {
        if command.count > 0 {
            outputText.append(parser.parse(command: command))
            command = ""
            // self.view.window?.makeFirstResponder(commandTextField)
            // outputTextView.scrollToEndOfDocument(nil)
        }
    }
    
    func setupWorld() {
        // Do any additional setup after loading the view.
        //parser.world = World()
        if let defaultWorldURL = Bundle.main.path(forResource: "defaultWorld", ofType: "json") {
            let url = URL(fileURLWithPath: defaultWorldURL)
            print("Loading default world.")
            parser.world = World.loadGame(from: url)
        }
        
        if parser.world == nil {
            print("Loading of default world failed. Initiazing default world.")
            parser.world = World()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
