//
//  ReminderError.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import Foundation

enum ReminderError: LocalizedError {
    
    case failedReadingCalendarItem
    case accessDenied
    case accessRestricted
    case failedReadingReminders
    case reminderHasNoDueDate
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedReadingCalendarItem:
            return NSLocalizedString("Failed to read calendar item", comment: "failed reading calendar item error description")
        case .accessDenied:
            return NSLocalizedString(
                "The app doesn't have permission to read reminders.", comment: "access denied due to no permission")
        case .accessRestricted:
            return NSLocalizedString("This device doesn't allow access to reminders.", comment: "access restricted error description")
        case .failedReadingReminders:
            return NSLocalizedString("Failed to read reminders.", comment: "failed reading reminders error description")
        case .reminderHasNoDueDate:
            return NSLocalizedString("A reminder has no due date.", comment: "reminder has no due date error description")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "unknown error description")
        }
    }
}
