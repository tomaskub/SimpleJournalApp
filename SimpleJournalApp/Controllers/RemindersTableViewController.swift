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
        
        return reminders.count
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
    //TODO: show alert containing error and ok button
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath)
        if let cell = cell as? LabelCell {
            cell.configureCell(with: reminders[indexPath.row].title)
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = EKEventViewController()
//        vc.allowsEditing = true
//        vc.event = reminderStore.read(with: reminders[indexPath.row].id)
        do {
            let ekReminder = try reminderStore.read(with: reminders[indexPath.row].id)
            print(ekReminder)
        } catch {
            displayAlert(error)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
