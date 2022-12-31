//
//  QuestionView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/30/22.
//

import UIKit

class QuestionView: UIView {
    
    var isEditable: Bool = false
    weak var delegate: UITextViewDelegate?
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentMode = .topLeft
        view.textColor = UIColor(named: K.Colors.complement)
        return view
    }()
    
    override init(frame: CGRect) {
        textView.isEditable = isEditable
        textView.delegate = delegate
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubview(questionLabel)
        addSubview(textView)
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(question: String, answer: String? = nil) {
        questionLabel.text = question
        textView.text = answer
    }
    
    func returnAnswer() -> String {
        return textView.text
    }
    
}

