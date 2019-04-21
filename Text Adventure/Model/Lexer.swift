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
        "?": "HELP"
    ]
    
    static func lex(_ string: String) -> [String] {
        let subStrings = string.split(separator: " ")
        
        if let abbreviation = abbreviations[String(subStrings[0])] {
            return lex(abbreviation)
        }
        
        var result = [String]()
        
        subStrings.forEach {
            result.append(String($0))
        }
        
        
        
        return result
    }
    
}
