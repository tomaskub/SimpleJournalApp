//
//  Reminder.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import Foundation

struct Reminder: Equatable, Identifiable {
    var id: String = UUID().uuidString
    var titile: String
    var dueDate: Date
    var notes: String? = nil
    var isComplete: Bool = false
}

extension [Reminder] {
    func indexOfReminder(withID id: Reminder.ID) -> Self.Index {
        guard let index = firstIndex(where: {$0.id == id}) else { fatalError() }
        return index
    }
}
