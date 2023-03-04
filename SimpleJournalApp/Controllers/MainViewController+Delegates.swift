//
//  MainViewController+Delegates.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 3/4/23.
//

import Foundation
import UIKit

//MARK: ReminderManagerDelegate methods
extension MainViewController: ReminderManagerDelegate {
    
    func requestUIUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
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
    
    func controller(_ controller: ReminderManager, didChange aReminder: Reminder, at indexPath: IndexPath?, for type: ReminderManagerChangeType, newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                if !self.collapsedSections.contains(newIndexPath!.section) {
                    self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
                }
            case .delete:
                if !self.collapsedSections.contains(indexPath!.section) {
                    self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                }
            case .move:
                
                if !self.collapsedSections.contains(indexPath!.section) {
                    self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                }
                
                if !self.collapsedSections.contains(newIndexPath!.section) {
                    self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
                }
                
            case .update:
                if !self.collapsedSections.contains(indexPath!.section) {
                    if let cell = self.tableView.cellForRow(at: indexPath!) as? ReminderTableViewCell {
                        cell.configureCell(buttonState: aReminder.isComplete)
                    }
                }
            }
        }
    }
    
    func controller(_ controller: ReminderManager, didChange sectionInfo: ReminderResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: ReminderManagerChangeType) {
    }
    
}

//MARK: UIImagePickerControllerDelegate methods
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let data = image.jpegData(compressionQuality: 1.0),
                    let log = selectedDayLog,
                  let manager = journalManager else { return }
            manager.addPhoto(jpegData: data, to: log)
        }
        tableView.reloadData()
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
}

//MARK: PhotoCellDelegate methods
extension MainViewController: PhotoCellDelegate {
    func leftButtonTapped() {
        presentPhotoPicker()
    }
    func rightButtonTapped() {
        guard let entry = selectedDayLog, let _journalManager = journalManager else { return }
        _journalManager.deletePhoto(entry: entry)
        tableView.reloadData()
    }
}

//MARK: ReminderTableViewCellDelegate methods
extension MainViewController: ReminderTableViewCellDelegate {
    
    func doneButtonTapped(sender: ReminderTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            do {
                try reminderManager?.updateReminder(atIndexPath: indexPath)
            } catch {
                print(error)
            }
        }
    }
}

