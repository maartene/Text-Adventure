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
    enum WorldKeys: CodingKey {
        case rooms
        case doors
        case currentRoomIndex
        case inventory
        case flags
    }
    
    enum WorldErrors: Error {
        case roomWithIndexDoesNotExist
    }
    
    // make sure that rooms ID == index in rooms array
    var rooms = [Int: Room]()
    
    var doors = [Door]()
    var currentRoomIndex = 0
    
    var flags = Set<String>()
    
    var currentRoom: Room {
        get {
            guard let room = rooms[currentRoomIndex] else {
                fatalError("CurrentRoomIndex has a value (\(currentRoomIndex)) for which no room could be found.")
            }
            return room
        }
    }
    
    var inventory = [Item]()
    
    init() {
        // setup a test world with a couple of (connected) rooms.
        // this will probably be read from a file later.
        addRoom(id: 0, name: "Small Cupboard", description: "You find yourself in a small cupboard. There are some empty shelves nearby. The only light eminates from the crack between the floor and the door.")
        addRoom(id: 1, name: "Main Hall", description: "A slightly larger hallway. A skylight provides illumination, making your wonder what is better: not seeing anything because of absense of light or not seeing anything because there simply is nothing to see?")
        addRoom(id: 2, name: "Bedroom", description: "This appears to be the master bedroom.")
        addRoom(id: 3, name: "East corridor", description: "You are in a tight corridor. There are some storage shelves left of you.")
        addRoom(id: 4, name: "South corridor", description: "You are in a tight corridor. A ceiling window provides some light around you.")
        addRoom(id: 5, name: "Secret Stash", description: "Congratulations! You found the secret stash!")
        addRoom(id: 6, name: "Choose door", description: "There are three doors in this room. Which one do you choose?")
        
        connectRoomFrom(room: rooms[0]!, using: .EAST, to: rooms[1]!)
        connectRoomFrom(room: rooms[1]!, using: .EAST, to: rooms[2]!)
        connectRoomFrom(room: rooms[2]!, using: .SOUTH, to: rooms[3]!)
        connectRoomFrom(room: rooms[3]!, using: .WEST, to: rooms[4]!)
        connectRoomFrom(room: rooms[4]!, using: .NORTH, to: rooms[1]!)
        connectRoomFrom(room: rooms[0]!, using: .NORTH, to: rooms[6]!)
        
        rooms[3] = rooms[3]!.addItem(Item(name: "Skeleton Key", description: "Bone made key."))
        rooms[3] = rooms[3]!.addItem(Item(name: "Green Key", description: "Green key."))
        
        let singleUseKey = Item(name: "Single Use Key", description: "Use this key to open one of three doors.")
        rooms[6] = rooms[6]!.addItem(singleUseKey)
        
        doors.append(Door.createDoor(between: rooms[2]!, facing: .NORTH, to: rooms[5]!, itemToOpen: Item(name: "Skeleton Key", description: "")))
        
        doors.append(Door.createDoor(between: rooms[6]!, facing: .NORTH, to: rooms[5]!, itemToOpen: singleUseKey, name: "First Door"))
        doors.append(Door.createDoor(between: rooms[6]!, facing: .NORTH, to: rooms[5]!, itemToOpen: singleUseKey, name: "Second Door"))
        doors.append(Door.createDoor(between: rooms[6]!, facing: .NORTH, to: rooms[5]!, itemToOpen: singleUseKey, name: "Third Door"))
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: WorldKeys.self)
        
        let roomsArray = try values.decode([Room].self, forKey: .rooms)
        roomsArray.forEach { room in
            rooms[room.id] = room
        }
        
        //print(rooms)
        
        doors = try values.decode([Door].self, forKey: .doors)
        inventory = try values.decode([Item].self, forKey: .inventory)
        currentRoomIndex = try values.decode(Int.self, forKey: .currentRoomIndex)
        flags = try values.decode(Set<String>.self, forKey: .flags)
        
        guard currentRoomIndex >= 0 && currentRoomIndex < rooms.count else {
            throw WorldErrors.roomWithIndexDoesNotExist
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WorldKeys.self)
        
        let roomsArray = Array(rooms.values)
        try container.encode(roomsArray, forKey: .rooms)
        try container.encode(doors, forKey: .doors)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(currentRoomIndex, forKey: .currentRoomIndex)
        try container.encode(flags, forKey: .flags)
    }
    
    // MARK: Save and load game
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
    
    // MARK: world creation functions
    func addRoom(id: Int, name: String, description: String) {
        rooms[id] = Room(id: id, name: name, description: description)
    }
    
    func connectRoomFrom(room: Room, using direction: Direction, to room2: Room, bidirectional: Bool = true) {
        rooms[room.id] =
        room.addExit(direction: direction, roomID: room2.id)
        if bidirectional {
            rooms[room2.id] = room2.addExit(direction: direction.opposite(), roomID: room.id)
        }
    }
    
    func connectRoomFrom(roomId: Int, using direction: Direction, to room2Id: Int, bidirectional: Bool = true) {
        guard let room1 = rooms[roomId], let room2 = rooms[room2Id] else {
            print("At least one room could not be found.")
            return
        }
        connectRoomFrom(room: room1, using: direction, to: room2, bidirectional: bidirectional)
    }
    
    // MARK: Commands
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
    
    func open(door: Door) -> Door.DoorResult {
        guard doorsInRoom(room: currentRoom).contains(door) else {
            return Door.DoorResult.doorDoesNotExist
        }
        
        let result = door.open(world: self)
        if result == .doorDidOpen {
            doors.remove(at: doors.firstIndex(of: door)!)
        }
        return result
    }
    
    func use(item: Item) -> Item.ItemResult {
        guard let effect = item.effect else {
            return Item.ItemResult.noEffect
        }
        
        switch effect {
        case .light:
            flags.insert("light")
            return .itemHadEffect
        }
    }
    
    // MARK: Command helpers
    func doorsInRoom(room: Room) -> [Door] {
        return doors.filter { $0.betweenRooms.keys.contains(room.id) }
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
