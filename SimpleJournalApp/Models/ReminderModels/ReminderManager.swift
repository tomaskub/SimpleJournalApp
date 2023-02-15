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

struct ReminderManagerChange {
    let changeType: ReminderManagerChangeType
    let reminder: Reminder
}

class ReminderManager {
    
    
    private lazy var reminderStore = ReminderStore.shared
    
    var delegate: ReminderManagerDelegate?
    
    var reminders: [IndexPath : Reminder] = [:]
    
    
    var oldReminders: [Reminder] = []
    var newReminders: [Reminder] = []
    var sortedReminders: [[Reminder]] = []
    
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
    
    func processReminders(_ reminders: [Reminder]) -> [[Reminder]] {
        
        
        var future: [Reminder] = []
        var noDueDate: [Reminder] = []
        var noDueDateCompleted: [Reminder] = []
        var today: [Reminder] = []
        var todayCompleted: [Reminder] = []
        var tomorrow: [Reminder] = []
        var tomorrowCompleted: [Reminder] = []
        var past: [Reminder] = []
        var pastCompleted: [Reminder] = []
        
        for reminder in reminders {
            if let dueDate = reminder.dueDate {
                //TODO: how to handle incomplete due date data?
                
                    if Calendar.current.isDateInToday(dueDate) {
                        if !reminder.isComplete {
                            today.append(reminder)
                        } else {
                            todayCompleted.append(reminder)
                        }
                    } else if Calendar.current.isDateInTomorrow(dueDate) {
                        if !reminder.isComplete { tomorrow.append(reminder) } else { tomorrowCompleted.append(reminder) }
                    } else if dueDate.timeIntervalSinceNow.sign == .minus {
                        if !reminder.isComplete {
                            past.append(reminder)
                        } else {
                            pastCompleted.append(reminder)
                        }
                    } else if dueDate.timeIntervalSinceNow.sign == .plus {
                            future.append(reminder)
                    }
                 
            } else {
                if !reminder.isComplete {
                    noDueDate.append(reminder)
                } else {
                    noDueDateCompleted.append(reminder)
                }
                //                if !reminder.isComplete {
                //This only appends reminders that are not completed and have no due date - future uncompleted reminders with dueDate are not appended
                //                    future.append(reminder)
                //                }
            }
            
            // sort by due date
            today.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            todayCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            tomorrow.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            tomorrowCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            future.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            past.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
            pastCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
        }
        //append the completed sorted at the end of a section
        today.append(contentsOf: todayCompleted)
        tomorrow.append(contentsOf: tomorrowCompleted)
        noDueDate.append(contentsOf: noDueDateCompleted)
//        past.append(contentsOf: pastCompleted)
        
        return  [past, today, tomorrow, future, noDueDate, pastCompleted]
    }
    
    func prepareReminderStore() throws {
        Task {
            do {
                try await reminderStore.requestAccess()
                newReminders = try await reminderStore.readAll()
//                reminders = processReminders(tempReminders)
                sortedReminders = processReminders(newReminders)
                delegate?.requestUIUpdate()
            } catch {
                throw error
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot), name: .EKEventStoreChanged, object: nil)
    }
    
    //TODO: Review below - think about using tableView.indexPathForVisibleRows to not check changes for all of the data. For this to work it might be neccessary to make the reminder.id equal to ekReminder.calendarItemIdentifier (it is when it pulled from calendar)
    
    func diff(old: [Reminder], new: [Reminder]) -> [ReminderManagerChange] {
        
        var changes: [ReminderManagerChange] = []
        var oldFiltered = old
        var newFiltered = new
        // handle removed and added reminders by ids
        
        let oldIDSet = Set(old.map { $0.id })
        let newIDSet = Set(new.map { $0.id })
        let inserted = newIDSet.subtracting(oldIDSet)
        let deleted = oldIDSet.subtracting(newIDSet)
        
        for id in inserted {
            if let reminder = new.first(where: { $0.id == id}) {
                changes.append(ReminderManagerChange(changeType: .insert, reminder: reminder))
                newFiltered.removeAll(where: {$0 == reminder})
            }
        }
        
        for id in deleted {
            if let i = old.firstIndex(where: { $0.id == id}) {
                changes.append(ReminderManagerChange(changeType: .delete, reminder: old[i]))
                oldFiltered.removeAll(where: {$0 == old[i]})
            }
        }
        
        
        //Define updated as new objects that are not in old objects
        let updated = newFiltered.filter( { !oldFiltered.contains($0) })
        for reminder in updated {
            //the cases are:
            //the content changed but the date is the same
            //the content is the same but the date changed
            //The content is different and the date changed
            
            if let oldReminder = old.first(where: {$0.id == reminder.id }) {
                if oldReminder.dueDate == reminder.dueDate {
                    
                    changes.append(ReminderManagerChange(changeType: .update, reminder: reminder))
                    
                } else if oldReminder.isComplete != reminder.isComplete ||
                            oldReminder.title != reminder.title ||
                            oldReminder.notes != reminder.notes {
                    
                    changes.append(ReminderManagerChange(changeType: .update, reminder: reminder))
                    changes.append(ReminderManagerChange(changeType: .move, reminder: reminder))
                    
                } else {
                    
                    changes.append(ReminderManagerChange(changeType: .move, reminder: reminder))
                    
                } // missing edge case where any of the properties changes, also with the due date
            }
        }
        return changes
    }
    
    
    
    @objc func updateSnapshot() {
        Task {
            oldReminders = newReminders
            newReminders = try await reminderStore.readAll()
            let changes = diff(old: oldReminders, new: newReminders)
            
            delegate?.controllerWillChangeContent(self)
            for change in changes {
                /*
                switch change.changeType {
                case .delete:
                    //find the section where the changing reminder should be
                    //Find which index it has
                    //Remove at index
                    //pass the index to the controller call
                case .insert:
                    //find the section
                    //Find at which index should it be
                    //insert it at the right index
                    //pass the new index path to the controller call
                    case .update:
                    //find the section
//                    find which index it has
//                    update data in index,
//                    pass intex to the controller call
                case .move:
//                    this also gets into update since diff does not take that into account
                    // find the right section for the new data
                    // provide old and new index with sections
                    // pass to controller
                }
                */
                
                
                
//                delegate?.controller(self, didChange: change.reminder, at: <#T##IndexPath?#>, for: change.changeType, newIndexPath: <#T##IndexPath?#>)
            }
            
            delegate?.controllerDidChangeContent(self)
            delegate?.requestUIUpdate()
        }
    }
    
    func reminder(forIndexPath indexPath: IndexPath) throws -> Reminder {
//        guard let reminder = reminders[indexPath] else { throw ReminderError.reminderForIndexPathDoesNotExist }
        
        guard sortedReminders.indices.contains(indexPath.section),
                sortedReminders[indexPath.section].indices.contains(indexPath.row) else {
            print("reminder for index path throw - Reminder for indexpath \(indexPath) does not exist")
            throw ReminderError.reminderForIndexPathDoesNotExist }
        
        return sortedReminders[indexPath.section][indexPath.row]
    }
    
    func updateReminder(atIndexPath indexPath: IndexPath) throws {
//        guard var reminder = reminders[indexPath] else { throw ReminderError.reminderForIndexPathDoesNotExist }
        guard sortedReminders.indices.contains(indexPath.section),
                sortedReminders[indexPath.section].indices.contains(indexPath.row) else {
            print("Update reminder throw - Reminder for indexpath \(indexPath) does not exist")
            throw ReminderError.reminderForIndexPathDoesNotExist
        }
        var reminder = sortedReminders[indexPath.section][indexPath.row]
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
