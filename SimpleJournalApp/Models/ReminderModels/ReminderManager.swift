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
    var numberOfObjects: Int { get }
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
    
//    var oldReminders: [Reminder] = []
    var newReminders: [Reminder] = []
    
    var isTaskRunning: Bool = false
    
//    var sortedReminders: [[Reminder]] = []
    
    lazy var sectionTitles: [String] = {
        return sections.map { $0.name }
    }()
    
    var sections: [ReminderManagerSection]
    
    
    init() {
        sections = [ ReminderManagerSection(name: "Yesterday", comparator: { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInYesterday(dueDate)
            } else {
                return false
            }
        }),
        ReminderManagerSection(name: "Today", comparator: { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            } else {
                return false
            }
        }),
                     ReminderManagerSection(name: "Tomorrow", comparator: { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInTomorrow(dueDate)
            } else {
                return false
            }
        })]
    }
    
    //done for sections
    func processReminders(_ reminders: [Reminder]){
        
        for reminder in reminders {
            for section in sections {
                if section.belongingComparator(reminder) {
                    if section.objects == nil {
                        section.objects = []
                    }
                    section.objects?.append(reminder)
                }
            }
        }
    }
    
    //done for sections
    func prepareReminderStore() throws {
        Task {
            do {
                try await reminderStore.requestAccess()
                newReminders = try await reminderStore.readAll()
                //                reminders = processReminders(tempReminders)
                processReminders(newReminders)
                delegate?.requestUIUpdate()
            } catch {
                throw error
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot), name: .EKEventStoreChanged, object: nil)
    }
    
    //TODO: Review below - think about using tableView.indexPathForVisibleRows to not check changes for all of the data. For this to work it might be neccessary to make the reminder.id equal to ekReminder.calendarItemIdentifier (it is when it pulled from calendar)
    //seems ok?
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
            let oldReminders = newReminders
            Task {
                //still need to check for failures
                isTaskRunning = true
                newReminders = try await reminderStore.readAll()
                let changes = diff(old: oldReminders, new: newReminders)
                
                //change is done for sections
                delegate?.controllerWillChangeContent(self)
                for change in changes {
                    
                    switch change.changeType {
                    case .delete:
                        //crashed on delete? - works if not optional if let var
                        if let indexPathToRemove = indexPath(for: change.reminder.id) {
                            sections[indexPathToRemove.section].objects?.remove(at: indexPathToRemove.row)
                            
//                            sortedReminders[indexPathToRemove.section].remove(at: indexPathToRemove.row)
                            
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                        }
                        
                    case .insert:
                        //works after different unwrapping
                        let indexPathToInsert = indexPath(toInsert: change.reminder)
                        
                        if sections[indexPathToInsert.section].objects != nil {
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        } else {
                            sections[indexPathToInsert.section].objects = []
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        }
//                        sortedReminders[indexPathToInsert.section].insert(change.reminder, at: indexPathToInsert.row)
                        delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                        
                    case .update:
                        if let indexPathToUpdate = indexPath(for: change.reminder.id) {
                            sections[indexPathToUpdate.section].objects?[indexPathToUpdate.row] = change.reminder
//                            sortedReminders[indexPathToUpdate.section][indexPathToUpdate.row] = change.reminder
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToUpdate, for: .update, newIndexPath: nil)
                        }
                    case .move:
                        if let indexPathToRemove = indexPath(for: change.reminder.id) {
                            sections[indexPathToRemove.section].objects?.remove(at: indexPathToRemove.row)
//                            sortedReminders[indexPathToRemove.section].remove(at: indexPathToRemove.row)
                            
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                        }
                        let indexPathToInsert = indexPath(toInsert: change.reminder)
                        if sections[indexPathToInsert.section].objects != nil {
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        } else {
                            sections[indexPathToInsert.section].objects = []
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        }
//                        sortedReminders[indexPathToInsert.section].insert(change.reminder, at: indexPathToInsert.row)
                        delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                    }
                }
                delegate?.controllerDidChangeContent(self)
                isTaskRunning = false
            }
        }
    }
    // done for sections
    func indexPath(for id: String) -> IndexPath? {
        
        for (i, section) in sections.enumerated() {
            if let objectsArray = section.objects {
                for (j, element) in objectsArray.enumerated() {
                    if element.id == id {
                        return IndexPath(row: j, section: i)
                    }}
            }
        }
        return nil
    }
    //done for sections
    func indexPath(toInsert reminder: Reminder) -> IndexPath {

        var rowForIndex: Int = 0
        var sectionForIndex: Int = 0
        
        //TODO: Transfer the search of row to section
        for (i, section) in sections.enumerated() {
            if section.belongingComparator(reminder) {
                sectionForIndex = i
                rowForIndex = section.numberOfObjects
            }
        }
        return IndexPath(row: rowForIndex, section: sectionForIndex)
    }
    //done for sections
    func reminder(forIndexPath indexPath: IndexPath) throws -> Reminder {
        //        guard let reminder = reminders[indexPath] else { throw ReminderError.reminderForIndexPathDoesNotExist }
        
        guard sections.indices.contains(indexPath.section),
              let objects = sections[indexPath.section].objects,
              objects.indices.contains(indexPath.row) else {
            print("reminder for index path throw - Reminder for indexpath \(indexPath) does not exist")
            throw ReminderError.reminderForIndexPathDoesNotExist
        }
        // guard above throws if objects is nil so it is safe to force unwrap it
        return sections[indexPath.section].objects![indexPath.row]
    }
    //done for sections
    func updateReminder(atIndexPath indexPath: IndexPath) throws {
        var reminder =  try reminder(forIndexPath: indexPath)
        reminder.isComplete.toggle()
            _ = try reminderStore.save(reminder)
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
    }
}

    //MARK: move this to definition of the sections in RemindersTableViewController
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
//        }
        
