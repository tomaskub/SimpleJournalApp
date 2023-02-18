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
        static let wasRunBefore = "isRunFirstTime"
        static let useDefaultReminderCalendar = "useDefaultReminderCalendar"
        static let useAppBundleReminderCalendar = "useAppBundleReminderCalendar"
//        static let
    }
    struct Reminder {
        static let notificationRequestID = "SimpleJournalNotification"
        static let notificationTitle = "Simple Journal"
        static let notificationBody = "Your journaling time is now! Spend 5 to 15 minutes to summarize you day the way Marcus Aurelius did!"
        
    }
    struct SegueIdentifiers {
        static let toQuestionVC = "ToAnswerQuestion"
    }
    struct Colors {
        static let complement = "ComplementColor"
        static let accent = "AccentColor"
        static let dominant = "DominantColor"
    }
    
    static let questions: [String] = [
        "Summary of the day",
        "What did i do good?",
        "What did i do bad?",
        "How can I improve on that?",
        "Where was my discipline and self-control tested?"
    ]
    static let actions: [String] = [
    "Add photo",
    "Add journal entry",
    "Add reminders for next day"]
    
    struct SFSymbols {
        static let edit = "square.and.pencil"
    }
    
}
