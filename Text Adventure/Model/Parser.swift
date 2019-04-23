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
        result.append(contentsOf: describeRoom())
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
            return describeRoom()
        case Verb.TAKE:
            return take(itemName: newCommand.noun!)
        case Verb.INVENTORY:
            return inventory()
        case Verb.QUIT:
            NSApplication.shared.terminate(nil)
            return [FormattedString(string: "Good Bye!")]
            
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
                return describeRoom()
            } else {
                // apparently not a valid exit
                return [FormattedString(string: "You bang against the wall.\n", style: .warning)]
            }
        } else {
            return [FormattedString(string: "\(direction) is not a valid direction.\n", style: .warning)]
        }
    }
    
    func take(itemName: String) -> [FormattedString] {
        // first try and find the item in the room
        var potentialItems = [Item]()
        for index in 0 ..< world.currentRoom.items.count {
            
            // get an array of all the words that make up the item name. We can use this to find all matching items
            let itemWords = world.currentRoom.items[index].name.split(separator: " ")
            
            itemWords.forEach {
                if $0.uppercased().starts(with: itemName.uppercased()) {
                    let potentialItem = world.currentRoom.items[index]
                    potentialItems.append(potentialItem)
                }
            }
        }
        
        switch potentialItems.count {
        case 0:
            // no potential item was found
            return [FormattedString(string: "There is no \(itemName) here.\n", style: .warning)]
        case 1:
            // we found exactly one item that matches. Try and get the item.
            let item = potentialItems.first!
            if world.take(item: item) {
                return [FormattedString(string: "\nYou picked up \(item.name).\n")]
            } else {
                return [FormattedString(string: "\nYou could not pick up \(item.name)\n", style: .debug)]
            }
        default:
            // more than one potential item was found, how can we choose?
            return [FormattedString(string: "\nMore than one item matches \(itemName). Please be more specific.\n", style: .warning)]
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
    
    func inventory() -> [FormattedString] {
        var result = [FormattedString(string: "\nYou carry: \n")]
        if world.inventory.count > 0 {
            world.inventory.forEach {
                result.append(FormattedString(string: $0.name, style: .noEmphasis))
            }
        } else {
            result.append(FormattedString(string: "Nothing."))
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
    
    func describeRoom() -> [FormattedString] {
        var result = [FormattedString(string: "\n\n", style: .noEmphasis)]
        result.append(contentsOf: showDescription())
        result.append(contentsOf: showExits())
        result.append(contentsOf: showItems())
        return result
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
    
    func showItems() -> [FormattedString] {
        var result = [FormattedString]()
        world.currentRoom.items.forEach {
            result.append(FormattedString(string: "You see a \($0.name)\n"))
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
    case INVENTORY
    case QUIT
    
    func expectNoun() -> Bool
    {
        switch self {
        case .HELP:
            return false
        case .ABOUT:
            return false
        case .LOOK:
            return false
        case .INVENTORY:
            return false
        case .QUIT:
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
