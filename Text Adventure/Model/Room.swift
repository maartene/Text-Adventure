//
//  Room.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Room: Codable {
    let id: Int
    var exits = [Direction: Int]()
    let name: String
    let description: String
    var isDark = false
    var items = [Item]()
    
    init(id: Int, name: String, description: String, isDark: Bool = false, exits: [Direction: Int]? = nil) {
        self.id = id
        self.description = description
        self.name = name
        self.isDark = isDark
        
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
