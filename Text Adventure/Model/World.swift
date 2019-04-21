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
    }
    
    func connectRoomFrom(room: Room, using direction: Direction, to room2: Room, bidirectional: Bool = true) {
        room.addExit(direction: direction, roomID: room2.id)
        if bidirectional {
            room2.addExit(direction: direction.opposite(), roomID: room.id)
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
}

class Room {
    let id: Int
    var exits = [Direction: Int]()
    let description: String
    
    init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
    
    func addExit(direction: Direction, roomID: Int) {
        exits[direction] = roomID
    }
    
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
