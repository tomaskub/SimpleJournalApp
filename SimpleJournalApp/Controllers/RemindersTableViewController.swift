//
//  RemindersTableViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import UIKit
import EventKitUI

class RemindersTableViewController: UITableViewController, ReminderTableViewCellDelegate, ReminderManagerDelegate {
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    let reminderManager = ReminderManager()
    
    private let addButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plus.circle"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    func requestUIUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func addButtonTapped() {
        runEditingVC(for: Reminder())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(addButton)
        NSLayoutConstraint.activate(  [
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.widthAnchor.constraint(equalToConstant: 50)])
        
        tableView.register(ReminderTableViewCell.self, forCellReuseIdentifier: ReminderTableViewCell.identifier)
//        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        tableView.rowHeight = 50
        reminderManager.delegate = self
        do {
            try reminderManager.prepareReminderStore()
            tableView.reloadData()
        } catch {
            displayAlert(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
    }
    
    @objc func eventStoreChanged (_ notification: NSNotification){
            reminderManager.updateSnapshot()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        return 1
        return reminderManager.numbersOfSections()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        case 2:
            return "Future"
        case 3:
            return "No due date"
        case 4:
            return "Past"
        default:
            return "Unknown"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderManager.numberOfItemsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
        do {
            let reminder = try reminderManager.reminder(forIndexPath: indexPath)
            cell.configureCell(with: reminder.title, buttonState: reminder.isComplete)
            cell.delegate = self
        } catch {
            displayAlert(error)
        }
        return cell
    }
    
    func doneButtonTapped(sender: ReminderTableViewCell) {
        
        if let indexPath = tableView.indexPath(for: sender) {
            do {
                try reminderManager.updateReminder(atIndexPath: indexPath)
            } catch ReminderError.reminderForIndexPathDoesNotExist {
                
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
        do {
            runEditingVC(for: try reminderManager.reminder(forIndexPath: indexPath))
        } catch {
            displayAlert(error)
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
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: {
            (_, _, completionHandler) in
            self.reminderManager.removeReminder(for: indexPath)
        })
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {
            (_, _, completionHandler)  in
            do {
                self.runEditingVC(for: try self.reminderManager.reminder(forIndexPath: indexPath))
            } catch {
                print(error)
            }
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
