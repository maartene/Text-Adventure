//
//  Item.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Item: Equatable, Codable {
    enum ItemEffect: Int, Codable {
        case light
    }
    
    enum ItemResult: String {
        case noEffect
        case itemHadNoEffect
        case itemHadEffect
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
    
    func canBe(partOfName: String) -> Bool {
        return name.uppercased().contains(partOfName.uppercased())
    }
    
    let name: String
    let description: String
    let effect: ItemEffect?
    
    init(name: String, description: String, effect: ItemEffect? = nil) {
        self.name = name
        self.description = description
        self.effect = effect
    }
}
