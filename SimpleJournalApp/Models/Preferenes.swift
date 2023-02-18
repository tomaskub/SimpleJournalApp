//
//  Preferenes.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/26/22.
//

import Foundation

struct Preferences {
    
    let settings: [Section]
    
    init() {
        self.settings = [
            Section(sectionName: "Privacy", settingInSection: [
                Setting(icon: "eye", key: K.UserDefaultsKeys.isTrackDataEnabled, text: "Track data", type: .withToggleSwitch),
                Setting(icon: "hand.raised", key: K.UserDefaultsKeys.sendFailureReports, text: "Send failure reports", type: .withToggleSwitch)
            ]
                   ),
            Section(sectionName: "Data", settingInSection: [
                Setting(icon: "server.rack", key: nil, text: "Remove all day logs", type: .withChevronRight)]),
            Section(sectionName: "Colors", settingInSection: [
                Setting(icon: "circle.lefthalf.filled", key: K.UserDefaultsKeys.useDarkTheme, text: "Use dark theme", type: .withToggleSwitch)]),
            Section(sectionName: "Notifications", settingInSection: [
                Setting(icon: "bell", key: K.UserDefaultsKeys.isReminderEnabled, text: "Enable reminder", type: .withToggleSwitch),
                Setting(icon: "clock", key: K.UserDefaultsKeys.reminderTime, text: "Time", type: .withTimePicker)]),
            Section(sectionName: "Reminders", settingInSection: [
                Setting(icon: "calendar", key: K.UserDefaultsKeys.useDefaultReminderCalendar, text: "Use default reminder list", type: .withToggleSwitch),
            Setting(icon: "calendar.badge.plus", key: K.UserDefaultsKeys.useAppBundleReminderCalendar, text: "Use special list for reminders", type: .withToggleSwitch)])
        ]
    }
    struct Section {
        let sectionName: String
        let settingInSection: [Setting]
        
    }
    
    struct Setting {
        let icon: String
        let key: String?
        let text: String
        let type: SettingCell.CellButtonType
    }
}
