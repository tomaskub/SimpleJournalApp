//
//  RemindersTableViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import UIKit
import EventKitUI

class RemindersTableViewController: UITableViewController, ReminderTableViewCellDelegate {
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    var reminders: [Reminder] = []
    var processedReminders: [IndexPath : Reminder] = [ : ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ReminderTableViewCell.self, forCellReuseIdentifier: ReminderTableViewCell.identifier)
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        tableView.rowHeight = 50
        prepareReminderStore()
    }
    //MARK: EventKit Reminders
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
//                let unprocessedReminders
                reminders = try await reminderStore.readAll()
                processedReminders = processReminders(Reminder.sampleData)
                print(processedReminders)
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch ReminderError.accessDenied, ReminderError.accessRestricted {
                
            } catch {
                displayAlert(error)
            }
            tableView.reloadData()
        }
    }
    func processReminders(_ reminders: [Reminder]) -> [IndexPath : Reminder] {
        
        var temp: [IndexPath : Reminder] = [:]
        var future: [Reminder] = []
        var today: [Reminder] = []
        var tomorrow: [Reminder] = []
        
        for reminder in reminders {
            if let dueDate = reminder.dueDate {
                if Calendar.current.isDateInToday(dueDate) {
                    today.append(reminder)
                } else if Calendar.current.isDateInTomorrow(dueDate) {
                    tomorrow.append(reminder)
                }
            } else {
                if !reminder.isComplete {
                    //this will also append past reminders
                    future.append(reminder)
                }
            }
            for (i, reminder) in today.enumerated() {
                temp[IndexPath(row: i, section: 0)] = reminder
            }
            for (i, reminder) in tomorrow.enumerated() {
                temp[IndexPath(row: i, section: 1)] = reminder
            }
            for (i, reminder) in future.enumerated() {
                temp[IndexPath(row: i, section: 2)] = reminder
            }
        }
        return temp
    }
    @objc func eventStoreChanged (_ notification: NSNotification){
        Task {
            reminders = try await reminderStore.readAll()
            tableView.reloadData()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminders.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == reminders.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.configureCell(with: "Add new reminder")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
                    let reminder = reminders[indexPath.row]
                    cell.configureCell(with: reminder.title)
                    cell.updateDoneButtonConfiguration(for: reminder)
                    cell.delegate = self
            return cell
        }
    }
    
    func doneButtonTapped(sender: ReminderTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            reminders[indexPath.row].isComplete.toggle()
            sender.updateDoneButtonConfiguration(for: reminders[indexPath.row])
            
            do {
                _ = try reminderStore.save(reminders[indexPath.row])
            } catch {
                displayAlert(error)
            }
        }
    }
    
    func runEditingVC(for reminder: Reminder) {
        let vc = DetailViewController()
        vc.reminder = reminder
        present(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == reminders.count {
            runEditingVC(for: Reminder())
        } else {
            runEditingVC(for: reminders[indexPath.row])
        }
        
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == reminders.count {
            return false
        } else {
            return true
        }
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try reminderStore.remove(with: reminders[indexPath.row].id)
            } catch {
                displayAlert(error)
            }
            reminders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: {
            (_, _, completionHandler) in
            do {
                try self.reminderStore.remove(with: self.reminders[indexPath.row].id)
            } catch {
                self.displayAlert(error)
            }
            self.reminders.remove(at: indexPath.row)
        })
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {
            (_, _, completionHandler)  in
            self.runEditingVC(for: self.reminders[indexPath.row])
        })
        editAction.backgroundColor = UIColor(named: K.Colors.accent)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    //MARK: Alerts
    func displayAlert(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: {
            [weak self] _ in
            self?.dismiss(animated: true)
        })
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
