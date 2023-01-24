//
//  JournalManager.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/23/23.
//

import Foundation
import CoreData

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
        
        //TODO: Add date implementation
        dayLog.date = Calendar.current.startOfDay(for: date)
        dayLog.id = UUID()
        
        coreDataStack.saveContext()
        
        return dayLog
    }
    
    func updateEntry(for date: Date, with dayLog: DayLog){
        
    }
    
    func deleteEntry(for date: Date) {
            //TODO: add function to delete entry
    }
    
    func deleteEntry(with id: UUID) {
        //TODO: add function to delete entry
    }
    
    func deleteEntry(entry: DayLog) {
        //TODO: add function to delete entry
    }
    
    func deleteAllEntries() {
        
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
                error = NSError(domain: "JournalManager", code: 4865, userInfo: ["Problem" : "Day log log date not found"])
            } else if retrivedDayLogs.count > 1 {
                error = NSError(domain: "JournalManager", code: 5, userInfo: ["Problem" : "Retrived multiple day logs"])
            }
        } catch let _error as NSError {
            error = _error
        }
        return (retrivedDayLogs, error)
    }
    
    func getAllEntries() -> [DayLog] {
        
        return []
    }
    
    func addAnswer(to dayLog: DayLog, for question: String, answer: String) {
        
    }
    func deleteAnswer(answer: Answer) {
        
    }
    func updateAnswer(of: DayLog, for question: String, with answer: String){
        
    }
}

