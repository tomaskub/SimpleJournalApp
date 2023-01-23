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
    
    func getEntry(for date: Date) -> DayLog? {
        return nil
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

