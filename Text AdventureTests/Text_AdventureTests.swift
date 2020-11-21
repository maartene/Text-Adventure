//
//  Text_AdventureTests.swift
//  Text AdventureTests
//
//  Created by Maarten Engels on 19/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Text_Adventure

class Text_AdventureTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testSentence() {
        let sentences = [
            "TAKE lamp",
            "USE foo with bar",
            "help",
            "Use foo with",
            "Use with bar",
            "Take special lamp",
            "Take",
            "Use with",
            "with"
        ]
        
        for sentenceString in sentences {
            let sentence = Sentence.createSentence(sentenceString)
            print(sentence)
        }
    }
    
    func testUseTwoObjects() {
        let item1 = Item(name: "item 1", description: "item number 1", combineItemName: "item 2", replaceWithAfterUse: "new item")
        let item2 = Item(name: "item 2", description: "item number 2", combineItemName: "item 1", replaceWithAfterUse: "new item")
        
        let world = World()
        world.inventory.append(contentsOf: [item1, item2])
        
        var parser = Parser()
        parser.world = world
        
        let sentences = [
            "USE item 1 WITH item 2",
            "USE item with item",
            "USE 1 with 2",
            "USE foo with item 2",
            "USE item 1 with bar",
            "USE foo with bar",
            "USE item 1 with item",
            "USE item with item 2",
            "USE item 2 with item 1"
        ]
        
        for sentenceString in sentences {
            let result = parser.parse(command: sentenceString)
            print(result)
        }
    }
}
