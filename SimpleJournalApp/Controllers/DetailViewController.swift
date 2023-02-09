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
        }
        // Do any additional setup after loading the view.
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
