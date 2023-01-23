//
//  JournalManagerTests.swift
//  SimpleJournalAppTests
//
//  Created by Tomasz Kubiak on 1/23/23.
//

import XCTest
import CoreData
@testable import SimpleJournalApp

final class JournalManagerTests: XCTestCase {

    var journalManager: JournalManager!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack(modelName: "Model")
        journalManager = JournalManager(managedObjectContext: coreDataStack.managedContext, coreDataStack: coreDataStack)
    }
    override func tearDown() {
        super.tearDown()
        
        coreDataStack = nil
        journalManager = nil
        
    }
    func testContextIsSavedAfterAddingEntry() {
        //
    }
    
    func testAddEntryByDate() {
        let date = Date()
        let dayLog = journalManager.addEntry(date)
        
        XCTAssertNotNil(dayLog, "Day log should not be nil")
        XCTAssertTrue(dayLog.date == Calendar.current.startOfDay(for: date))
        XCTAssertNotNil(dayLog.id, "Day log should have id")
    }
    
    func testDeleteEntryByDate() {
        let date = Date()
        let dayLog = journalManager.addEntry(date)
        
        journalManager.deleteEntry(for: date)
        
        XCTAssertNotNil(dayLog, "Day log should not be nil")
        XCTAssertTrue(dayLog.date == date)
        XCTAssertNotNil(dayLog.id, "Day log should have id")
    }
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    

}
