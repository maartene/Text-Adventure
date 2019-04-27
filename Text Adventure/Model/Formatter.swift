//
//  Formatter.swift
//  Text Adventure
//
//  Created by Maarten Engels on 20/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import AppKit

struct Formatter {
    
    var defaultColor: NSColor
    var fontSize: Double
    var defaultFont: NSFont
    
    init(defaultColor: NSColor = NSColor.white, fontSize: Double = 12.0, defaultFontName: String = "Helvetica") {
        self.defaultColor = defaultColor
        self.fontSize = fontSize
        self.defaultFont = NSFont(name: defaultFontName, size: CGFloat(fontSize)) ?? NSFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    init(defaultAttributes: [NSAttributedString.Key: Any]) {
        if let defaultColor = defaultAttributes[NSAttributedString.Key.foregroundColor] as? NSColor {
            self.defaultColor = defaultColor
        } else {
            self.defaultColor = NSColor.white
        }
        
        if let font = defaultAttributes[NSAttributedString.Key.font] as? NSFont {
            self.fontSize = Double(font.pointSize)
            self.defaultFont = font
        } else {
            self.fontSize = Double(NSFont.systemFontSize)
            self.defaultFont = NSFont.systemFont(ofSize: CGFloat(fontSize))
        }
    }
    
    func format(text: String) -> NSAttributedString {
        var result = "<div style=\"font-family: Helvetica; font-size: 16.0; color: #dddddd;\">" + text + "</div>"
        result = result.replacingOccurrences(of: "\n", with: "<br>")
        result = result.replacingOccurrences(of: "<EXIT>", with: "<span style=\"color: green;\">")
        result = result.replacingOccurrences(of: "</EXIT>", with: "</span>")
        result = result.replacingOccurrences(of: "<ITEM>", with: "<span style=\"color: orange;\">")
        result = result.replacingOccurrences(of: "</ITEM>", with: "</span>")
        result = result.replacingOccurrences(of: "<ACTION>", with: "<span style=\"color: yellow;\">")
        result = result.replacingOccurrences(of: "</ACTION>", with: "</span>")
        result = result.replacingOccurrences(of: "<WARNING>", with: "<span style=\"color: orange;\">")
        result = result.replacingOccurrences(of: "</WARNING>", with: "</span>")
        result = result.replacingOccurrences(of: "<DEBUG>", with: "<span style=\"color: purple;\">")
        result = result.replacingOccurrences(of: "</DEBUG>", with: "</span>")
        
        let data = result.data(using: .utf8)!
        
        return NSAttributedString(html: data, documentAttributes: nil) ?? NSAttributedString(string: text)
    }
    
    
}
