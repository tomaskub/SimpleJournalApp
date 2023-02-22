//
//  DetailView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/9/23.
//

import UIKit

class DetailView: UIView {

    let spacing: CGFloat = 10
    let textColor = UIColor(named: K.Colors.complement)
    
    let titleTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Title"
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.contentMode = .topLeft
        return view
    }()
    
    let notesTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Notes"
        view.contentMode = .topLeft
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date"
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time"
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date

        return picker
    }()
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time

        return picker
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    let okButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        return button
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func internalInit(){
        for view in [cancelButton, okButton, titleLabel, titleTextField, notesTextField, dateLabel, timeLabel, datePicker, timePicker] {
            self.addSubview(view)
        }
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        layoutSubviews()
    }
    
    
    
    override func layoutSubviews() {
        //Constraints for the first row
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            okButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            okButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            titleTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
//            titleTextField.heightAnchor.constraint(equalToConstant: 100),
            notesTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            notesTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            notesTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: spacing),
            notesTextField.heightAnchor.constraint(equalToConstant: 100)
        ])
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -spacing),
            dateLabel.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: spacing),
            dateLabel.heightAnchor.constraint(equalToConstant: 50),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: spacing)])
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -spacing),
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: spacing),
            timeLabel.heightAnchor.constraint(equalToConstant: 50),
            timePicker.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            timePicker.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: spacing)])
    }
    
    func configureView(title: String, titleText: String? = "Reminder title", notesText: String? = "Notes") {
        titleLabel.text = title
        titleTextField.text = titleText
        notesTextField.text = notesText
    }
    func setDisplayedDate(date: Date){
        datePicker.date = date
        timePicker.date = date
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
