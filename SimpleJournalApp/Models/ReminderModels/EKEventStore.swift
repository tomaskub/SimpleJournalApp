//
//  EKEventStore.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//
import EventKit
import Foundation

// Wrapper around fetch reminders function
extension EKEventStore {
    func reminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: ReminderError.failedReadingReminders)
                }
            }
        }
    }
}
