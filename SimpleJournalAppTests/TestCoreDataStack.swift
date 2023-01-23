//
//  TestCoreDataStack.swift
//  SimpleJournalAppTests
//
//  Created by Tomasz Kubiak on 1/20/23.
//

import Foundation
@testable import SimpleJournalApp
import CoreData

class TestCoreDataStack: CoreDataStack {
    
    override init(modelName: String) {
        super.init(modelName: modelName)
        
        let container = NSPersistentContainer(name: modelName)//, managedObjectModel: CoreDataStack.model)
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        
        container.loadPersistentStores { (_, error) in
          if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
          }
        }
        self.storeContainer = container
    }
}
