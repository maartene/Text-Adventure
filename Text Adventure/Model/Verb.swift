//
//  Verb.swift
//  Text Adventure
//
//  Created by Maarten Engels on 15/11/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

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
    case COMBINE
    
    var expectedNounCount: Int
    {
        switch self {
        case .LOOKAT:
            return 1
        case .GO:
            return 1
        case .OPEN:
            return 1
        case .TAKE:
            return 1
        case .USE:
            return 1
        case .COMBINE:
            return 2
        default:
            return 0
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
            case .COMBINE:
                result += "Combine two items together into a new one."
            case .SAVE:
                result += "Save your current progress."
            case .LOAD:
                result += "Load saved game."
            }
            
            if expectedNounCount == 2 {
                result += " use: <STRONG>\(self) [ITEM 1] WITH [ITEM 2]</STRONG>"
            } else if expectedNounCount == 1 {
                result += " use: <STRONG>\(self) [NOUN]</STRONG>"
            } else {
                result += " use: <STRONG>\(self)</STRONG>"
            }
                        
            return result
        }
    }
}
