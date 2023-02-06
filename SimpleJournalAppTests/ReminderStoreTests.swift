//
//  ReminderStoreTests.swift
//  SimpleJournalAppTests
//
//  Created by Tomasz Kubiak on 2/6/23.
//
import EventKit
import XCTest
@testable import SimpleJournalApp

final class ReminderStoreTests: XCTestCase {
    
    var sut: ReminderStore!
    
    override func setUp() {
        super.setUp()
        sut = ReminderStore.shared
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        
    }
    
    //Have to set the access to allowed in simulator settings before
    func testRequestAccess() throws {
        let expectation = self.expectation(description: "RequestedAcess")
        
        
        Task {
            do {
                try await sut.requestAccess()
                expectation.fulfill()
            } catch { }
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssert(sut.isAvaliable == true, "isAvaliable should be true")
        
    }
    
    //Have to set the access to denied in simulator settings before
    func testRequestAccess_whenAccessDenied(){
        
        let expectation = self.expectation(description: "RequestedAcess")
        
        Task {
            do {
                try await sut.requestAccess()
            } catch {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssert(sut.isAvaliable == false, "isAvaliable should be false")
        
    }
    
    func testReadAll() async throws {
        let reminders = try await sut.readAll()
        
        XCTAssert(reminders.count > 0, "There should be more than 0 reminders")
    }
    
    func testSave() throws {
        var idToRetrive: String?
        let reminderToSave = Reminder(title: "Submit reimbursement report",
                                      dueDate: Date().addingTimeInterval(800.0),
                                      notes: "Don't forget about taxi receipts")
        do {
            idToRetrive = try sut.save(reminderToSave)
        } catch {
            XCTFail("Error occured when saving")
        }
        
        XCTAssertNotNil(idToRetrive, "ID should not be nil")
    }
    
    func testReadWithId() throws {
        var idToRetrive: String?
        let reminderToSave = Reminder(title: "Submit reimbursement report",
                                      dueDate: Date().addingTimeInterval(800.0),
                                      notes: "Don't forget about taxi receipts")
        var retrivedReminder: EKReminder?
        do {
            idToRetrive = try sut.save(reminderToSave)
            if let idToRetrive {
                retrivedReminder = try sut.read(with: idToRetrive)
            }
        } catch let error {
            throw error
        }
        
        XCTAssertNotNil(retrivedReminder, "Retrived reminder should not be nil")
    }
    
    func testRemoveWithID() throws {
        var idToRemove: String?
        let reminderToSave = Reminder(title: "Submit reimbursement report",
                                      dueDate: Date().addingTimeInterval(800.0),
                                      notes: "Don't forget about taxi receipts")
        var expectedError: ReminderError?
        do {
            idToRemove = try sut.save(reminderToSave)
            if let idToRemove {
                try sut.remove(with: idToRemove)
                _ = try sut.read(with: idToRemove)
            }
        } catch let error as ReminderError {
                expectedError = error
        } catch {
            throw error
        }
        
        XCTAssert(expectedError == .failedReadingCalendarItem, "Error type should be failedReadingCalendarError")
    }
    func testRemoveAll() async throws {
        var expectedError: ReminderError?
        var reminders: [Reminder]?
        do {
            try await sut.removeAll()
            reminders = try await sut.readAll()
        } catch let error as ReminderError {
            expectedError = error
        } catch {
            throw error
        }
        
        XCTAssertNil(expectedError, "Error type should be nil")
        XCTAssert(reminders?.count == 0, "There should be not items in reminders")
        
    }
}
