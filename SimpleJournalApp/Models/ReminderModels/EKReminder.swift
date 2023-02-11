//
//  EKReminder.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import Foundation
import EventKit

extension EKReminder {
    func update(using reminder: Reminder, in store: EKEventStore, using ekCalendar: EKCalendar? = nil) {
        title = reminder.title
        notes = reminder.notes
        isCompleted = reminder.isComplete
        
        if let ekCalendar = ekCalendar {
            calendar = ekCalendar
        } else {
            calendar = store.defaultCalendarForNewReminders()
        }
        
        alarms?.forEach({ alarm in
            guard let absoluteDate = alarm.absoluteDate,
            let reminderDueDate = reminder.dueDate else { return }
            let comparision = Locale.current.calendar.compare(reminderDueDate, to: absoluteDate, toGranularity: .minute)
            if comparision != .orderedSame {
                removeAlarm(alarm)
            }
        })
        if !hasAlarms {
            guard let reminderDueDate = reminder.dueDate else { return }
            addAlarm(EKAlarm(absoluteDate: reminderDueDate))
        }
    }
}
