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
    
    var reminderStore = ReminderStore.shared
    
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
            view.setDisplayedDate(date: reminder.dueDate)
            addTargets(to: view)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func addTargets(to view: DetailView){
        view.cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.okButton.addTarget(self, action: #selector(okAction), for: .touchUpInside)
    }
    
    
    func updateReminder() {
        guard let view = view as? DetailView,
              let title = view.titleTextField.text else { return }
        
        reminder.title = title
        reminder.notes = view.notesTextField.text
        reminder.dueDate = view.datePicker.date
            
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension DetailViewController {
    
    @objc func cancelAction() {
        self.dismiss(animated: true)
    }
    
    @objc func okAction() {
        updateReminder()
        do {
            _ = try reminderStore.save(reminder)
        } catch {
            print(error)
        }
        self.dismiss(animated: true)
        
    }
}
