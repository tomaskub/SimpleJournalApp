//
//  Answer+CoreDataProperties.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/25/22.
//
//

import Foundation
import CoreData


extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer")
    }
    @NSManaged public var text: String?
    @NSManaged public var dayLog: DayLog?
    
    @NSManaged fileprivate var questionValue: String
    
    public var question: Question {
        get {
            return Question(rawValue: questionValue) ?? .summary
        }
        set {
            questionValue = newValue.rawValue
        }
    }
    
    
}

extension Answer : Identifiable {

}
