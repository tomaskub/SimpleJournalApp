//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//

import UIKit

class QuestionViewController: UIViewController {
    
//  Constraint with constant to adjust based on keyboard height
    var nextButtonBottomConstraint: NSLayoutConstraint?
    
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
    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = UIColor(named: K.Colors.complement)
        field.contentVerticalAlignment = .top
        field.returnKeyType = .done
        return field
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AccentColor")
        addSubviews()
        setUpConstraints()
        textField.delegate = self
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
        view.addSubview(textField)
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
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10).isActive = true
        textField.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20).isActive = true
        textField.layer.cornerRadius = 10
    }
    
    public func setLabelText(text: String){
        questionLabel.text = text
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
extension QuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
