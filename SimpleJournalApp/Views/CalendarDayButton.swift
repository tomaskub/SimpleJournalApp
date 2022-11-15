//
//  CalendarDayButton.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//

import UIKit

@IBDesignable class CalendarDayButton: UIButton {

    @IBInspectable var secondaryColor: UIColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1)
    @IBInspectable var primaryColor: UIColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    @IBInspectable var tertiaryColor: UIColor = UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1)
    @IBInspectable var isTodayButton: Bool = false
    @IBInspectable var bottomLabelText: String = "DAY"
    @IBInspectable var topLabelText: String = "NN"
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let topLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private struct Constants {
        static let plusLineWidth: CGFloat = 3.0
        static let plusButtonScale: CGFloat = 0.6
        static let halfPointShift: CGFloat = 0.5
    }
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }
    
    private var mainHeight: CGFloat {
        return bounds.height
    }
    private var mainWidth: CGFloat {
        return bounds.width
    }
    private var mainCornerRadius: CGFloat {
        return  0.175 * min(mainWidth, mainHeight)
    }
    
    override func draw(_ rect: CGRect) {

        // Draw card
        //main card rectangle
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: mainWidth, height: mainHeight), cornerRadius: mainCornerRadius)
        secondaryColor.setFill()
        path.fill()
        //internal card rectangle
        let secondaryPath = UIBezierPath(roundedRect: CGRect(x: mainWidth * 0.125, y: mainHeight * 0.125, width: mainWidth * 0.75 , height: mainHeight * 0.6), cornerRadius: mainCornerRadius * 0.5)
        primaryColor.setFill()
        secondaryPath.fill()
        //Set up button labels
        bottomLabel.text = bottomLabelText
        bottomLabel.textColor = tertiaryColor
        bottomLabel.font = .systemFont(ofSize: mainHeight * 0.2 )
        topLabel.text = topLabelText
        topLabel.font = .systemFont(ofSize: mainHeight * 0.3 , weight: .bold)
        topLabel.textColor = secondaryColor
        //Add labels and constraints
        self.addSubview(bottomLabel)
        bottomLabel.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.15 * mainHeight).isActive = true
        bottomLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.addSubview(topLabel)
        topLabel.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.575 * mainHeight).isActive = true
        topLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    }
    
    func setTopLabelText(text: String) -> Void {
        topLabelText = text
    }
    func setBottomLabelText(text: String) -> Void {
        bottomLabelText = text
    }
    
}
