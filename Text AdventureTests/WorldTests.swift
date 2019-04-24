//
//  WorldTests.swift
//  Text AdventureTests
//
//  Created by Maarten Engels on 24/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Text_Adventure

class WorldTests: XCTestCase {

    
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
    
    func testRoomConnections() {
        let world = World()
        
        world.currentRoomIndex = 1
        let connectionsInRoom1 = world.currentRoom.exits.keys
        
        assert(connectionsInRoom1.count == 3)
        assert(connectionsInRoom1.contains(Direction.WEST))
        assert(connectionsInRoom1.contains(Direction.EAST))
        assert(connectionsInRoom1.contains(Direction.SOUTH))
    }
    
    func testConnectionWithDoorBlocked() {
        /*let world = World()
        
        let connectionsInRoom2 = world.getExitsForRoom(roomID: 2)
        
        var connectionToRoom5 = connectionsInRoom2.first { $0.room2.id == 5 }!
        
        // check whether this is actually a closed door
        assert(connectionToRoom5.isDoor == true)
        assert(connectionToRoom5.canTraverse() == false)
        
        // check to see whether we can open it
        assert((connectionToRoom5.canOpen(inventory: [Item(name: "Skeleton Key", description: "Bone made key")])))
        
        // we open the door
        let newInventory = connectionToRoom5.open(inventory: [Item(name: "Skeleton Key", description: "")])
        
        // assert that this consumed the item
        assert((newInventory.count == 0))
        
        // assert that the door is now open and we can traverse the connection
        assert(connectionToRoom5.isOpen == true)
        assert(connectionToRoom5.canTraverse() == true)
 */
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
