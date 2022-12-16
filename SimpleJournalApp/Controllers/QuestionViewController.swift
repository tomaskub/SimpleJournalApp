//
//  QuestionViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/16/22.
//

import UIKit

class QuestionViewController: UIViewController {
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Placeholder text"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: K.Colors.complement)
        return label
    }()
    private let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next Qestion", for: .normal)
        button.backgroundColor = UIColor(named: K.Colors.complement)
        button.titleLabel?.textColor = UIColor(named: K.Colors.accent)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AccentColor")
        addSubviews()
        setUpConstraints()
        // Do any additional setup after loading the view.
    }
    func addSubviews(){
        view.addSubview(questionLabel)
        view.addSubview(nextButton)
    }
    
    func setUpConstraints() {
        questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        questionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        questionLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
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
