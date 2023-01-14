//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//
import CoreData
import UIKit

class EntryViewController: UIViewController {
    
    enum Strategy {
    case isShowingOldEntry
    case isCreatingNewEntry
    }
    
    //  Constraint with constant to adjust based on keyboard height
    private var viewBottomConstraint: NSLayoutConstraint?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainter.viewContext
    
    var managedContext: NSManagedObjectContext!
    var strategy: Strategy = .isCreatingNewEntry
    
    
    
    
    var dayLog: DayLog? {
        didSet {
            guard let unwrappedDayLog = dayLog else { return }
            //TODO: FIX force uwrapping a possibly nil value when there is no existing answers in a new dayLog
            if unwrappedDayLog.answers?.allObjects == nil {
                for question in K.questions {
                    let answer = Answer()
                    answer.question = question
                    answer.dayLog = unwrappedDayLog
                }
                populate(unwrappedDayLog.answers?.allObjects as! [Answer])
            } else {
                let answers = unwrappedDayLog.answers?.allObjects as! [Answer]
                populate(answers)
                
                
                
                
                
                
//                for (i, answer) in answers.enumerated() {
//                    if let text = answer.text, let question = answer.question {
//                        questionViews[i].configure(question: question, answer: text)
//                    }
//                }
            }
        }
        
    }
    
    
    
    //  MARK: UI elements declarations
    private let questionViews: [QuestionView] = {
        var views: [QuestionView] = []
        for question in K.questions {
            let view = QuestionView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
//            view.configure(question: question)
            views.append(view)
        }
        return views
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return view
    }()
    
    //MARK: button actions
    @objc func editPressed() {
        //Edit apperance of questionViews to show editable behaviour
        for view in questionViews {
            view.textView.isEditable = true
            view.textView.layer.borderColor = UIColor(named: K.Colors.complement)?.cgColor
            view.textView.layer.borderWidth = 3
            view.textView.layer.cornerRadius = 5
        }
    }
    
    //  MARK: View life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        
        addSubviews()
        layoutUI()
        scrollView.delegate = self
        
        for view in questionViews {
            switch strategy {
            case .isCreatingNewEntry:
                view.textView.isEditable = true
                view.editButton.removeFromSuperview()
            case .isShowingOldEntry:
                view.textView.isEditable = false
                view.editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
            }
            view.textView.delegate = self
            //For testing the constraints
            view.textView.backgroundColor = UIColor(named: K.Colors.complement)
            view.textView.textColor = .black
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDissapear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        saveAnswers()
        if let log = dayLog {
            do {
                try managedContext.save()
            } catch let error as NSError{
                print("Failed to save: \(error), \(error.userInfo)")
            }
        }
    }
    
    
    //  MARK: Selectors
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            viewBottomConstraint?.constant = -(keyboardHeight+10)
        }
    }
    
    @objc func keyboardWillDissapear(_ notification: Notification) {
        viewBottomConstraint?.constant = -30
    }
    
    //  MARK: UI layout methods
    func addSubviews(){
        view.addSubview(scrollView)
        for view in questionViews {
            scrollView.addSubview(view)
        }
    }
    
    func layoutUI() {
        
        
        viewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        viewBottomConstraint?.isActive = true
        
        for qview in questionViews {
            NSLayoutConstraint.activate([
                qview.heightAnchor.constraint(equalToConstant: view.frame.height),
                qview.widthAnchor.constraint(equalToConstant: view.frame.width)])
        }
        
        
        NSLayoutConstraint.activate([
            //      layout scrollView
            //            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        for i in 0...questionViews.count - 1 {
            if i == 0{
                questionViews[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            } else if i == questionViews.count - 1 {
                questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor).isActive = true
                questionViews[i].trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            } else {
                questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor).isActive = true
            }
        }
        
        
    }

    func populate(_ answers: [Answer]) {
        // This probably needs to be extraxted to seperate method
        // enumerate thorugh all question views
        for (i, view) in questionViews.enumerated() {
            // for question view, get question from k.questions
            // set question for the question view
            view.question = K.questions[i]
            // enumerate though all answers
            for answer in answers {
                if let question = answer.question {
                    // If question in answer matches question for view
                    if question == view.question {
                        //Check if question has an answer text
                        if let text = answer.text {
                            // set answer in text field
                            view.textView.text = text
                        }
                    }
                }
            }
            
        }
    }
    
    func saveAnswers() {
        for view in questionViews {
            if let question = view.question, let existingAnswers = dayLog?.answers?.allObjects as? [Answer] {
                
                if let i = existingAnswers.firstIndex(where: {$0.question == question}) {
                    existingAnswers[i].text = view.returnAnswer()
                } else {
                    let answer = Answer(context: managedContext)
                    answer.question = view.question
                    answer.text = view.returnAnswer()
                    answer.dayLog = dayLog
                }
                
            }
        }
    }
}

//MARK: UITextViewDelegate
extension EntryViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension EntryViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for view in questionViews {
            if CGRectIntersectsRect(scrollView.bounds, view.frame) {
                view.textView.becomeFirstResponder()
            }
        }
    }
}
