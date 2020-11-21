//
//  Item.swift
//  Text Adventure
//
//  Created by Maarten Engels on 18/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Item: Equatable, Codable {
    static let prototypes = [Item(name: "Oil Lamp", description: "The lamp has fuel.", effect: .light)]
    
    enum ItemEffect: Int, Codable {
        case light
    }
    
    enum ItemResult: String {
        case noEffect
        case itemHadNoEffect
        case itemHadEffect
        case itemsCannotBeCombined
        case itemNotInInventory
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
    let combineItemName: String?
    let replaceWithAfterUse: String?
    
    private init(name: String, description: String, effect: ItemEffect?, combineItemName: String?, replaceWithAfterUse: String?) {
        self.name = name
        self.description = description
        self.effect = effect
        self.combineItemName = combineItemName
        self.replaceWithAfterUse = replaceWithAfterUse
    }
    
    init(name: String, description: String) {
        self = Item(name: name, description: description, effect: nil, combineItemName: nil, replaceWithAfterUse: nil)
    }
    
    init(name: String, description: String, effect: ItemEffect) {
        self = Item(name: name, description: description, effect: effect, combineItemName: nil, replaceWithAfterUse: nil)
    }
    
    init(name: String, description: String, combineItemName: String, replaceWithAfterUse: String) {
        self = Item(name: name, description: description, effect: nil, combineItemName: combineItemName, replaceWithAfterUse: replaceWithAfterUse)
    }
}
