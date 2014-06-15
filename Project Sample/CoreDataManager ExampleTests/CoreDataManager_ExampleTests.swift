//
//  CoreDataManager_ExampleTests.swift
//  CoreDataManager ExampleTests
//
//  Created by Manuel de la Mata on 13/06/2014.
//  Copyright (c) 2014 MMS. All rights reserved.
//

import XCTest
import CoreData
import Foundation

class CoreDataManager_ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        CoreDataManager.shared.initialize()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            
            let count = 1000

            for (var i=0; i < count; i++){
                
                var newMonkey: MonkeyEntity = NSEntityDescription.insertNewObjectForEntityForName("MonkeyEntity", inManagedObjectContext: CoreDataManager.shared.managedObjectContext) as MonkeyEntity
                
                newMonkey.name = NSString(format:"Monkey x%.002d", i)
                
                CoreDataManager.shared.save()
            }
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                for (var i=0; i < count; i++){
                    
                    var newMonkey: MonkeyEntity = NSEntityDescription.insertNewObjectForEntityForName("MonkeyEntity", inManagedObjectContext: CoreDataManager.shared.managedObjectContext) as MonkeyEntity
                    
                    newMonkey.name = NSString(format:"Monkey %.002d", i)
                                        
                    CoreDataManager.shared.save()
                }
            })
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                
                for (var i=0; i < count; i++){
                    var request: NSFetchRequest = NSFetchRequest(entityName: "MonkeyEntity")
                    request.sortDescriptors = [NSSortDescriptor(key: "name" , ascending: true)]
                    CoreDataManager.shared.executeFetchRequest(request) { results in }
                }
            })
         

        }
    }

}
