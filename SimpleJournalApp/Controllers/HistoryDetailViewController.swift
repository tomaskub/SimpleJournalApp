//
//  HistoryDetailViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/29/22.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    var dayLog: DayLog?
    
    
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
            card.configure(question: question)
            cards.append(card)
        }
        return cards
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        addViews()
        layoutUI()
        if let dayLog = dayLog {
            let answers: [Answer] = dayLog.answers?.allObjects as! [Answer]
            for i in 0...answers.count - 1 {
                if let answer = answers[i].text {
                    questionCards[i].configure(question: K.questions[i], answer: answer)
                } else {
                    questionCards[i].configure(question: K.questions[i])
                }
            }
        }
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


