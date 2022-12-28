//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//

import UIKit

protocol QuestionViewControllerDelegate {
    func nextButtonPressed(question: String, answer: String)
    func backButtonPressed(question: String, answer: String)
}

class QuestionViewController: UIViewController {
    
//  Constraint with constant to adjust based on keyboard height
    var nextButtonBottomConstraint: NSLayoutConstraint?
    var delegate: QuestionViewControllerDelegate?
    
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
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(named: K.Colors.complement)
        textView.returnKeyType = .done
        
        return textView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDissapear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            nextButtonBottomConstraint?.constant = -(keyboardHeight+10)
        }
    }
    
    @objc func keyboardWillDissapear(_ notification: Notification) {
        nextButtonBottomConstraint?.constant = -30
    }
    //TODO: decide which way is better to present - changing VCs or properties (label, buton titles), maybe something else?
    @objc func backButtonPressed() {
        
        if let question = questionLabel.text, let answer = textView.text {
            delegate?.nextButtonPressed(question: question, answer: answer)
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
        
        if let question = questionLabel.text, let answer = textView.text {
            delegate?.nextButtonPressed(question: question, answer: answer)
        }
        
        //present title for next question
        let e = K.questions.firstIndex(of: questionLabel.text!)!
        if e < K.questions.count - 2 {
            let nextQuestion = K.questions[e+1]
            self.setLabelText(text: nextQuestion)
        } else if e == K.questions.count - 2 {
            let nextQuestion = K.questions[e+1]
            self.setLabelText(text: nextQuestion)
            nextButton.setTitle("Finish", for: .normal)
            print("last question")
        }
        //empty text view for next answer
        textView.text = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AccentColor")
        addSubviews()
        setUpConstraints()
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        textView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addSubviews(){
        view.addSubview(questionLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
        view.addSubview(textView)
    }
    
    func setUpConstraints() {
//      layout question label
        questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        questionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        questionLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        questionLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
//      layout next button
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        if let constraint = nextButtonBottomConstraint {
            constraint.isActive = true
        }
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        nextButton.layer.cornerRadius = 10
//        layout back button
        backButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        backButton.layer.cornerRadius = 10
//        layout text field
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10).isActive = true
        textView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20).isActive = true
        textView.layer.cornerRadius = 10
    }
    
    public func setLabelText(text: String){
        questionLabel.text = text
    }
    
    public func setTextFieldText(text: String) {
        textView.text = text
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QuestionViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
