//
//  EKReminder.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import Foundation
import EventKit

extension EKReminder {
    func update(using reminder: Reminder, in store: EKEventStore) {
        title = reminder.title
        notes = reminder.notes
        isCompleted = reminder.isComplete
        calendar = store.defaultCalendarForNewReminders()
        alarms?.forEach({ alarm in
            guard let absoluteDate = alarm.absoluteDate else { return }
            let comparision = Locale.current.calendar.compare(reminder.dueDate, to: absoluteDate, toGranularity: .minute)
            if comparision != .orderedSame {
                removeAlarm(alarm)
            }
        })
        if !hasAlarms {
            addAlarm(EKAlarm(absoluteDate: reminder.dueDate))
        }
    }
}
