//
//  SettingsViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/15/22.
//
import CoreData
import UserNotifications
import UIKit

class SettingsViewController: UIViewController {
    
    let pref = Preferences()
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display date
        dateLabel.text = Date.now.formatted(date: .complete, time: .omitted).uppercased()
        
        //set up table view appearance
        tableView.layer.backgroundColor = UIColor(named: "ComplementColor")?.cgColor
        tableView.layer.cornerRadius = tableView.layer.bounds.width / 10
        tableView.rowHeight = 80
        
        //set up tableView protocols
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.useDarkTheme) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
}

//MARK: UITableViewDelegate and DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pref.settings[section].settingInSection.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier) as! SettingCell
        let iconName = pref.settings[indexPath.section].settingInSection[indexPath.row].icon
        let labelText = pref.settings[indexPath.section].settingInSection[indexPath.row].text
        let cellType = pref.settings[indexPath.section].settingInSection[indexPath.row].type
        cell.configureCell(iconSystemName: iconName, labelText: labelText, cellType: cellType)
        cell.delegate = self
        cell.selectionStyle = .none
        //test - get the value of a bool for key
        if let key = pref.settings[indexPath.section].settingInSection[indexPath.row].key {
            
            if cellType == .withToggleSwitch {
                cell.setToggleButtonState(value: defaults.bool(forKey: key))
            }
            if cellType == .withTimePicker {
                if let date = defaults.value(forKey: key) as? Date{
                    cell.setTime(date: date)
                }
            }
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pref.settings.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pref.settings[section].sectionName
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

//MARK: SettingCellDelegate protocol implementation
extension SettingsViewController: SettingCellDelegate {
    
    func chevronButtonPressed(sender: SettingCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            if sender.getText() == pref.settings[1].settingInSection[0].text {
                removeAllDayLogs()
            }
        }
    }
    
    func toggleSwitchPressed(sender: SettingCell) {
        
        if let indexPath = tableView.indexPath(for: sender) {
            // retrieve key for the cell that called toggleSwitchPressed
            if let key = pref.settings[indexPath.section].settingInSection[indexPath.row].key {
                switch key {
                case K.UserDefaultsKeys.isReminderEnabled:
                    if sender.getToggleButtonState() == true {
                        
                        if let reminderTime = defaults.object(forKey: key) as? Date {
                            scheduleReminder(for: reminderTime )
                        }
                    } else {
                        
                        removeReminder()
                    }
                case K.UserDefaultsKeys.useDarkTheme:
                    if sender.getToggleButtonState()! {
                        self.overrideUserInterfaceStyle = .dark
                    } else {
                        self.overrideUserInterfaceStyle = .unspecified
                    }
                default:
                    return
                }
                defaults.setValue(sender.getToggleButtonState(), forKey: key)
            }
        }
    }
    
    func timePickerEditingDidEnd(sender: SettingCell) {
        
        if let indexPath = tableView.indexPath(for: sender) {
            
            if let date = sender.getTime(), let key = pref.settings[indexPath.section].settingInSection[indexPath.row].key {
                if key == K.UserDefaultsKeys.reminderTime && defaults.bool(forKey: K.UserDefaultsKeys.isReminderEnabled) {
                    scheduleReminder(for: date)
                }
                
                defaults.setValue(date, forKey: key)
                
            }
        }
        
    }
    
}

// MARK: User notifications
extension SettingsViewController {
    
    func scheduleReminder(for time: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { success, error in
            if success {
                //schedule reminder
                let content = UNMutableNotificationContent()
                content.title = K.Reminder.notificationTitle
                content.sound = .default
                content.body = K.Reminder.notificationBody
                
                let targetDate = time
                
                print(targetDate.formatted())
                let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: targetDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: K.Reminder.notificationRequestID, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        print("Notification set up with success!")
                    }
                })
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
    func removeReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [K.Reminder.notificationRequestID])
    }
}

// MARK: Alerts for chevron button cells
extension SettingsViewController {
    func removeAllDayLogs() {
        let alert = UIAlertController(title: "Remove all entries", message: "By confirming you will delete all of the entries describing your day", preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: "Confirm", style: .destructive) {
            (action) in
            self.removeAllEntries()
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(confirmButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true)
    }
}

// MARK: CoreData methods
extension SettingsViewController {
    
    func removeAllEntries(){
        
        let request = DayLog.fetchRequest() as NSFetchRequest<DayLog>
        do {
            var retrivedDayLogs = try context.fetch(request)
            for dayLog in retrivedDayLogs {
                self.context.delete(dayLog)
            }
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
