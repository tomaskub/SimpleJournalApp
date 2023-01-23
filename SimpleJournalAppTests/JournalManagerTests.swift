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
    
}
//MARK: TESTS FOR ADD METHODS
extension JournalManagerTests {
    
    func testAddEntryByDate() {
        let date = Date()
        let dayLog = journalManager.addEntry(date)
        
        XCTAssertNotNil(dayLog, "Day log should not be nil")
        XCTAssertTrue(dayLog.date == Calendar.current.startOfDay(for: date))
        XCTAssertNotNil(dayLog.id, "Day log should have id")
    }
    
    func testAddEntryByDateWhenEntryExists() {
        let date = Date()
        
        let firstID = journalManager.addEntry(date).id
        let secondID = journalManager.addEntry(date).id
        
        XCTAssertTrue(firstID == secondID, "ID should be the same for second added day")
    }
    
    func testAddAnswerToDayLog() {
        let date = Date()
        let dayLog = journalManager.addEntry(date)
        
        let question = "This is question"
        let answer = "This is answer"
        
        journalManager.addAnswer(to: dayLog, for: question, answer: answer)
        
        XCTAssertNotNil(dayLog.answers?.allObjects.first, "Answer in day log should not be nil")
        XCTAssertNotNil((dayLog.answers?.allObjects.first as? Answer)?.question, "Question in answer in day log should not be nil")
        XCTAssertNotNil((dayLog.answers?.allObjects.first as? Answer)?.text, "Text in answer in day log should not be nil")
        XCTAssertTrue((dayLog.answers?.allObjects.first as? Answer)?.question == question, "Question should be 'This is question'")
        XCTAssertTrue((dayLog.answers?.allObjects.first as? Answer)?.text == answer, "Answer text property should be 'This is answer'")
    }
}

//MARK: tests for get methods
extension JournalManagerTests {
    
    func testGetEntryForDateWhenEntryExists() {
        let date = Date()
        _ = journalManager.addEntry(date)
        
        let resultDayLog = journalManager.getEntry(for: date)
        
        XCTAssertNotNil(resultDayLog, "Retrieved day log should not be nil")
        XCTAssertNotNil(resultDayLog?.id, "Retrieved day log should have id")
        XCTAssertTrue(resultDayLog?.date == Calendar.current.startOfDay(for: date), "Retrived day log should have date equal to start of the day")
        
    }
    
    func testGetEntryForDateWhenNoEntry() {
        let date = Date()
        
        let resultDayLog = journalManager.getEntry(for: date)
        
        XCTAssertNil(resultDayLog, "Retrived day log should be nil")
    }
}

//MARK: Tests for delete methods
extension JournalManagerTests {
    func testDeleteEntryByDate() {
        let date = Date()
        let dayLog = journalManager.addEntry(date)
        
        journalManager.deleteEntry(for: date)
        
        XCTAssertNotNil(dayLog, "Day log should not be nil")
        XCTAssertTrue(dayLog.date == date)
        XCTAssertNotNil(dayLog.id, "Day log should have id")
    }
}
