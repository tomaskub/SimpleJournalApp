//
//  QuestionView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/30/22.
//
import UIKit

class QuestionView: UIView {
    
    
    var question: Question? {
        didSet {
            questionLabel.text = question?.rawValue
        }
    }
    var answer: String? {
        didSet {
            textView.text = answer
        }
    }
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isScrollEnabled = true
        view.font = UIFont.systemFont(ofSize: 17)
        view.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        view.backgroundColor = .clear
        view.contentMode = .topLeft
        view.textColor = UIColor(named: K.Colors.complement)
        return view
    }()
    let editButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: K.SFSymbols.edit)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: K.Colors.complement)!
        return button
    }()
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubview(questionLabel)
        addSubview(textView)
        addSubview(editButton)
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            editButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)])
        textView.layer.cornerRadius = 10.0
        textView.layer.borderColor = UIColor(named: K.Colors.complement)?.cgColor
        textView.layer.borderWidth = 3.0
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(question: Question, answer: String? = nil) {
        self.question = question
        self.answer = answer
    }
    
    func returnAnswer() -> String {
        return textView.text
    }
    
    
}
