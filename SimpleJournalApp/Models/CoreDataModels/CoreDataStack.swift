//
//  CoreDataStack.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/15/23.
//

import Foundation
import CoreData

open class CoreDataStack {
    let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error: \(error), description: \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return storeContainer.viewContext
    }()
    
    func saveContext() {
        
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error: \(error), description: \(error.userInfo)")
        }
    }
}
