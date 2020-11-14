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
        case Verb.ABOUT:
            return about()
        case Verb.GO:
            return go(direction: newCommand.noun!)
        case Verb.LOOK:
            return describeRoom()
        case Verb.TAKE:
            return take(itemName: newCommand.noun!)
        case Verb.LOOKAT:
            return lookat(objectName: newCommand.noun!)
        case Verb.OPEN:
            return open(doorName: newCommand.noun!)
        case Verb.INVENTORY:
            return inventory()
        case Verb.USE:
            return use(itemName: newCommand.noun!)
        case Verb.SAVE:
            return saveGame()
        case Verb.LOAD:
            return loadGame()
        case Verb.QUIT:
            NSApplication.shared.terminate(nil)
            return "<H2>Good Bye!</H2>"
            
        default:
            // echo what comes in
            return "<DEBUG>Received command: \(newCommand)</DEBUG>\n"
        }
    }
    
    func about() -> String {
        return """
            This is a small text adventure written in Swift. I Hope you have fun playing it.
        &copy; <a href="https://www.thedreamweb.eu/">thedreamweb.eu</a> / Maarten Engels, 2019. MIT license.
        See <a href="https://github.com/maartene/Text-Adventure.git">https://github.com/maartene/Text-Adventure.git</a> for more information.
        """
    }
    
    func lookat(objectName: String) -> String {
        // First, check whether player intents to look at a door.
        if objectName.uppercased() == "DOOR" {
            if world.doorsInRoom(room: world.currentRoom).count > 0 {
                var result = ""
                for door in world.doorsInRoom(room: world.currentRoom) {
                    result += "The door to the <EXIT>\(door.direction(from: world.currentRoom))</EXIT> requires <ITEM>\(door.requiresItemToOpen?.name ?? "no item")</ITEM> to open."
                }
                return result
            } else {
                return "<WARNING>There is no </WARNING> <EXIT>DOOR</EXIT> <WARNING> in the current room.</WARNING>"
            }
        }
        
        // check whether there is an item in the room called itemName
        var itemsInRoomAndInventory = world.currentRoom.items
        itemsInRoomAndInventory.append(contentsOf: world.inventory)
        
        let possibleItems = itemsInRoomAndInventory.filter { item in item.canBe(partOfName: objectName) }
        
        switch possibleItems.count {
        case 0:
            return "<WARNING>There is no </WARNING> <ITEM>\(objectName)</ITEM> <WARNING> in the current room.</WARNING>"
        case 1:
            guard let item = possibleItems.first else {
                return "<DEBUG>Unexpected nil value in \(possibleItems).first</DEBUG>"
            }
            return "<ITEM>\(item.name)</ITEM>: \(item.description)"
        case 2...:
            return "<WARNING>More than one item contains </WARNING><ITEM>\(objectName)</ITEM>. <WARNING>Please be more specific.</WARNING>"
        default:
            return "<DEBUG>Negative item count should not be possible.</DEBUG>"
        }
    }
    
    func use(itemName: String) -> String {
        // get a list of all items in inventory that somehow have the itemName in it's name
        let potentialItems = world.inventory.filter { item in item.name.uppercased().contains(itemName.uppercased()) }
        
        switch potentialItems.count {
        case 0:
            return "<WARNING>You don't carry an item with name: <ITEM>\(itemName).</WARNING>"
        case 1:
            // we found an item
            guard let item = potentialItems.first else {
                return "<DEBUG>For some reason a nil value for found for the item.</DEBUG>"
            }
            
            switch world.use(item: item) {
            case .noEffect:
                return "You try and use the <ITEM>\(item.name)</ITEM>, but it has no effect."
            case .itemHadEffect:
                return "You used the \(item.name). It has the following effect: \(item.effect!)." + describeRoom()
            case .itemHadNoEffect:
                return "This does not seem to be the right place to use the \(item.name)."
            }

        case 2...:
            return "<WARNING>More than one item contains the name <ITEM>\(itemName). Please be more specific.</WARNING>"
        default:
            return "<DEBUG>A negative value of potentialItems.count was observed.</DEBUG>"
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
    
    func open(doorName: String) -> String {
        func interpretDoorOpenResult(_ doorResult: Door.DoorResult) -> String {
            var result = ""
            switch doorResult {
            case .doorDidOpen:
                result += "<ACTION>You opened the door.</ACTION>\n"
                result += describeRoom()
            case .missingItemToOpen(let item):
                result = "<WARNING>You require <ITEM>\(item.name)</ITEM> to open the door.</WARNING>"
            default:
                result = "<DEBUG>Failed to open door: \(doorResult)</DEBUG>"
            }
            return result
        }
        
        if world.doorsInRoom(room: world.currentRoom).count < 1 {
            return "<WARNING>There is no closed door here.</WARNING>\n"
        }
        
        let doorsInCurrentRoom = world.doorsInRoom(room: world.currentRoom)
        
        guard doorsInCurrentRoom.count > 0 else {
            return "<WARNING>There is no closed door here.</WARNING>\n"
        }
        
        let filteredDoors = doorsInCurrentRoom.filter { door in
            door.name.uppercased().contains(doorName.uppercased())
        }
        
        if filteredDoors.count == 0 {
            return "<WARNING>Could not find door with name \(doorName) in this room.</WARNING>"
        } else if filteredDoors.count > 1 {
            return "<WARNING>Please be more specific which door you want to open.</WARNING>\n"
        } else {
            let door = filteredDoors[0]
            let result = world.open(door: door)
            return interpretDoorOpenResult(result)
        }
    }
    
    func help() -> String {
        var result = "\n<H3>Commands:</H3>"
        Verb.allCases.forEach {
            result += "<STRONG>\($0.rawValue)</STRONG>   " + $0.explanation + "\n"
        }
        result += "\n"
        return result
    }
    
    func inventory() -> String {
        var result = "\nYou carry: \n"
        if world.inventory.count > 0 {
            world.inventory.forEach {
                result += "<ITEM>\($0.name)</ITEM>\n"
            }
        } else {
            result += "Nothing.\n"
        }
        //result += "\n"
        return result
    }
    
    func saveGame() -> String {
        if world.saveGame() {
            return "Save succesfull!"
        } else {
            return "<WARNING>Failed to save.</WARNING>"
        }
    }
    
    mutating func loadGame() -> String {
        var result = ""
        
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "<DUBUG>Failed to get document directory.</DEBUG>"
        }
            
        let fileURL = dir.appendingPathComponent("taSave.json")
        
        if let newWorld = World.loadGame(from: fileURL) {
            world = newWorld
            result += "Succesfully loaded world."
            result += describeRoom()
        } else {
            result += "<WARNING>Could not load game.</WARNING>"
        }
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
        if world.currentRoom.isDark && world.flags.contains("light") == false {
            result += "It's too dark to see."
        } else {
            result += showDescription()
            result += showExits()
            result += showItems()
            result += showDoors()
        }
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
            result += "There is a <EXIT>\($0.name.uppercased())</EXIT> to the <EXIT>\($0.direction(from: world.currentRoom))</EXIT>\n"
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
    case SAVE
    case LOAD
    case USE
    
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
        case .SAVE:
            return false
        case .LOAD:
            return false
        default:
            return true
        }
    }
    
    var explanation: String {
        get {
            var result = ""
            switch self {
            case .HELP:
                result += "Shows a list of commands."
            case .GO:
                result += "Go in a direction (NORTH, SOUTH, EAST, WEST)"
            case .ABOUT:
                result += "Information about this game."
            case .LOOK:
                result += "Look around in the current room."
            case .INVENTORY:
                result += "Show your inventory."
            case .QUIT:
                result += "Quit the game (instantanious - no save game warning!)"
            case .OPEN:
                result += "Open a door or container (chest/box/safe/...)."
            case .LOOKAT:
                result += "Look at an object in the room or in your inventory."
            case .TAKE:
                result += "Pick up an item into your inventory."
            case .USE:
                result += "Use an item."
            case .SAVE:
                result += "Save your current progress."
            case .LOAD:
                result += "Load saved game."
            default:
                result += ""
            }
            if expectNoun() {
                result += " use: <STRONG>\(self) [NOUN]</STRONG>"
            } else {
                result += " use: <STRONG>\(self)</STRONG>"
            }
            
            return result
        }
    }
}

struct Command {
    let verb: Verb
    let noun: String?
}
