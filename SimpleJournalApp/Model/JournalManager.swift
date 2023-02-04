//
//  JournalManager.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/23/23.
//

import Foundation
import CoreData

enum JournalManagerNSError: Error {
    case noResultsRetrived
    case multipleResultsRetrived
    case asyncFetchFailed
}

public final class JournalManager {
    
    
    
    //MARK: Properties
    
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    //MARK: Initializers
    
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}

extension JournalManager {
    
    /// Add entry for a specific date and return it - if a entry for a date already exists, return existing dayLog
    /// - Parameter date: date for the DayLog
    /// - Returns: created or retrived DayLog
    func addEntry(_ date: Date) -> DayLog {
        var dayLog: DayLog!
        let results = getEntry(for: date)
        
        guard let error = results.error as? JournalManagerNSError else {
            dayLog = results.dayLogs.first
            return dayLog
        }
        switch error {
        case .noResultsRetrived:
            dayLog = DayLog(context: managedObjectContext)
            
            dayLog.date = Calendar.current.startOfDay(for: date)
            dayLog.id = UUID()
            
            coreDataStack.saveContext()
        case .multipleResultsRetrived:
            print("Multiple dayLogs retrived, return 1st")
            dayLog = results.dayLogs.first
        default:
            print("error occured: \(error), \(error.userInfo)")
        }
        return dayLog
    }
    
    func deleteEntry(for date: Date) {
        
        let results = getEntry(for: date)
        
        if let error = results.error as? JournalManagerNSError {
            switch error {
            case .noResultsRetrived:
                return
            case .multipleResultsRetrived:
                print("Error occured while searching for logs to delete: \(error): \(error.userInfo)")
            default:
                print("An error occured: \(error)")
            }
        }
        
        for log in results.dayLogs {
            do{
                self.managedObjectContext.delete(log)
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Error occured: \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteEntry(with id: UUID) {
        
        let response = getEntry(with: id)
        
        if let error = response.error as? JournalManagerNSError {
            if error == .noResultsRetrived { return }
            else if error == .multipleResultsRetrived {
                print("Multiple ID for the entries - this is serious problem")
            }
        }
        
        let entryToDelete = response.dayLog
        do {
            self.managedObjectContext.delete(entryToDelete!)
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error occured: \(error), \(error.userInfo)")
        }
    }
    
    func deleteEntry(entry: DayLog) {
        do {
            self.managedObjectContext.delete(entry)
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error occured: \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteAllEntries() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        
        var retrivedDayLogs: [DayLog]
        
        do {
            retrivedDayLogs = try managedObjectContext.fetch(request)
            for log in retrivedDayLogs {
                self.managedObjectContext.delete(log)
            }
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error occured: \(error), \(error.userInfo)")
        }
        
    }
    
    
    /// Retrive all dayLogs for a given day containing a date based on the current calenar of the user
    /// - Parameter date: Any date, in a specific day
    /// - Returns: dayLogs: an array of DayLogs retrieved
    /// error: NSError if any present
    func getEntry(for date: Date) -> (dayLogs: [DayLog], error: NSError?) {
        //Create request
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        //Create dates for begining of the day and end of a day
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)
        //Create sub predicates and compond predicate
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        //add predicate to the request
        request.predicate = datePredicate
        
        var error: NSError?
        var retrivedDayLogs: [DayLog] = []
        //Retrive day logs for that date and create error
        do {
            retrivedDayLogs = try managedObjectContext.fetch(request)
            if retrivedDayLogs.isEmpty {
                error = JournalManagerNSError.noResultsRetrived as NSError
            } else if retrivedDayLogs.count > 1 {
                error = JournalManagerNSError.multipleResultsRetrived as NSError
            }
        } catch let _error as NSError {
            error = _error
        }
        return (retrivedDayLogs, error)
    }
    
    func getEntry(with id: UUID) -> (dayLog: DayLog?, error: NSError? ) {
        var dayLog: DayLog?
        var error: NSError?
        
        //Create request
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        //add predicate to the request
        request.predicate = predicate
        
        
        var retrivedDayLogs: [DayLog] = []
        //Retrive day logs for that ID and create error
        do {
            retrivedDayLogs = try managedObjectContext.fetch(request)
            if retrivedDayLogs.isEmpty {
                error = JournalManagerNSError.noResultsRetrived as NSError
            } else if retrivedDayLogs.count > 1 {
                error = JournalManagerNSError.multipleResultsRetrived as NSError
            }
            dayLog = retrivedDayLogs.first
        } catch let _error as NSError {
            error = _error
        }
        return (dayLog, error)
        
    }
    
    /// Fetch all dayLogs in context of the journal manager
    /// - Returns: an array of DayLog objects
    func getAllEntries() -> [DayLog] {
        let request : NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(DayLog.date), ascending: false)
        request.sortDescriptors = [sort]
        var results: [DayLog] = []
        
        do {
            results = try managedObjectContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch \(error)m \(error.userInfo)")
        }
        return results
        
        
    }
    
    
    func getAllEntriesAsync(completionHandler: @escaping((NSAsynchronousFetchResult<DayLog>) -> Void)) -> NSError? {
        
        var asyncFetchRequest: NSAsynchronousFetchRequest<DayLog>?
        let request : NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(DayLog.date), ascending: false)
        
        request.sortDescriptors = [sort]
        
        asyncFetchRequest = NSAsynchronousFetchRequest<DayLog>(fetchRequest: request) {
            (result: NSAsynchronousFetchResult) in
            completionHandler(result)
        }
        do {
            guard let asyncFetchRequest = asyncFetchRequest else { return JournalManagerNSError.asyncFetchFailed as NSError }
            try managedObjectContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            return error
        }
        return nil
    }
    
    func addAnswer(to dayLog: DayLog, for question: Question, text: String, updateExistingAnswers: Bool = true) {
        //TODO: add parameter to recognize when updating answer is wanted or to create a second answer
        if updateExistingAnswers == true {
            let existingAnswers = dayLog.answers?.allObjects as! [Answer]
            if let i = existingAnswers.firstIndex(where: {$0.question == question}) {
                existingAnswers[i].text = text
            } else {
                let answerToAdd = Answer(context: managedObjectContext)
                answerToAdd.question = question
                answerToAdd.text = text
                answerToAdd.dayLog = dayLog
            }
        } else {
            let answerToAdd = Answer(context: managedObjectContext)
            answerToAdd.question = question
            answerToAdd.text = text
            answerToAdd.dayLog = dayLog
        }
        coreDataStack.saveContext()
    }
    
    func addPhoto(jpegData: Data, to dayLog: DayLog) {
        dayLog.photo = jpegData
        coreDataStack.saveContext()
    }
    
    func getPhoto(for dayLog: DayLog) -> Data? {
        return dayLog.photo
    }
    func deletePhoto(entry: DayLog) {
        do {
            entry.photo = nil
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error occured: \(error), \(error.userInfo)")
        }
    }
    
    func deleteAnswer(answer: Answer) {
        
    }
    
    func updateAnswer(of: DayLog, for question: Question, with answer: String){
        
    }
}

