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
    
    var newReminders: [Reminder] = []
    var sections: [ReminderManagerSection]
    
    
    var isTaskRunning: Bool = false
    
    lazy var numberOfSections = {
        return sections.count
    }()
    lazy var sectionTitles: [String] = {
        return sections.map { $0.name }
    }()
    
    init(sectionNames names: [String], comparators comp: [(Reminder) -> Bool]) {
        self.sections = []
        for (i, name) in names.enumerated() {
            var section = ReminderManagerSection(name: name, comparator: comp[i])
            sections.append(section)
        }
        
    }
    
    convenience init() {
        let names = ["Yesterday", "Today", "Tomorrow"]
        let comparators: [(Reminder) -> Bool] = [
            { reminder in
                if let dueDate = reminder.dueDate {
                    return Calendar.current.isDateInYesterday(dueDate)
                } else { return false } },
            { reminder in
            if let dueDate = reminder.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            } else { return false } },
            { reminder in
                if let dueDate = reminder.dueDate {
                    return Calendar.current.isDateInTomorrow(dueDate)
                } else { return false } }
            ]
        
        self.init(sectionNames: names, comparators: comparators)
    }
    
    func processReminders(_ reminders: [Reminder]){
        
        for reminder in reminders {
            for section in sections {
                if section.belongingComparator(reminder) {
                    if section.objects == nil {
                        section.objects = []
                    }
                    section.objects?.append(reminder)
                }
                section.objects?.sort(by: { (lhs, rhs) -> Bool in
                    if lhs.isComplete != rhs.isComplete {
                        return !lhs.isComplete
                    } else {
                        if let lhsDueDate = lhs.dueDate, let rhsDueDate = rhs.dueDate {
                            return lhsDueDate < rhsDueDate
                        } else if lhs.dueDate != nil {
                            return true
                        } else {
                            return false
                        }
                    }
                })
            }
        }
    }
    
    func prepareReminderStore(completionHandler: ( ()-> Void )? = nil ) throws {
        Task {
            do {
                try await reminderStore.requestAccess()
                newReminders = try await reminderStore.readAll()
                //                reminders = processReminders(tempReminders)
                processReminders(newReminders)
                delegate?.requestUIUpdate()
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            } catch {
                throw error
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot), name: .EKEventStoreChanged, object: nil)
    }
    
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
            //the content changed but the date is the same -> update
            //the content is the same but the date changed -> move
            //The content is different and the date changed -> update & move
            
            if let oldReminder = old.first(where: {$0.id == reminder.id }) {
                if oldReminder.dueDate == reminder.dueDate &&  oldReminder.isComplete == reminder.isComplete {
                    
                    changes.append(ReminderManagerChange(changeType: .update, reminder: reminder))
                    
                } else if oldReminder.isComplete != reminder.isComplete ||
                            oldReminder.title != reminder.title ||
                            oldReminder.notes != reminder.notes {
                    
                    changes.append(ReminderManagerChange(changeType: .update, reminder: reminder))
                    changes.append(ReminderManagerChange(changeType: .move, reminder: reminder))
                    
                } else {
                    
                    changes.append(ReminderManagerChange(changeType: .move, reminder: reminder))
                    
                }
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
                        
                        if let indexPathToRemove = indexPath(for: change.reminder.id) {
                            sections[indexPathToRemove.section].objects?.remove(at: indexPathToRemove.row)
                            delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                        }
                        
                    case .insert:
                        
                        let indexPathToInsert = indexPath(toInsert: change.reminder)
                        
                        if sections[indexPathToInsert.section].objects != nil {
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        } else {
                            sections[indexPathToInsert.section].objects = []
                            sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                        }
                        
                        delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                        
                    case .update:
                        if let indexPathToUpdate = indexPath(for: change.reminder.id) {
                            sections[indexPathToUpdate.section].objects?[indexPathToUpdate.row] = change.reminder

                            delegate?.controller(self, didChange: change.reminder, at: indexPathToUpdate, for: .update, newIndexPath: nil)
                        }
                    case .move:
                        
                        
                        if let indexPathToRemove = indexPath(for: change.reminder.id) {
                            
                            sections[indexPathToRemove.section].objects?.remove(at: indexPathToRemove.row)
                            
                            let indexPathToInsert = indexPath(toInsert: change.reminder)
                            if sections[indexPathToInsert.section].objects != nil {
                                sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                            } else {
                                sections[indexPathToInsert.section].objects = []
                                sections[indexPathToInsert.section].objects?.insert(change.reminder, at: indexPathToInsert.row)
                            }
                            
                            if indexPathToRemove != indexPathToInsert {
                                delegate?.controller(self, didChange: change.reminder, at: indexPathToRemove, for: .delete, newIndexPath: nil)
                                delegate?.controller(self, didChange: change.reminder, at: nil, for: .insert, newIndexPath: indexPathToInsert)
                            }
                        }

                    }
                }
                delegate?.controllerDidChangeContent(self)
                isTaskRunning = false
            }
        }
    }

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

    func indexPath(toInsert reminder: Reminder) -> IndexPath {
        
        var rowForIndex: Int = 0
        var sectionForIndex: Int = 0
        
        for (i, section) in sections.enumerated() {
            if section.belongingComparator(reminder) {
                sectionForIndex = i
                
                if let objects = section.objects {
                    rowForIndex = objects.firstIndex(where: {
                        if $0.isComplete != reminder.isComplete {
                            return $0.isComplete
                        } else {
                            if let lhsDueDate = $0.dueDate, let rhsDueDate = reminder.dueDate {
                                return lhsDueDate < rhsDueDate
                            } else if $0.dueDate != nil {
                                return true
                            } else {
                                return false
                            }
                        }
                    }) ?? objects.count // if all the due dates are the same in completed reminders insert at the end
                    
                } else {
                    rowForIndex = 0
                }
            }
        }
            return IndexPath(row: rowForIndex, section: sectionForIndex)
        }
        

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
        
