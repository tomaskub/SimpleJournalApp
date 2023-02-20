//
//  ReminderManagerSection.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/20/23.
//

import Foundation

class ReminderManagerSection {
    
    var name: String
    var objects: [Reminder]?
    
    var belongingComparator: (Reminder) -> Bool
    
    var numberOfObjects: Int {
        return objects?.count ?? 0
    }
    
    init(name: String, objects: [Reminder]? = nil, comparator: @escaping (Reminder) -> Bool) {
        self.name = name
        self.objects = objects
        self.belongingComparator = comparator
    }
    
}
