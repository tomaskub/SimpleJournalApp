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
    
<<<<<<< Updated upstream
//  MARK: UI elements declarations
    private let questionViews: [QuestionView] = {
        var views: [QuestionView] = []
        for question in K.questions {
            let view = QuestionView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(question: question)
            views.append(view)
        }
        return views
    }()
    private let scrollView: QuestionView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Placeholder text"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: K.Colors.complement)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.backgroundColor = UIColor(named: K.Colors.complement)
        button.setTitleColor(UIColor(named: K.Colors.accent), for: .normal)
        return button
    }()
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("back", for: .normal)
        button.backgroundColor = UIColor(named: K.Colors.complement)
        button.setTitleColor(UIColor(named: K.Colors.accent), for: .normal)
        return button
    }()
    private let finishButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Finish", for: .normal)
        button.backgroundColor = UIColor(named: K.Colors.complement)
        button.setTitleColor(UIColor(named: K.Colors.accent), for: .normal)
        return button
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(named: K.Colors.complement)
        textView.returnKeyType = .done
        return textView
    }()
    
    
//  MARK: View life-cycle
=======
    //  MARK: UI elements declarations
    private let questionViews: [QuestionView] = {
        var views: [QuestionView] = []
        for question in K.questions {
            let view = QuestionView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(question: question)
            views.append(view)
        }
        return views
    }()
    private let scrollView: QuestionView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return
    }()
    
    //  MARK: View life-cycle
>>>>>>> Stashed changes
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in questionViews {
            view.delegate = self
        }
        
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubviews()
        setUpConstraints()
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
    
    func setUpConstraints() {
        
        
        viewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        viewBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            //      layout scrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        for i in 0...questionViews.count - 1 {
            if i == 0{
                questionViews[i].leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            } else if i == questionViews.count - 1 {
                questionViews[i].trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
            questionViews[i].leadingAnchor.constraint(equalTo: questionViews[i-1].trailingAnchor).isActive = true
            NSLayoutConstraint.activate([
                questionViews[i].topAnchor.constraint(equalTo: scrollView.topAnchor),
                questionViews[i].heightAnchor.constraint(equalToConstant: scrollView.frame.height),
                questionViews[i].widthAnchor.constraint(equalToConstant: scrollView.frame.width)
            ])
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
