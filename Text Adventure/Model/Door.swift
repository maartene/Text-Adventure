//
//  Door.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

// when you open a door, it creates a new connection
struct Door: Equatable, Codable {
    enum DoorResult: Equatable {
        case doorDoesNotExist
        case doorDidOpen
        case missingItemToOpen(item: Item)
    }
    
    let name: String
    let betweenRooms: [Int: Direction]
    var requiresItemToOpen: Item?
    
    static func createDoor(between room1: Room, facing: Direction, to room2: Room, itemToOpen: Item? = nil, name: String = "DOOR") -> Door {
        let betweenRooms = [room1.id: facing, room2.id: facing.opposite()]
        return Door(name: name, betweenRooms: betweenRooms, requiresItemToOpen: itemToOpen)
    }
    
    func canOpen(world: World) -> Bool {
        if let itemToOpen = requiresItemToOpen {
            return world.inventory.contains(itemToOpen)
        } else {
            return true
        }
    }
    
    func open(world: World) -> DoorResult {
        if canOpen(world: world) {
            let roomIDs = Array<Int>(betweenRooms.keys)
            world.connectRoomFrom(roomId: roomIDs[0], using: betweenRooms[roomIDs[0]]!, to: roomIDs[1], bidirectional: true)
            
            if let itemToOpen = requiresItemToOpen {
                world.inventory.remove(at: world.inventory.firstIndex(of: itemToOpen)!)
            }
            
            return .doorDidOpen
        } else {
            return .missingItemToOpen(item: requiresItemToOpen!)
        }
    }
    
    func direction(from room: Room) -> Direction {
        if let dir = betweenRooms[room.id] {
            return dir
        } else {
            fatalError("There is no door in room \(room).")
        }
    }
}
