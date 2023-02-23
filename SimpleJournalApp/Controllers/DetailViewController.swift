//
//  DetailViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/8/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    //Injections
    var reminder: Reminder!
    var reminderManager: ReminderManager!
    
    var dateComponents: DateComponents?
    var isAddingNewReminder = true
    fileprivate var viewBottomConstraint: NSLayoutConstraint?
    
    //UI elements
    let detailView: DetailView = {
        let view = DetailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(detailView)
        view.addSubview(scrollView)
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        layoutUI()
        let title = isAddingNewReminder ? "Add new reminder" : "Edit reminder"
        detailView.configureView(title: title , titleText: reminder.title, notesText: reminder.notes)
        if let dueDate = reminder.dueDate {
            detailView.setDisplayedDate(date: dueDate)
        }
        addTargets(to: detailView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func layoutUI() {
        viewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewBottomConstraint!
        ])
        NSLayoutConstraint.activate([
        detailView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: detailView.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: detailView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: detailView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: detailView.bottomAnchor)])
    }
    
    func addTargets(to view: DetailView){
        view.cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.okButton.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        view.datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        view.timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
    }
    
    
    func updateReminder() {
        guard let view = view as? DetailView,
              let title = view.titleTextView.text else { return }
        reminder.title = title
        reminder.notes = view.notesTextView.text
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

extension DetailViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            viewBottomConstraint?.constant = -(keyboardHeight)
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        viewBottomConstraint?.constant = 0
    }
}
