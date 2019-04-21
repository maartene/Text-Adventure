//
//  Parser.swift
//  Text Adventure
//
//  Created by Maarten Engels on 19/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import AppKit

struct Parser {
    
    var world: World!
    
    func welcome() -> [FormattedString] {

        var result = [FormattedString(string: "Welcome to Text Adventure\n\n", style: .title)]
        result.append(contentsOf: showDescription())
        result.append(contentsOf: showExits())
        return result
    }
    
    mutating func parse(command: String) -> [FormattedString] {
        
        let words = Lexer.lex(command)
        
        // for the first word, expect a verb
        let newCommand: Command
        if let verbWord = words.first?.uppercased() {
            if let verb = Verb(rawValue: verbWord) {
                if verb.expectNoun() {
                    // expect a noun, check whether one is available
                    if words.count < 2 {
                        return [FormattedString(string: "Expected a noun as the second word for verb: \(verb)\n", style: .warning)]
                    } else {
                        newCommand = Command(verb: verb, noun: words[1])
                    }
                } else {
                    // don't expect any noun
                    newCommand = Command(verb: verb, noun: nil)
                }
            } else {
                return [FormattedString(string: "Expected a verb as the first word, found: \(verbWord)\n", style: .warning)]
            }
        } else {
            return [FormattedString(string: "nothing to parse\n", style: .warning)]
        }
        
        // execute the command
        switch newCommand.verb {
        case Verb.HELP:
            return help()
        case Verb.GO:
            return go(direction: newCommand.noun!)
        case Verb.LOOK:
            var result = [FormattedString(string: "\n")]
            result.append(contentsOf: showDescription())
            result.append(contentsOf: showExits())
            return result
        default:
            // echo what comes in
            return [FormattedString(string: "Received command: \(newCommand)\n", style: .debug)]
        }
    }
    
    func go(direction: String) -> [FormattedString] {
        // check whether the current room has this exit
        if let direction = Direction(rawValue: direction.uppercased()) {
            // direction is a valid Direction
            if world.go(direction: direction) {
                var result = [FormattedString(string: "\n\n", style: .noEmphasis)]
                result.append(contentsOf: showDescription())
                result.append(contentsOf: showExits())
                return result
            } else {
                // apparently not a valid exit
                return [FormattedString(string: "You bang against the wall.\n", style: .warning)]
            }
        } else {
            return [FormattedString(string: "\(direction) is not a valid direction.\n", style: .warning)]
        }
    }
    
    func help() -> [FormattedString] {
        var result = [FormattedString(string: "\nCommands: \n")]
        Verb.allCases.forEach {
            result.append(FormattedString(string: $0.rawValue + "\n", style: .noEmphasis))
        }
        result.append(FormattedString(string: "\n"))
        return result
    }
    
    func expectNoun(noun: String) -> Bool {
        if noun == "" {
            return false
        }
        
        return true
    }
    
    func showDescription() -> [FormattedString] {
        return [FormattedString(string: world.currentRoom.description + "\n", style: .noEmphasis)]
    }
    
    func showExits() -> [FormattedString] {
        var result = [FormattedString]()
        world.currentRoom.exits.keys.forEach {
            result.append(FormattedString(string: "There is an exit to the \($0).\n"))
        }
        return result
    }
}

enum Verb: String, CaseIterable {
    case HELP
    case LOOK
    case LOOKAT
    case GO
    case TAKE
    case ABOUT
    
    func expectNoun() -> Bool
    {
        switch self {
        case .HELP:
            return false
        case .ABOUT:
            return false
        case .LOOK:
            return false
        default:
            return true
        }
    }
}

struct Command {
    let verb: Verb
    let noun: String?
}
