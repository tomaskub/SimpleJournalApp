//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//

import UIKit

protocol QuestionViewControllerDelegate {
    func saveDayLog(dayLog: DayLog)
}

class QuestionViewController: UIViewController {
    
    //  Constraint with constant to adjust based on keyboard height
    private var viewBottomConstraint: NSLayoutConstraint?
    
    var dayLog: DayLog?
    
    public var delegate: QuestionViewControllerDelegate?
    
//  MARK: UI elements declarations
    private let questionViews: [QuestionView] = {
        var views: [QuestionView] = []
        for question in K.questions {
            let view = QuestionView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(question: question)
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
       
    
    //  MARK: View life-cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubviews()
        layoutUI()
        
        for view in questionViews {
            view.textView.isEditable = true
            view.textView.delegate = self
                
            
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

        if let log = dayLog {
            delegate?.saveDayLog(dayLog: log)
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
        
        
//        viewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
//        viewBottomConstraint?.isActive = true
        
        for qview in questionViews {
            NSLayoutConstraint.activate([
                qview.heightAnchor.constraint(equalToConstant: view.frame.height),
                qview.widthAnchor.constraint(equalToConstant: view.frame.width)])
        }
        
        
        NSLayoutConstraint.activate([
            //      layout scrollView
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
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
//            NSLayoutConstraint.activate([
//                questionViews[i].topAnchor.constraint(equalTo: scrollView.topAnchor),
//                questionViews[i].heightAnchor.constraint(equalToConstant: view.frame.height),
//                questionViews[i].widthAnchor.constraint(equalToConstant: view.frame.width)
//            ])
        }
        
        
    }
    
    // MARK: configure view for data
    func configure(forDisplaying dayLog: DayLog) {
        self.dayLog = dayLog
        let answers = dayLog.answers?.allObjects as! [Answer]
        for (i, answer) in answers.enumerated() {
            if let text = answer.text, let question = answer.question {
                questionViews[i].configure(question: question, answer: text)
            }
        }
    }
}
//MARK: UITextViewDelegate
extension QuestionViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
