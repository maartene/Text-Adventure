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
    
    func welcome() -> String {

        var result = "<H1>Welcome to Text Adventure</H1>"
        result += describeRoom()
        return result
    }
    
    mutating func parse(command: String) -> String {
        
        let words = Lexer.lex(command)
        
        // for the first word, expect a verb
        let newCommand: Command
        if let verbWord = words.first?.uppercased() {
            if let verb = Verb(rawValue: verbWord) {
                if verb.expectNoun() {
                    // expect a noun, check whether one is available
                    if words.count < 2 {
                        return "<WARNING>Expected a noun as the second word for verb: \(verb)</WARNING>\n"
                    } else {
                        newCommand = Command(verb: verb, noun: words[1])
                    }
                } else {
                    // don't expect any noun
                    newCommand = Command(verb: verb, noun: nil)
                }
            } else {
                let word = verbWord.isEmpty ? ", but none was found." : ", found: \"\(verbWord)\""
                return "<WARNING>Expected a verb as the first word\(word)</WARNING>\n"
            }
        } else {
            return "<DEBUG>nothing to parse</DEBUG>\n"
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
        case Verb.OPEN:
            return open()
        case Verb.INVENTORY:
            return inventory()
        case Verb.QUIT:
            NSApplication.shared.terminate(nil)
            return "<H2>Good Bye!</H2>"
            
        default:
            // echo what comes in
            return "<DEBUG>Received command: \(newCommand)</DEBUG>\n"
        }
    }
    
    func go(direction: String) -> String {
        // check whether the current room has this exit
        if let direction = Direction(rawValue: direction.uppercased()) {
            // direction is a valid Direction
            if world.go(direction: direction) {
                return describeRoom()
            } else {
                // apparently not a valid exit
                return "<WARNING>You bang against the wall.</WARNING>\n"
            }
        } else {
            return "<WARNING>\(direction) is not a valid direction.</WARNING>\n"
        }
    }
    
    func take(itemName: String) -> String {
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
            return "There is no <ITEM>\(itemName)</ITEM> here.\n"
        case 1:
            // we found exactly one item that matches. Try and get the item.
            let item = potentialItems.first!
            if world.take(item: item) {
                return "\nYou picked up <ITEM>\(item.name)</ITEM>.\n"
            } else {
                return "\nYou could not pick up <ITEM>\(item.name)</ITEM>\n"
            }
        default:
            // more than one potential item was found, how can we choose?
            return "\nMore than one item matches <ITEM>\(itemName)</ITEM>. Please be more specific.\n"
        }
    }
    
    func open() -> String {
        if world.doorsInRoom(room: world.currentRoom).count < 1 {
            return "<WARNING>There is no closed door here.</WARNING>\n"
        }
        
        if world.open() {
            var result = "<ACTION>You opened the door.</ACTION>\n"
            result += describeRoom()
            return result
        } else {
            return "<WARNING>You could not open the door.</WARNING>\n"
        }
    }
    
    func help() -> String {
        var result = "\nCommands: \n"
        Verb.allCases.forEach {
            result += $0.rawValue + "\n"
        }
        result += "\n"
        return result
    }
    
    func inventory() -> String {
        var result = "\nYou carry: \n"
        if world.inventory.count > 0 {
            world.inventory.forEach {
                result += "<ITEM>\($0.name)</ITEM>"
            }
        } else {
            result += "Nothing."
        }
        result += "\n"
        return result
    }
    
    func expectNoun(noun: String) -> Bool {
        if noun == "" {
            return false
        }
        
        return true
    }
    
    func describeRoom() -> String {
        var result = "\n"
        result += showDescription()
        result += showExits()
        result += showItems()
        result += showDoors()
        return result
    }
    
    func showDescription() -> String {
        return "<H3>\(world.currentRoom.name)</H3>" + world.currentRoom.description + "\n"
    }
    
    func showExits() -> String {
        var result = ""
        world.currentRoom.exits.keys.forEach {
            result += "There is an exit to the <EXIT>\($0)</EXIT>.\n"
        }
        return result
    }
    
    func showItems() -> String {
        var result = ""
        world.currentRoom.items.forEach {
            result += "You see a <ITEM>\($0.name)</ITEM>\n"
        }
        
        return result
    }
    
    func showDoors() -> String {
        let doorsInRoom = world.doorsInRoom(room: world.currentRoom)
        
        var result = ""
        doorsInRoom.forEach {
            result += "There is a <EXIT>DOOR</EXIT> to the <EXIT>\($0.direction(from: world.currentRoom))</EXIT>\n"
        }
        
        return result
    }
}

enum Verb: String, CaseIterable {
    case HELP
    case LOOK
    case LOOKAT
    case GO
    case OPEN
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
