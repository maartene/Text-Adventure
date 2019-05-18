//
//  World.swift
//  Text Adventure
//
//  Created by Maarten Engels on 21/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import AppKit

class World: Codable {
    // make sure that rooms ID == index in rooms array
    var rooms = [Room]()
    var doors = [Door]()
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
        rooms.append(Room(id: 0, name: "Small Cupboard", description: "You find yourself in a small cupboard. There are some empty shelves nearby. The only light eminates from the crack between the floor and the door."))
        rooms.append(Room(id: 1, name: "Main Hall", description: "A slightly larger hallway. A skylight provides illumination, making your wonder what is better: not seeing anything because of absense of light or not seeing anything because there simply is nothing to see?"))
        rooms.append(Room(id: 2, name: "Bedroom", description: "This appears to be the master bedroom."))
        rooms.append(Room(id: 3, name: "East corridor", description: "You are in a tight corridor. There are some storage shelves left of you."))
        rooms.append(Room(id: 4, name: "South corridor", description: "You are in a tight corridor. A ceiling window provides some light around you."))
        rooms.append(Room(id: 5, name: "Secret Stash", description: "Congratulations! You found the secret stash!"))
        
        connectRoomFrom(room: rooms[0], using: .EAST, to: rooms[1])
        connectRoomFrom(room: rooms[1], using: .EAST, to: rooms[2])
        connectRoomFrom(room: rooms[2], using: .SOUTH, to: rooms[3])
        connectRoomFrom(room: rooms[3], using: .WEST, to: rooms[4])
        connectRoomFrom(room: rooms[4], using: .NORTH, to: rooms[1])
        
        rooms[3] = rooms[3].addItem(Item(name: "Skeleton Key", description: "Bone made key."))
        rooms[3] = rooms[3].addItem(Item(name: "Green Key", description: "Green key."))
        
        doors.append(Door.createDoor(between: rooms[2], facing: .NORTH, to: rooms[5], itemToOpen: Item(name: "Skeleton Key", description: "")))
    }
    
    func saveGame() -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent("taSave.json")
                print("attempting save to: \(fileURL)")
                //writing
                try data.write(to: fileURL, options: .atomic)
                return true
            } else {
                return false
            }
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    static func loadGame(from url: URL) -> World? {
        var world: World? = nil
        print("attempting load from: \(url)")
        
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            world = try? decoder.decode(World.self, from: data)
        } catch {
            print("Error: \(error)")
        }
        
        return world
    }
    
    func connectRoomFrom(room: Room, using direction: Direction, to room2: Room, bidirectional: Bool = true) {
        rooms[room.id] =
        room.addExit(direction: direction, roomID: room2.id)
        if bidirectional {
            rooms[room2.id] = room2.addExit(direction: direction.opposite(), roomID: room.id)
        }
    }
    
    func connectRoomFrom(roomId: Int, using direction: Direction, to room2Id: Int, bidirectional: Bool = true) {
        let room1 = rooms[roomId]
        let room2 = rooms[room2Id]
        connectRoomFrom(room: room1, using: direction, to: room2, bidirectional: bidirectional)
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
    
    func doorsInRoom(room: Room) -> [Door] {
        return doors.filter { $0.betweenRooms.keys.contains(room.id) }
    }
    
    func open() -> Door.DoorResult {
        let doorsInCurrentRoom = doorsInRoom(room: currentRoom)
        var result = Door.DoorResult.doorDidOpen
        if doorsInCurrentRoom.count > 0 {
            doorsInCurrentRoom.forEach {
                result = $0.open(world: self)
                if result == .doorDidOpen { doors.remove(at: doors.firstIndex(of: $0)!) }
            }
        }
        return result
    }
}

struct Room: Codable {
    let id: Int
    var exits = [Direction: Int]()
    let name: String
    let description: String
    var items = [Item]()
    
    init(id: Int, name: String, description: String, exits: [Direction: Int]? = nil) {
        self.id = id
        self.description = description
        self.name = name
        
        if let exits = exits {
            self.exits = exits
        }
    }
    
    func addExit(direction: Direction, roomID: Int) -> Room {
        var newExits = [direction: roomID]
        newExits.merge(self.exits) { (_, new) in new }
        return Room(id: self.id, name: self.name, description: self.description, exits: newExits)
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

struct Item: Equatable, Codable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
    
    func canBe(partOfName: String) -> Bool {
        return name.uppercased().contains(partOfName.uppercased())
    }
    
    let name: String
    let description: String
}

// when you open a door, it creates a new connection
struct Door: Equatable, Codable {
    enum DoorResult: Equatable {
        case doorDidOpen
        case missingItemToOpen(item: Item)
    }
    
    let betweenRooms: [Int: Direction]
    var requiresItemToOpen: Item?
    
    static func createDoor(between room1: Room, facing: Direction, to room2: Room, itemToOpen: Item? = nil) -> Door {
        let betweenRooms = [room1.id: facing, room2.id: facing.opposite()]
        return Door(betweenRooms: betweenRooms, requiresItemToOpen: itemToOpen)
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

enum Direction: String, Codable {
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
