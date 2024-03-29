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
    
    var ekCalendar: EKCalendar!
    
    var isAvaliable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    init() {
        do { try self.reminderCategory() } catch { }
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
    
    func read(with id: Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw ReminderError.failedReadingCalendarItem
        }
        return ekReminder
    }
    
    func readAllCompleted() async throws -> [Reminder] {
        
        guard isAvaliable else { throw ReminderError.accessDenied }
        let predicate = ekStore.predicateForCompletedReminders(withCompletionDateStarting: nil, ending: nil, calendars: nil)
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
    
    
    func readAll() async throws -> [Reminder] {
        guard isAvaliable else { throw ReminderError.accessDenied }
        //in shoul be a custom calendar created for the app
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
    
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvaliable else { throw ReminderError.accessDenied }
        
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
            ekReminder.update(using: reminder, in: ekStore)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
            ekReminder.update(using: reminder, in: ekStore, using: ekCalendar)
        }
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
    
    func remove(with id: Reminder.ID) throws {
        guard isAvaliable else { throw ReminderError.accessDenied }
        let ekRemidner = try read(with: id)
        try ekStore.remove(ekRemidner, commit: true)
    }
    //For use in tearing down the results of the tests when no mocks are done. All data will be lost
    func removeAll() async throws {
        guard isAvaliable else { throw ReminderError.accessDenied }
        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        for ekReminder in ekReminders {
            try ekStore.remove(ekReminder, commit: false)
        }
        try ekStore.commit()
    }
    
    func reminderCategory() throws {
        let calendars = ekStore.calendars(for: .reminder)
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        
        if let bundleCalendar = calendars.first(where: {$0.title == bundleName}) {
            ekCalendar = bundleCalendar
        } else {
            let calendar = EKCalendar(for: .reminder, eventStore: ekStore)
            calendar.title = bundleName
            calendar.source = ekStore.defaultCalendarForNewReminders()?.source
            try ekStore.saveCalendar(calendar, commit: true)
            ekCalendar = calendar
        }
    }
}
