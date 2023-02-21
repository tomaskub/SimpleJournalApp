//
//  RemindersTableViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/5/23.
//

import UIKit
import EventKitUI

class RemindersTableViewController: UITableViewController {
    
    let reminderManager = ReminderManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ReminderTableViewCell.self, forCellReuseIdentifier: ReminderTableViewCell.identifier)
        tableView.rowHeight = 50
        reminderManager.delegate = self
        //Move this to reminderManager
        do {
            try reminderManager.prepareReminderStore()
        } catch {
            displayAlert(error)
        }
        
    }
    
    func presentDetailViewController(for reminder: Reminder) {
        let vc = DetailViewController()
        vc.reminder = reminder
        vc.reminderManager = reminderManager
        present(vc, animated: true)
        
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

// MARK: - Table view data source
extension RemindersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return reminderManager.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //this should come from the reminderManager
//        let sectionHeaders = [ "Past due", "Today", "Tomorrow", "Future", "No due date", "Past"]
//        return sectionHeaders[section]
        return reminderManager.sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderManager.sections[section].numberOfObjects
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            presentDetailViewController(for: try reminderManager.reminder(forIndexPath: indexPath))
        } catch {
            displayAlert(error)
        }
    }
}

//MARK: Table view configuration methods
extension RemindersTableViewController {
    
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
                self.presentDetailViewController(for: try self.reminderManager.reminder(forIndexPath: indexPath))
            } catch {
                print(error)
            }
        })
        
        editAction.backgroundColor = UIColor(named: K.Colors.accent)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

//MARK: ReminderManagerDelegate methods
extension RemindersTableViewController: ReminderManagerDelegate {
    
    func controllerWillChangeContent(_ controller: ReminderManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
        
    }
    
    func controllerDidChangeContent(_ controller: ReminderManager) {
      
        DispatchQueue.main.async {
            self.tableView.endUpdates()
        }
    }
    
    
    func requestUIUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
  
  func controller(_ controller: ReminderManager, didChange aReminder: Reminder, at indexPath: IndexPath?, for type: ReminderManagerChangeType, newIndexPath: IndexPath?){
      DispatchQueue.main.async {
          
          
          switch type {
          case .insert:
              self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
          case .delete:
              self.tableView.deleteRows(at: [indexPath!], with: .automatic)
          case .update:
              let cell = self.tableView.cellForRow(at: indexPath!) as! ReminderTableViewCell
              cell.configureCell(buttonState: aReminder.isComplete)
          case .move:
              self.tableView.deleteRows(at: [indexPath!], with: .automatic)
              self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
          }
      }
  }
  
  
    func controller(_ controller: ReminderManager, didChange sectionInfo: ReminderResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: ReminderManagerChangeType) {
      let indexSet = IndexSet(integer: sectionIndex)
    switch type {
    case .insert:
      tableView.insertSections(indexSet, with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet, with: .automatic)
    default:
      break
    }
  }
}

//MARK: ReminderTableViewCellDelegate methods
extension RemindersTableViewController: ReminderTableViewCellDelegate {
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
}
