//
//  MainViewController+DataSource.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 3/4/23.
//
import UIKit
import Foundation

//MARK: UITableViewDataSource methods
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reminderManager?.numberOfSections ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if collapsedSections.contains(section) {
            return 0
        } else {
            if section == 1 {
                return K.actions.count
            } else {
                return reminderManager?.sections[section].numberOfObjects ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            if indexPath.row == 0, let data = selectedDayLog?.photo  {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
                cell.delegate = self
                cell.myImageView.image = UIImage(data: data)
                cell.cornerRadius = 20
                cell.selectionStyle = .none
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
                cell.configureCell(with: K.actions[indexPath.row])
                cell.selectionStyle = .none
                cell.cornerRadius = 20
                return cell
                
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
            if let reminderManager = reminderManager {
            do {
                let reminder = try reminderManager.reminder(forIndexPath: indexPath)
                cell.configureCell(with: reminder.title, buttonState: reminder.isComplete)
                cell.delegate = self
            } catch {
                print(error)
            }}
            return cell
        }
    }
}
