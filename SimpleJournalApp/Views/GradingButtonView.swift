//
//  GradingButtonView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/10/23.
//

import UIKit

@IBDesignable class GradingButtonView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var scale: Int = 5
    @IBInspectable var buttonTint: UIColor = .black
    
    private let gradingButtons: [UIButton] = {
        
            var buttons: [UIButton] = []
            for i in 1...5 {
                let button = UIButton()
                button.setTitle(String(i), for: .normal)
            }
        return buttons
        }()
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        for button in gradingButtons {
            addSubview(button)
            button.tintColor = buttonTint
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: self.topAnchor),
                button.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        }
        gradingButtons.first?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        for i in 1...gradingButtons.count-1 {
            NSLayoutConstraint.activate([
                gradingButtons[i].leadingAnchor.constraint(equalTo: gradingButtons[i-1].trailingAnchor),
            ])
        }
        gradingButtons.last?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
    
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
