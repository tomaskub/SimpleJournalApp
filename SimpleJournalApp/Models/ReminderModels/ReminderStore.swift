//
//  ReminderStore.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//
import EventKit
import Foundation

class ReminderStore {
    
    static let shared = ReminderStore()
    
    private let ekStore = EKEventStore()
    
    var isAvaliable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            return
        case .restricted:
            throw ReminderError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestAccess(to: .reminder)
            guard accessGranted else { throw ReminderError.accessDenied }
        case .denied:
            throw ReminderError.accessDenied
        @unknown default:
            throw ReminderError.unknown
        }
    }
    func readAll() async throws -> [Reminder] {
        guard isAvaliable else { throw ReminderError.accessDenied }
        
        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap({
            ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch ReminderError.reminderHasNoDueDate {
                return nil
            }
        })
        return reminders
    }
    
}
