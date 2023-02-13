//
//  ReminderManager.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/11/23.
//

import Foundation

protocol ReminderManagerDelegate {
    func requestUIUpdate()
    func controllerWillChangeContent(_ controller: ReminderManager)
    func controllerDidChangeContent(_ controller: ReminderManager)
    func controller(_ controller: ReminderManager, didChange aReminder: Reminder, at indexPath: IndexPath?, for type: ReminderManagerChangeType, newIndexPath: IndexPath?)
    func controller(_ controller: ReminderManager, didChange sectionInfo: ReminderResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: ReminderManagerChangeType)
}

protocol ReminderResultsSectionInfo {
    var numberOfObject: Int { get }
    var objects: [Reminder]? { get }
    var name: String { get }
    var indexTitle: String? { get }
}

enum ReminderManagerChangeType {
    case insert
    case delete
    case update
    case move
}

class ReminderManager {
    
    
    private lazy var reminderStore = ReminderStore.shared
    
    var delegate: ReminderManagerDelegate?
    
    var reminders: [IndexPath : Reminder] = [:]
    
    func processReminders(_ reminders: [Reminder]) -> [IndexPath : Reminder] {
        
        var temp: [IndexPath : Reminder] = [:]
        var future: [Reminder] = []
        var noDueDate: [Reminder] = []
        var today: [Reminder] = []
        var tomorrow: [Reminder] = []
        var past: [Reminder] = []
        for reminder in reminders {
            if let dueDate = reminder.dueDate {
                if Calendar.current.isDateInToday(dueDate) {
                    today.append(reminder)
                } else if Calendar.current.isDateInTomorrow(dueDate) {
                    tomorrow.append(reminder)
                } else if dueDate.timeIntervalSinceNow.sign == .minus {
                    //due date is in the past
                    past.append(reminder)
                } else if dueDate.timeIntervalSinceNow.sign == .plus {
                    future.append(reminder)
                }
            } else {
                noDueDate.append(reminder)
//                if !reminder.isComplete {
                    //This only appends reminders that are not completed and have no due date - future uncompleted reminders with dueDate are not appended
//                    future.append(reminder)
//                }
            }
            
            today.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            for (i, reminder) in today.enumerated() {
                temp[IndexPath(row: i, section: 0)] = reminder
            }
            tomorrow.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending})
            for (i, reminder) in tomorrow.enumerated() {
                temp[IndexPath(row: i, section: 1)] = reminder
            }
            future.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending})
            for (i, reminder) in future.enumerated() {
                temp[IndexPath(row: i, section: 2)] = reminder
            }
            for (i, reminder) in noDueDate.enumerated() {
                temp[IndexPath(row: i, section: 3)] = reminder
            }
            for (i, reminder) in past.enumerated() {
                temp[IndexPath(row: i, section: 4)] = reminder
            }
        }
        return temp
    }
    
    func prepareReminderStore() throws {
        Task {
            do {
                try await reminderStore.requestAccess()
                let tempReminders = try await reminderStore.readAll()
                reminders = processReminders(tempReminders)
                delegate?.requestUIUpdate()
            } catch {
                throw error
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot), name: .EKEventStoreChanged, object: nil)
    }
    
    func numbersOfSections() -> Int {
        
        let keys = reminders.keys
        var max = 0
        
        for key in keys {
            if key.section > max {
                max = key.section
            }
        }
        
        return max+1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        var count: Int = 0
        for key in reminders.keys {
            if key.section == section {
                count += 1
            }
        }
        return count
    }
    
    @objc func updateSnapshot() {
        Task {
            let tempReminders = try await reminderStore.readAll()
            reminders = processReminders(tempReminders)
            delegate?.requestUIUpdate()
        }
    }
    
    func reminder(forIndexPath indexPath: IndexPath) throws -> Reminder {
        guard let reminder = reminders[indexPath] else { throw ReminderError.reminderForIndexPathDoesNotExist }
        return reminder
    }
    
    func updateReminder(atIndexPath indexPath: IndexPath) throws {
        guard var reminder = reminders[indexPath] else { throw ReminderError.reminderForIndexPathDoesNotExist }
        reminder.isComplete.toggle()
        do {
            _ = try reminderStore.save(reminder)
        } catch {
            print(error)
        }
    }
    
    func removeReminder(for indexPath: IndexPath) {
        guard let id = reminders[indexPath]?.id else { return }
        do {
            try reminderStore.remove(with: id)
            reminders.removeValue(forKey: indexPath)
        } catch {
            print(error)
        }
    }
    
    //Delegate methods
    
}
