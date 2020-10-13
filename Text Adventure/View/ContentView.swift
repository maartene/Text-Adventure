//
//  ContentView.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/09/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI
import WebKit

struct TextLine {
    static var lineCount: Int = 0
    let index: Int
    let text: String
    
    init(_ text: String) {
        self.index = Self.lineCount
        self.text = text
        Self.lineCount += 1
    }
}

struct ContentView: View {
    @State private var command = ""
    @State private var outputText = [TextLine]()
    @State private var parser = Parser()
    @State private var messageIndexToScrollTo = 0
    
    let formatter = SwiftUIFormatter()
    
    var body: some View {
        VStack {
            ScrollView(.vertical , showsIndicators: true) {
                ScrollViewReader { scrollProxy in
                    ForEach(outputText, id: \.index) { text in
                        formatter.format(text.text).frame(maxWidth: .infinity, alignment: Alignment.bottomLeading ).id(text.index)
                    }.onChange(of: self.messageIndexToScrollTo) { index in
                        withAnimation {
                            scrollProxy.scrollTo(index)
                        }
                    }
                }
            }
                
            HStack {
                TextField("Command: ", text: $command)
                Button("OK", action: parseCommand).keyboardShortcut(.defaultAction)
            }
        }
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
        .padding()
        .onAppear {
            setupWorld()
            outputText = [TextLine(parser.welcome())]
        }
    }
    
    func parseCommand() {
        if command.count > 0 {
            let newText = TextLine(parser.parse(command: command))
            outputText.append(newText)
            messageIndexToScrollTo = newText.index
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
