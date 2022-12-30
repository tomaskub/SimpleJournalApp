//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//

import UIKit

protocol QuestionViewControllerDelegate {
    func saveAnswer(question: String, answer: String)
}

class QuestionViewController: UIViewController {
    
//  Constraint with constant to adjust based on keyboard height
    private var navigationButtonBottomConstraint: NSLayoutConstraint?
    
    var dayLog: DayLog?
    
    public var delegate: QuestionViewControllerDelegate?
    public var isLastQuestion = false
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubviews()
        setUpConstraints()
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonPressed), for: .touchUpInside)
        textView.delegate = self
        
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
        
        if let question = questionLabel.text, let answer = textView.text {
            delegate?.saveAnswer(question: question, answer: answer)
        }
    }
    
//  MARK: Selectors
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            navigationButtonBottomConstraint?.constant = -(keyboardHeight+10)
        }
    }
    
    @objc func keyboardWillDissapear(_ notification: Notification) {
        navigationButtonBottomConstraint?.constant = -30
    }
    
    @objc func backButtonPressed() {
        //TODO: Clean up
        //TODO: decide which way is better to present - changing VCs or properties (label, buton titles), maybe something else?
        if let question = questionLabel.text, let answer = textView.text {
            delegate?.saveAnswer(question: question, answer: answer)
        }
        
        weak var presentingVC = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let targetVC = QuestionViewController()
            let e = K.questions.firstIndex(of: self.questionLabel.text!)!
            if e == 0 {
                return
            } else {
                targetVC.setLabelText(text: K.questions[e-1])
                presentingVC?.present(targetVC, animated: true)
                
            }
        })
    }
    
    @objc func nextButtonPressed() {
//        TODO: Clean up
        if let question = questionLabel.text, let answer = textView.text {
            delegate?.saveAnswer(question: question, answer: answer)
        }
        //present title for next question
        let e = K.questions.firstIndex(of: questionLabel.text!)!
        if e < K.questions.count - 2 {
            let nextQuestion = K.questions[e+1]
            self.setLabelText(text: nextQuestion)
        } else if e == K.questions.count - 2 {
            let nextQuestion = K.questions[e+1]
            self.setLabelText(text: nextQuestion)
            nextButton.removeFromSuperview()
            self.view.addSubview(finishButton)
            layoutFinishButton()
            print("last question")
        }
        //empty text view for next answer
        textView.text = nil
    }
    
    @objc func finishButtonPressed() {
        self.dismiss(animated: true)
    }
    
//  MARK: UI layout methods
    func addSubviews(){
        view.addSubview(questionLabel)
        view.addSubview(backButton)
        view.addSubview(textView)
        
        if !isLastQuestion {
            view.addSubview(nextButton)
        } else {
            view.addSubview(finishButton)
        }
    }
    
    func setUpConstraints() {
        
        nextButton.layer.cornerRadius = 10
        backButton.layer.cornerRadius = 10
        finishButton.layer.cornerRadius = 10
        textView.layer.cornerRadius = 10
        
        navigationButtonBottomConstraint = backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        if let constraint = navigationButtonBottomConstraint {
            constraint.isActive = true
        }

        NSLayoutConstraint.activate([
            //      layout question label
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            //      layout back button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            //        layout text field
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
        ])
        
        if !isLastQuestion {
            //        layout neck button
            layoutNextButton()
        } else {
            //        layout finish button
            layoutFinishButton()
        }
    }
    
    func layoutNextButton() {
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: view.frame.width/3),
            
        ])
    }
    
    func layoutFinishButton() {
        NSLayoutConstraint.activate([
            finishButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.heightAnchor.constraint(equalToConstant: 50),
            finishButton.widthAnchor.constraint(equalToConstant: view.frame.width/3)
        ])
    }
    
    public func setLabelText(text: String){
        questionLabel.text = text
    }
    
    public func setTextFieldText(text: String) {
        textView.text = text
    }
    
}

//MARK: UITextViewDelegate
extension QuestionViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
