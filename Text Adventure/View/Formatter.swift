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
    
    let templateHTML: String
    
    init() {
        if let templatePath = Bundle.main.path(forResource: "template", ofType: "html") {
            print("Loading html template from: \(templatePath).")
            let url = URL(fileURLWithPath: templatePath)
        
            do {
                let data = try Data(contentsOf: url)
                templateHTML = String(data: data, encoding: .utf8) ?? ""
                // print(templateHTML)
            } catch {
                print(error)
                templateHTML = ""
            }
        } else {
            templateHTML = ""
        }
    }
    
    func format(text: String) -> NSAttributedString {
        var inlineStyledText = text
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "\n", with: "<br>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<EXIT>", with: "<span class=\"exit\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</EXIT>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<ITEM>", with: "<span class=\"item\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</ITEM>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<ACTION>", with: "<span class=\"action\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</ACTION>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<WARNING>", with: "<span class=\"warning\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</WARNING>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<DEBUG>", with: "<span class=\"debug\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</DEBUG>", with: "</span>")
        
        print(inlineStyledText)
        
        let htmlText = templateHTML.replacingOccurrences(of: "[[RESULT]]", with: inlineStyledText)
        
        let data = htmlText.data(using: .utf8)!
        
        return NSAttributedString(html: data, documentAttributes: nil) ?? NSAttributedString(string: text)
    }
    
    
}
