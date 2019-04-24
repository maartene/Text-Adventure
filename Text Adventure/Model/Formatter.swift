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
    
    var defaultAttributes = [NSAttributedString.Key: Any]()
    
    func format(formattedString: FormattedString) -> NSAttributedString {
        return format(formattedStrings: [formattedString])
    }
    
    func format(formattedStrings: [FormattedString]) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        formattedStrings.forEach {
            let formattedString = $0
            let attributedString = NSAttributedString(string: formattedString.stringValue, attributes: getAttributesForStyle(formattedString.style))
            result.append(attributedString)
        }
        return NSAttributedString(attributedString: result)
    }
    
    func setAttribute(attributes: [NSAttributedString.Key: Any], forKey: NSAttributedString.Key, newValue: Any) -> [NSAttributedString.Key: Any] {
        var result = attributes
        result[forKey] = newValue
        return result
    }
    
    func getAttributesForStyle(_ style: Style) -> [NSAttributedString.Key: Any] {
        switch style {
        case .error:
            return setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.red)
        case .warning:
            return setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.orange)
        case .title:
            let attributes = setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.green)
            let font = defaultAttributes[.font] as! NSFont
            return setAttribute(attributes: attributes, forKey: .font, newValue: NSFont(name: font.fontName, size: 24)!)
        case .noEmphasis:
            return setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.gray)
        case .emphasis:
            return setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.green)
        case .debug:
            return setAttribute(attributes: defaultAttributes, forKey: .foregroundColor, newValue: NSColor.purple)
        default:
            return defaultAttributes
        }
    }
}

struct FormattedString {
    let stringValue: String
    let style: Style
    
    init(string: String, style: Style = .normal) {
        self.stringValue = string
        self.style = style
    }
    
    func appendToStringValue(_ value: String) -> FormattedString {
        return FormattedString(string: self.stringValue + value, style: self.style)
    }
}

enum Style {
    case normal
    case noEmphasis
    case title
    case warning
    case error
    case emphasis
    case debug
}
