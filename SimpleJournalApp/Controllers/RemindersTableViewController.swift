//
//  RemindersTableViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import UIKit
import EventKitUI

class RemindersTableViewController: UITableViewController {
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    var reminders: [Reminder] = Reminder.sampleData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        prepareReminderStore()
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
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch ReminderError.accessDenied, ReminderError.accessRestricted {
                
            } catch {
                displayAlert(error)
            }
            
//            do {
//               _ = try reminderStore.reminderCategory()
//            } catch {
//                displayAlert(error)
//            }
            tableView.reloadData()
        }
    }
    
    @objc func eventStoreChanged (_ notification: NSNotification){
        Task {
            reminders = try await reminderStore.readAll()
            tableView.reloadData()
        }
    }
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath)
        if let cell = cell as? LabelCell {
            if indexPath.row == reminders.count {
                cell.configureCell(with: "Add new reminder")
            } else {
                cell.configureCell(with: reminders[indexPath.row].title)
            }
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let vc = EKEventViewController()
        //        vc.allowsEditing = true
        //        vc.event = reminderStore.read(with: reminders[indexPath.row].id)
        let vc = DetailViewController()
        
        if indexPath.row == reminders.count {
            vc.reminder = Reminder()
        } else {
            vc.reminder = reminders[indexPath.row]
        }
        present(vc, animated: true)
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
            (_, _, completionHandler) in
            //push new vc that allows for editing the reminder
        })
        editAction.backgroundColor = UIColor(named: K.Colors.accent)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
