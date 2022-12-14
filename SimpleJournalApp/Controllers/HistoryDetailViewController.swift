//
//  HistoryDetailViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/29/22.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    var dayLog: DayLog? {
        didSet {
            guard let unwrappedDayLog = dayLog else { return }
            guard let answers: [Answer] = unwrappedDayLog.answers?.allObjects as? [Answer] else {
                print("Retrived day log does not have any q&a")
                return
            }
            if answers.count == 1 {
                if let answer = answers.first?.text, let question = answers.first?.question {
                    questionCards[0].configure(question: question, answer: answer)
                }
            } else if answers.count > 1 {
                for i in 0...answers.count - 1 {
                    if let answer = answers[i].text {
                        questionCards[i].configure(question: K.questions[i], answer: answer)
                    } else {
                        questionCards[i].configure(question: K.questions[i])
                    }
                }
        }
    }
}
    
    //MARK: UI elements
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return view
    }()
    private let questionCards: [QuestionView] = {
        var cards: [QuestionView] = []
        for question in K.questions {
            let card = QuestionView()
            card.translatesAutoresizingMaskIntoConstraints = false
            cards.append(card)
        }
        return cards
    }()
    
    //MARK: button actions
    @objc func editPressed() {
        for view in questionCards {
            view.textView.isEditable = true
            view.textView.layer.borderColor = UIColor(named: K.Colors.complement)?.cgColor
            view.textView.layer.borderWidth = 3
            view.textView.layer.cornerRadius = 5
            
            
        }
    }
    
    
    
    //MARK: life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        addViews()
        layoutUI()
        for view in questionCards {
            view.editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        }
        //TODO: fix issue with out of bound on a placeholder item or remove placeholders?
        
        }
    
    
    //MARK: UI layout
    private func addViews() {
        for card in questionCards {
            scrollView.addSubview(card)
        }
        view.addSubview(scrollView)
        
    }
    
    private func layoutUI() {
        
        for card in questionCards {
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(equalToConstant: view.frame.height),
                card.widthAnchor.constraint(equalToConstant: view.frame.width)
            ])
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        questionCards.first?.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        for i in 1...questionCards.count - 1 {
            NSLayoutConstraint.activate([
                questionCards[i].leadingAnchor.constraint(equalTo: questionCards[i-1].trailingAnchor)])
        }
        questionCards.last?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }
    
}


