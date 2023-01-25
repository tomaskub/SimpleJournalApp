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
        let dayLog = journalManager.addEntry(date)
        
        let resultsFromGet = journalManager.getEntry(for: date)
        
        XCTAssertNil(resultsFromGet.error, "Retrived results should not have error")
        XCTAssertNotNil(resultsFromGet.dayLogs, "Retrieved day logs should not be nil")
        XCTAssertTrue(resultsFromGet.dayLogs.count == 1, "Retrived day logs should have 1 element")
        XCTAssertTrue(resultsFromGet.dayLogs.first?.date == Calendar.current.startOfDay(for: date), "Date should be start of today")
        XCTAssertTrue(resultsFromGet.dayLogs.first?.id == dayLog.id, "ID should match the created dayLog id")
        
    }
    
    func testGetEntryForDateWhenNoEntry() {
        
        let resultsFromGet = journalManager.getEntry(for: Date())
        
        XCTAssertNotNil(resultsFromGet.error, "Retrived results should have error")
        XCTAssertNotNil(resultsFromGet.dayLogs, "Retrieved day logs should not be nil")
        XCTAssertTrue(resultsFromGet.dayLogs.isEmpty, "Retrived day logs should be empty")
        XCTAssertTrue(resultsFromGet.error?.domain == "JournalManager", "Error domain should be JournalManager")
        XCTAssertTrue(resultsFromGet.error?.code == 4865, "Error code should be 4865")
    }
    
    func testGetEntryForDateWhenMultipleEntries() {
        
        let date = Date()
        _ = journalManager.addEntry(date)
        _ = journalManager.addEntry(date)
        
        let results = journalManager.getEntry(for: date)
        
        XCTAssertNotNil(results.error, "Retrived results should have error")
        XCTAssertNotNil(results.dayLogs, "Retrieved day logs should not be nil")
        XCTAssertTrue(results.dayLogs.count == 2, "Retrived day logs should have 2 entries")
        XCTAssertTrue(results.error?.domain == "JournalManager", "Error domain should be JournalManager")
        XCTAssertTrue(results.error?.code == 5, "Error code should be 5")
        
    }
    func testGetAllEntries() {
        let startingDate = Date()
        for i in 0...5 {
            let logDate = Calendar.current.date(byAdding: .day, value: i, to: startingDate)
            _ = journalManager.addEntry(logDate!)
        }
        let results = journalManager.getAllEntries()
        
        XCTAssertNotNil(results, "Results should not be nil")
        XCTAssertTrue(results.count == 6, "There should be 6 results")
    }
    func testGetAllEntriesAsync() {
        
        let startingDate = Date()
        for i in 0...5 {
            let logDate = Calendar.current.date(byAdding: .day, value: i, to: startingDate)
            _ = journalManager.addEntry(logDate!)
        }
        var testResults: [DayLog]?
        let expectation = self.expectation(description: "ClosureTriggered")
        
        let error = journalManager.getAllEntriesAsync(completionHandler: {
            result in
            guard let finalResults = result.finalResult else { return }
            testResults = finalResults
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertTrue(testResults?.count == 6, "There should be 6 dayLogs")
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