//
//  ViewController.swift
//  Text Adventure
//
//  Created by Maarten Engels on 19/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var commandEnterButton: NSButton!
    @IBOutlet weak var commandTextField: NSTextField!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var outputScrollView: NSScrollView!
    
    var parser = Parser()
    var formatter: Formatter!
    var world = World()
    
    @IBAction func onCommandEnterButtonClicked(_ sender: Any) {
        if commandTextField.stringValue.count > 0 {
            let formattedString = formatter.format(text: parser.parse(command: commandTextField.stringValue))
            outputTextView.textStorage?.append(formattedString)
            commandTextField.stringValue = ""
            self.view.window?.makeFirstResponder(commandTextField)
            outputTextView.scrollToEndOfDocument(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        parser.world = world
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidAppear() {
        self.view.window?.delegate = self
        self.view.window?.makeFirstResponder(commandTextField)
        
        formatter = Formatter(defaultAttributes: outputTextView.typingAttributes)
        formatter.defaultFont = NSFont(name: "Helvetica", size: 16.0)!
        formatter.defaultColor = NSColor.white
        outputTextView.textStorage?.append(formatter.format(text: parser.welcome()))
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
    
}

