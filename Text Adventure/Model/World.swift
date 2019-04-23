//
//  World.swift
//  Text Adventure
//
//  Created by Maarten Engels on 21/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import AppKit

class World {
    // make sure that rooms ID == index in rooms array
    var rooms = [Room]()
    var currentRoomIndex = 0
    
    var currentRoom: Room {
        get {
            return rooms[currentRoomIndex]
        }
    }
    
    var inventory = [Item]()
    
    init() {
        // setup a test world with a couple of (connected) rooms.
        // this will probably be read from a file later.
        rooms.append(Room(id: 0, description: "You find yourself in a small cupboard. There are some empty shelves nearby. The only light eminates from the crack between the floor and the door."))
        rooms.append(Room(id: 1, description: "A slightly larger hallway. A skylight provides illumination, making your wonder what is better: not seeing anything because of absense of light or not seeing anything because there simply is nothing to see?"))
        rooms.append(Room(id: 2, description: "Room 2"))
        rooms.append(Room(id: 3, description: "Room 3"))
        rooms.append(Room(id: 4, description: "Room 4"))
        
        connectRoomFrom(room: rooms[0], using: .EAST, to: rooms[1])
        connectRoomFrom(room: rooms[1], using: .EAST, to: rooms[2])
        connectRoomFrom(room: rooms[2], using: .SOUTH, to: rooms[3])
        connectRoomFrom(room: rooms[3], using: .WEST, to: rooms[4])
        connectRoomFrom(room: rooms[4], using: .NORTH, to: rooms[1])
        
        rooms[3] = rooms[3].addItem(Item(name: "Skeleton Key", description: "Bone made key."))
        rooms[3] = rooms[3].addItem(Item(name: "Green Key", description: "Green key."))
    }
    
    func connectRoomFrom(room: Room, using direction: Direction, to room2: Room, bidirectional: Bool = true) {
        rooms[room.id] =
        room.addExit(direction: direction, roomID: room2.id)
        if bidirectional {
            rooms[room2.id] = room2.addExit(direction: direction.opposite(), roomID: room.id)
        }
    }
    
    func go(direction: Direction) -> Bool {
        if currentRoom.exits.keys.contains(direction) {
            currentRoomIndex = currentRoom.exits[direction]!
            return true
        } else {
            return false
        }
    }
    
    func take(item: Item) -> Bool {
        if currentRoom.items.contains(item) {
            rooms[currentRoomIndex] = currentRoom.removeItem(item)
            inventory.append(item)
            return true
        } else {
            return false
        }
    }
}

struct Room {
    let id: Int
    var exits = [Direction: Int]()
    let description: String
    var items = [Item]()
    
    init(id: Int, description: String, exits: [Direction: Int]? = nil) {
        self.id = id
        self.description = description
        
        if let exits = exits {
            self.exits = exits
        }
    }
    
    func addExit(direction: Direction, roomID: Int) -> Room {
        var newExits = [direction: roomID]
        newExits.merge(self.exits) { (_, new) in new }
        return Room(id: self.id, description: self.description, exits: newExits)
    }
    
    func addItem(_ item: Item) -> Room {
        var result = self
        result.items.append(item)
        return result
    }
    
    func removeItem(_ item: Item) -> Room {
        var result = self
        
        guard let index = result.items.firstIndex(of: item) else {
                fatalError("Room \(self) does not contain an item \(item)")
        }
        
        result.items.remove(at: index)
        return result
    }
}

struct Connection {
    let fromRoom: Room
    let toRoom: Room
    let hasDoor: Bool
    let requiresItemToOpen: Item?
    var isOpen = false
    
    
    func canOpen(inventory: [Item]) -> Bool {
        if hasDoor == false {
            return false
        }
        
        if let requiredItem = requiresItemToOpen {
            if inventory.contains(requiredItem) == false {
                return false
            }
        }
        return true
    }
    
    func canPass() -> Bool {
        if hasDoor && isOpen == false {
            return false
        }
        
        return true
    }
    
}

struct Item: Equatable {
    let name: String
    let description: String
}

enum Direction: String {
    case NORTH
    case SOUTH
    case EAST
    case WEST
    
    func opposite() -> Direction {
        switch self {
        case .EAST:
            return .WEST
        case .WEST:
            return .EAST
        case .NORTH:
            return .SOUTH
        case .SOUTH:
            return .NORTH
        }
    }
}
