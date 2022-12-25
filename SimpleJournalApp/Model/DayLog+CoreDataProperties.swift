//
//  DayLog+CoreDataProperties.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/25/22.
//
//

import Foundation
import CoreData


extension DayLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayLog> {
        return NSFetchRequest<DayLog>(entityName: "DayLog")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var answers: NSSet?

}

// MARK: Generated accessors for answers
extension DayLog {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}

extension DayLog : Identifiable {

}
