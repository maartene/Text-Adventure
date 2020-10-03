//
//  Lexer.swift
//  Text Adventure
//
//  Created by Maarten Engels on 21/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import AppKit

struct Lexer {
    
    static let abbreviations = [
        "n": "GO NORTH",
        "s": "GO SOUTH",
        "e": "GO EAST",
        "w": "GO WEST",
        "l": "LOOK",
        "?": "HELP",
        "exit": "QUIT",
        "get": "TAKE",
        "i": "INVENTORY"
    ]
    
    static func lex(_ string: String) -> [String] {
        let subStrings = string.split(separator: " ")
        
        guard subStrings.count > 0 else {
            return [""]
        }
        
        if let abbreviation = abbreviations[String(subStrings[0])] {
            var expandedString = abbreviation
            for i in 1 ..< subStrings.count {
                expandedString += " " + subStrings[i]
            }
            print("Expanded string: \(string) to : \(expandedString)")
            return lex(expandedString)
        }
        
        var result = [String]()
        
        subStrings.forEach {
            result.append(String($0))
        }
        
        
        
        return result
    }
    
}
