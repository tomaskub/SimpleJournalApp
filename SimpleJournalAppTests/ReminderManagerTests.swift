//
//  ReminderManagerTests.swift
//  SimpleJournalAppTests
//
//  Created by Tomasz Kubiak on 2/13/23.
//

import XCTest
@testable import SimpleJournalApp

final class ReminderManagerTests: XCTestCase {
    
    var sut: ReminderManager!
    let oldData = Reminder.sampleData
    
    
    
    override func setUp() {
        super.setUp()
        sut = ReminderManager()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testDiffFunction_withDataDeletion() throws {
        
        var newData = oldData
        newData.remove(at: 0)
        
        
        let changes = sut.diff(old: oldData, new: newData)
        
        XCTAssert(changes.count == 1, "There should be one change present")
        XCTAssert(changes[0].changeType == .delete, "The change type should be delete")
        XCTAssert(changes[0].reminder.id == oldData[0].id, "The id of the deleted element should be the id of the first element in old array")
    }
    
    func testDiffFunction_withDataInsertion() throws {
        var newData = oldData
        
        let addedReminder = Reminder(
            id: UUID().uuidString,
            title: "This is a newly added reminder",
            dueDate: Date().addingTimeInterval(2200.0),
            notes: "These are notes for the newly added reminder",
            isComplete: false )
        
        newData.insert(addedReminder, at: 2)
        
        let changes = sut.diff(old: oldData, new: newData)
        
        XCTAssert(changes.count == 1, "There should be one change present")
        XCTAssert(changes[0].changeType == .insert, "The change type should be insert")
        XCTAssert(changes[0].reminder.id == addedReminder.id, "The id of the inserted element should be the id of the previously added reminder")
    }
    func testDiffFunction_withDataInsertionAndDataDeletion() throws {
        
        var newData = oldData
        
        newData.remove(at: 0)
        
        let addedReminder = Reminder(
            id: UUID().uuidString,
            title: "This is a newly added reminder",
            dueDate: Date().addingTimeInterval(2200.0),
            notes: "These are notes for the newly added reminder",
            isComplete: false )
        
        newData.insert(addedReminder, at: 2)
        
        let changes = sut.diff(old: oldData, new: newData)
        
        XCTAssert(changes.count == 2, "There should be two changes present")
        
        for change in changes {
            if change.changeType == .insert {
                XCTAssert(change.reminder.id == addedReminder.id, "The id of the inserted element should be the id of the previously added reminder")
            } else if change.changeType == .delete {
                XCTAssert(change.reminder.id == oldData[0].id, "The id of the deleted element should be the id of the first element in old array")
            }
        }
    }
    
    func testDiffFunction_withDataUpdate() throws {
        var newData = oldData
        newData[1].title = "this has changed"
        
        let changes = sut.diff(old: oldData, new: newData)
        
        
        XCTAssert(changes.count == 1, "There should be one change present")
        XCTAssert(changes[0].changeType == .update, "The change type should be .update")
        XCTAssert(changes[0].reminder.title == "this has changed", "The title of updated reminder should be 'this has changed'")
    }
    
    func testDiffFunction_withDataMove() throws {
        var newData = oldData
        newData[1].dueDate = Date().addingTimeInterval(-800.0)
        let idToCheck = newData[1].id
        let changes = sut.diff(old: oldData, new: newData)
        
        
        XCTAssert(changes.count == 1, "There should be one change present")
        XCTAssert(changes[0].changeType == .move, "The change type should be .move")
        XCTAssert(changes[0].reminder.id == idToCheck, "The id of the updated reminder should be equal to idToCheck")
    }
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
