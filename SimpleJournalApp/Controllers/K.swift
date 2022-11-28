//
//  K.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/26/22.
//

import Foundation

struct K {
    struct UserDefaultsKeys {
        static let isReminderEnabled = "isReminderEnabled"
        static let reminderTime = "reminderTime"
        static let isTrackDataEnabled = "trackData"
        static let sendFailureReports = "sendFailureReports"
        static let useDarkTheme = "useDarkTheme"
//        static let
    }
    struct Reminder {
        static let notificationRequestID = "SimpleJournalNotification"
        static let notificationTitle = "Simple Journal"
        static let notificationBody = "Your journaling time is now! Spend 5 to 15 minutes to summarize you day the way Marcus Aurelius did!"
        
    }
}
