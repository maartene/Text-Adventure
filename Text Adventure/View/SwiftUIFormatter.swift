//
//  SwiftUIFormatter.swift
//  Text Adventure
//
//  Created by Maarten Engels on 03/10/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SwiftUI

let tagRegex = try! NSRegularExpression(pattern: "<([a-z][a-z0-9]*)\\b[^>]*>(.*?)</\\1>", options: .caseInsensitive)

enum TextStyling: String {
    case none
    case STRONG
    case EXIT
    case ITEM
    case ACTION
    case WARNING
    case DEBUG
    case H1
    case H3
    
    static let allValues: [TextStyling] = [.none, .STRONG, .EXIT, .ITEM, .ACTION, .WARNING, .DEBUG, .H1, .H3]
}

extension TextStyling {
    func style(_ swiftUIText: Text) -> Text {
        switch self {
        case .H1:
            return swiftUIText.font(.largeTitle) + Text("\n")
        case .H3:
            return swiftUIText.font(.title) + Text("\n")
        case .ITEM:
            return swiftUIText.foregroundColor(Color(.sRGB, red: 0.87, green: 0.72, blue: 0.53, opacity: 1))
        case .ACTION:
            return swiftUIText.foregroundColor(Color.yellow)
        case .EXIT:
            return swiftUIText.foregroundColor(Color(.sRGB, red: 0.678, green: 1, blue: 0.184, opacity: 1))
        case .STRONG:
            return swiftUIText.bold()
        case .WARNING:
            return swiftUIText.foregroundColor(Color.orange)
        case .DEBUG:
            return swiftUIText.foregroundColor(Color.purple)
            
        default:
            return swiftUIText
        }
    }
}

struct TextElement: CustomStringConvertible {
    let text: String
    let format: TextStyling
    let children: [TextElement]
    
    init(_ string: String, format: TextStyling = .none) {
        if tagRegex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) == nil {
            self.text = string
            self.format = format
            children = []
        } else {
            let range = tagRegex.rangeOfFirstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count))
            let rangePart1 = NSRange(location: 0, length: range.lowerBound)
            
            var newChildren = [TextElement]()
            if let range1 = Range(rangePart1, in: string) {
                let part1 = string[range1]
                let textElement1 = TextElement(String(part1))
                newChildren.append(textElement1)
            }
            
            if let tagRange = Range(range, in: string) {
                var tag = String(string[tagRange])
                
                for styleTag in TextStyling.allValues {
                    if tag.contains("<\(styleTag)>") {
                        tag = tag.replacingOccurrences(of: "<\(styleTag)>", with: "")
                        tag = tag.replacingOccurrences(of: "</\(styleTag)>", with: "")
                        let textElementTag = TextElement(tag, format: styleTag)
                        newChildren.append(textElementTag)
                        break
                    }
                }
            }
            
            let rangePart2 = NSRange(location: range.upperBound, length: string.utf16.count - range.upperBound)
            if let range2 = Range(rangePart2, in: string) {
                let part2 = string[range2]
                let textElement2 = TextElement(String(part2))
                newChildren.append(textElement2)
            }
                        
            self.text = ""
            self.format = format
            self.children = newChildren
        }
        
        
    }
    
    var description: String {
        return "Text: '\(text)' ; format: '\(format)', children: '\(children)'"
    }
    
    func flatten() -> [TextElement] {
        var result = [TextElement(text, format: format)]
        for child in children {
            result.append(contentsOf: child.flatten())
        }
        return result.filter { $0.text.count > 0 }
    }
}

struct SwiftUIFormatter: Formatter {
    func format(_ html: String) -> Text {
        //print(html)
        let textElements = TextElement(html)
        
        let flattenedTextElements = textElements.flatten()
        let texts = flattenedTextElements.map { $0.format.style(Text($0.text)) }
        
        return texts.reduce(Text(""), +)
    }
}
