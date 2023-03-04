//
//  MainViewController+Delegate.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 3/4/23.
//
import UIKit
import Foundation

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //need to implement unwrapping the day log to make sure that it is added only when an action is tapped
        if indexPath.section == 1 {
            switch indexPath.row {
                
            case 0:
                if selectedDayLog == nil {
                    let result = journalManager?.getEntry(for: selectedDate)
                    if let error = result?.error as? JournalManagerNSError, error == .noResultsRetrived {
                        selectedDayLog = journalManager?.addEntry(selectedDate)
                    } else {
                        selectedDayLog = result?.dayLogs.first
                    }
                }
                presentPhotoPicker()
            case 1:
                if selectedDayLog == nil {
                    let result = journalManager?.getEntry(for: selectedDate)
                    if let error = result?.error as? JournalManagerNSError, error == .noResultsRetrived {
                        selectedDayLog = journalManager?.addEntry(selectedDate)
                    } else {
                        selectedDayLog = result?.dayLogs.first
                    }
                }
                let sender = tableView.cellForRow(at: indexPath)
                performSegue(withIdentifier: K.SegueIdentifiers.toQuestionVC, sender: sender)
            default:
                print("Add reminders cell tapped!")
                tableView.reloadData()
            }
        } else {
            do {
                //does not update the
                let reminder = try reminderManager?.reminder(forIndexPath: indexPath)
                let vc = DetailViewController()
                vc.reminder = reminder
                vc.isAddingNewReminder = false
                vc.reminderManager = reminderManager
                present(vc, animated: true)
            } catch {
                print(error)
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var result: CGFloat = tableView.frame.height / 8
        if indexPath.section == 1 && indexPath.row == 0 && selectedDayLog?.photo != nil {
            result = 5 * tableView.frame.height / 8
        }
        return result
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as! HeaderView
        switch section {
        case 1:
            header.titleLabel.text = "Actions"
            header.plusButton.removeFromSuperview()
            header.chevronButton.addTarget(self, action: #selector(collapseExpandSection(sender:)), for: .touchUpInside)
        default:
            header.titleLabel.text = reminderManager?.sectionTitles[section] ?? "Section \(section)"
            header.plusButton.addTarget(self, action: #selector(presentReminderDetailView), for: .touchUpInside)
            header.chevronButton.addTarget(self, action: #selector(collapseExpandSection(sender:)), for: .touchUpInside)
        }
        return header
    }
}
