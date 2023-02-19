//
//  ReminderManager.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/11/23.
//


//TODO: Fix error when the controller requests the table reload and not triggering the controller methods - additional issue, due to task construction in data request the updates are not being called from the main thread.

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
    var oldReminders: [Reminder] = []
    var newReminders: [Reminder] = []
    var sortedReminders: [[Reminder]] = []
    var isTaskRunning: Bool = false
    
    var sectionPredicates: [(Reminder) -> Bool] = [
        { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            } else {
                return false
            }
        },
        { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInTomorrow(dueDate)
            } else {
                return false
            }
        },
        { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInYesterday(dueDate)
            } else {
                return false
            }
        }
    
    ]
    
    func processReminders(_ reminders: [Reminder]) -> [[Reminder]] {
        
        
        var yesterday: [Reminder] = []
//        var noDueDate: [Reminder] = []
//        var noDueDateCompleted: [Reminder] = []
        var today: [Reminder] = []
//        var todayCompleted: [Reminder] = []
        var tomorrow: [Reminder] = []
//        var tomorrowCompleted: [Reminder] = []
//        var past: [Reminder] = []
//        var pastCompleted: [Reminder] = []
        var results = [yesterday, today, tomorrow]
        
        for reminder in reminders {
            
            for (i, sectionPredicate) in sectionPredicates.enumerated() {
                if sectionPredicate(reminder) {
                    results[i].append(reminder)
                }
            }
//            if let dueDate = reminder.dueDate {
//                //TODO: how to handle incomplete due date data?
//                if Calendar.current.isDateInToday(dueDate) {
//                    if !reminder.isComplete {
//                        today.append(reminder)
//                    } else {
//                        todayCompleted.append(reminder)
//                    }
//                } else if Calendar.current.isDateInTomorrow(dueDate) {
//                    if !reminder.isComplete { tomorrow.append(reminder) } else { tomorrowCompleted.append(reminder) }
//                } else if dueDate.timeIntervalSinceNow.sign == .minus {
//                    if !reminder.isComplete {
//                        past.append(reminder)
//                    } else {
//                        pastCompleted.append(reminder)
//                    }
//                } else if dueDate.timeIntervalSinceNow.sign == .plus {
//                    future.append(reminder)
//                }
//
//            } else {
//                if !reminder.isComplete {
//                    noDueDate.append(reminder)
//                } else {
//                    noDueDateCompleted.append(reminder)
//                }
            }
            return results
            // sort by due date
            
//            today.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            todayCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            tomorrow.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            tomorrowCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            future.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            past.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//            pastCompleted.sort(by: { $0.dueDate!.compare($1.dueDate!) == .orderedDescending })
//        }
//        //append the completed sorted at the end of a section
//        today.append(contentsOf: todayCompleted)
//        tomorrow.append(contentsOf: tomorrowCompleted)
//        noDueDate.append(contentsOf: noDueDateCompleted)
        //        past.append(contentsOf: pastCompleted)
        
//        return  [past, today, tomorrow, future, noDueDate, pastCompleted]
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
                newFiltered.removeAll(where: {$0.id == id})
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
        if !isTaskRunning {
            oldReminders = newReminders
            Task {
                isTaskRunning = true
                newReminders = try await reminderStore.readAll()
                
                
                let changes = diff(old: oldReminders, new: newReminders)
                
                delegate?.controllerWillChangeContent(self)
                
                for change in changes {
                    
                    switch change.changeType {
                    case .delete:
                        
                        if let indexPathToRemove = indexPath(for: change.reminder.id, in: sortedReminders) {
                            sortedReminders[indexPathToRemove.section].remove(at: indexPathToRemove.row)
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                        }
                        
                    case .insert:
                        let indexPathToInsert = indexPath(toInsert: change.reminder)
                        sortedReminders[indexPathToInsert.section].insert(change.reminder, at: indexPathToInsert.row)
                        delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                    case .update:
                        if let indexPathToUpdate = indexPath(for: change.reminder.id, in: sortedReminders) {
                            sortedReminders[indexPathToUpdate.section][indexPathToUpdate.row] = change.reminder
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToUpdate, for: .update, newIndexPath: nil)
                        }
                    case .move:
                        if let indexPathToRemove = indexPath(for: change.reminder.id, in: sortedReminders) {
                            sortedReminders[indexPathToRemove.section].remove(at: indexPathToRemove.row)
                            
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                        }
                        let indexPathToInsert = indexPath(toInsert: change.reminder)
                        sortedReminders[indexPathToInsert.section].insert(change.reminder, at: indexPathToInsert.row)
                        delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                    }
                }
                delegate?.controllerDidChangeContent(self)
                isTaskRunning = false
            }
        }
    }
    
    func indexPath(for id: String, in sortedReminders: [[Reminder]]) -> IndexPath? {
        
        for (i, array) in sortedReminders.enumerated() {
            for (j, element) in array.enumerated() {
                if element.id == id {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
    //TODO: needs troubleshooting
    func indexPath(toInsert reminder: Reminder) -> IndexPath {
        //        [past, today, tomorrow, future, noDueDate, pastCompleted]
        var row: Int = 0
        var section: Int = 0
        
//        if let dueDate = reminder.dueDate {
            //TODO: how to handle incomplete due date data?
        for (i, sectionPredicate) in sectionPredicates.enumerated() {
            if sectionPredicate(reminder) {
                section = i
                row = sortedReminders[i].count
            }
            }
//            if Calendar.current.isDateInToday(dueDate) {
//                section = 1
//                row = sortedReminders[section].firstIndex(where: {
//                    $0.isComplete == reminder.isComplete && $0.dueDate! < dueDate }) ?? 0
//            } else if Calendar.current.isDateInTomorrow(dueDate) {
//                // tomorrow
//                section = 2
//                row = sortedReminders[section].firstIndex(where: {
//                    $0.isComplete == reminder.isComplete && $0.dueDate! < dueDate }) ?? 0
//            } else if dueDate.timeIntervalSinceNow.sign == .minus {
//                //past
//                section = 0
//                row = sortedReminders[section].firstIndex(where: {
//                    $0.isComplete == reminder.isComplete && $0.dueDate! < dueDate }) ?? 0
//            } else if dueDate.timeIntervalSinceNow.sign == .plus {
//                //future
//                section = 3
//                row = sortedReminders[section].firstIndex(where: {
//                    $0.isComplete == reminder.isComplete && $0.dueDate! < dueDate }) ?? 0
//            }
            
//        } else {
//            section = 4
//            row = sortedReminders[section].firstIndex(where: {
//                $0.isComplete == reminder.isComplete }) ?? 0
//
            
//        }
        return IndexPath(row: row, section: section)
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
    
    func save(_ reminder: Reminder) {
        do {
            _ = try reminderStore.save(reminder)
        } catch {
            print(error)
        }
    }
    
    func removeReminder(for indexPath: IndexPath) {
        
        do {
            let id = try reminder(forIndexPath: indexPath).id
            try reminderStore.remove(with: id)
        } catch ReminderError.reminderForIndexPathDoesNotExist {
            print(ReminderError.reminderForIndexPathDoesNotExist.errorDescription)
        } catch {
            print(error)
        }
        
        
        //Delegate methods
        
    }
}
