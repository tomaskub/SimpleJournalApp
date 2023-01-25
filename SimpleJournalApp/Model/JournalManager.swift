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
    func addEntry(_ date: Date) -> DayLog {
        let dayLog = DayLog(context: managedObjectContext)
        
        dayLog.date = Calendar.current.startOfDay(for: date)
        dayLog.id = UUID()
        
        coreDataStack.saveContext()
        
        return dayLog
    }
    
    func updateEntry(for date: Date, with dayLog: DayLog){
        
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
        //TODO: add function to delete entry
    }
    
    func deleteEntry(entry: DayLog) {
        //TODO: add function to delete entry
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
        
    
    func addAnswer(to dayLog: DayLog, for question: String, answer: String) {
        
    }
    func deleteAnswer(answer: Answer) {
        
    }
    func updateAnswer(of: DayLog, for question: String, with answer: String){
        
    }
}

