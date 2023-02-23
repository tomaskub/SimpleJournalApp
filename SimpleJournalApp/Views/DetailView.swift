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
    
    let titleTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17)
        view.isScrollEnabled = false
        view.adjustsFontForContentSizeCategory = true
        view.backgroundColor = UIColor(named: K.Colors.complement)
        view.layer.cornerRadius = 10
        view.contentMode = .topLeft
        return view
    }()
    
    let notesTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17)
        view.isScrollEnabled = false
        view.adjustsFontForContentSizeCategory = true
        view.contentMode = .topLeft
        view.backgroundColor = UIColor(named: K.Colors.complement)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date:"
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time:"
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
        picker.setValue(UIColor(named: K.Colors.complement), forKey: "textColor")
        
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
        for view in [cancelButton, okButton, titleLabel, titleTextView, notesTextView, dateLabel, timeLabel, datePicker, timePicker] {
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
            titleTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            titleTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            titleTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            notesTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            notesTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            notesTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: spacing)
        ])
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -spacing),
            dateLabel.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: spacing),
            dateLabel.heightAnchor.constraint(equalToConstant: 50),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: spacing)])
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -spacing),
            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: spacing),
            timeLabel.heightAnchor.constraint(equalToConstant: 50),
            timePicker.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            timePicker.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: spacing),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
    }
    
    func configureView(title: String, titleText: String? = "Reminder title", notesText: String? = "Notes") {
        titleLabel.text = title
        titleTextView.text = titleText
        notesTextView.text = notesText
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
