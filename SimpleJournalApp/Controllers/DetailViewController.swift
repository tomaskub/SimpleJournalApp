//
//  DetailViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/8/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    var isAddingNewReminder = true
    
    var reminder: Reminder!
    var reminderManager: ReminderManager!
    
    
    var dateComponents: DateComponents?
    
    fileprivate var viewBottomConstraint: NSLayoutConstraint?
    
    let detailView: DetailView = {
        let view = DetailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = detailView
        
        if let view  = view as? DetailView {
            let title = isAddingNewReminder ? "Add new reminder" : "Edit reminder"
            view.configureView(title: title , titleText: reminder.title, notesText: reminder.notes)
            if let dueDate = reminder.dueDate {
                view.setDisplayedDate(date: dueDate)
            }
            addTargets(to: view)
        }
    }
    
    func addTargets(to view: DetailView){
        view.cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.okButton.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        //Using .editingDidEndOnExit to trigger only on finish of the editing
        view.datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)//.editingDidEndOnExit)
        view.timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .editingDidEndOnExit)
    }
    
    
    func updateReminder() {
        guard let view = view as? DetailView,
              let title = view.titleTextField.text else { return }
        reminder.title = title
        reminder.notes = view.notesTextField.text
        if let dateComponents = dateComponents {
            reminder.dueDate = Calendar.current.date(from: dateComponents)
        }
    }
}

//MARK: Actions
extension DetailViewController {
    
    @objc func cancelAction() {
        self.dismiss(animated: true)
    }
    
    @objc func okAction() {
        updateReminder()
        reminderManager.save(reminder)
        self.dismiss(animated: true)
    }
    
    @objc func datePickerValueChanged() {
        guard let view = view as? DetailView else { return }
        dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: view.datePicker.date)
    }
    
    @objc func timePickerValueChanged() {
        guard let view = view as? DetailView else { return }
        dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: view.datePicker.date)
    }
}
