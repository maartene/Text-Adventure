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
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<EXIT>", with: "<span style=\"color: green;\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</EXIT>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<ITEM>", with: "<span style=\"color: orange;\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</ITEM>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<ACTION>", with: "<span style=\"color: yellow;\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</ACTION>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<WARNING>", with: "<span style=\"color: orange;\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</WARNING>", with: "</span>")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "<DEBUG>", with: "<span style=\"color: purple;\">")
        inlineStyledText = inlineStyledText.replacingOccurrences(of: "</DEBUG>", with: "</span>")
        
        let htmlText = templateHTML.replacingOccurrences(of: "[[RESULT]]", with: inlineStyledText)
        
        let data = htmlText.data(using: .utf8)!
        
        return NSAttributedString(html: data, documentAttributes: nil) ?? NSAttributedString(string: text)
    }
    
    
}
