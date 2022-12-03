//
//  DayLog+CoreDataProperties.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/3/22.
//
//

import Foundation
import CoreData


extension DayLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayLog> {
        return NSFetchRequest<DayLog>(entityName: "DayLog")
    }

    @NSManaged public var answers: [String]?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?

}

extension DayLog : Identifiable {

}
