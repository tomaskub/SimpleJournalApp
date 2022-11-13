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
    private var mainDimension: CGFloat {
        if 1+bounds.height == bounds.width {
            return 0.85 * bounds.height
        } else {
            
            return min (bounds.height, bounds.width)
            
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // main card rectangle
        let path = UIBezierPath(roundedRect: CGRect(x: 0, //mainDimension * 0.15 / 2,
                                                    y: 0, width: mainDimension, height: mainDimension*1.2), cornerRadius: mainDimension * 0.15)
        secondaryColor.setFill()
        path.fill()
//        path.lineWidth = Constants.plusLineWidth / 2
//        UIColor.black.setStroke()
//        path.stroke()
        // calendar card rectangle
        let secondaryPath = UIBezierPath(roundedRect: CGRect(x: mainDimension * 0.1, y: mainDimension * 0.1, width: mainDimension * 0.8 , height: mainDimension * 0.7), cornerRadius: 0.15 * mainDimension)
        primaryColor.setFill()
        secondaryPath.fill()
        
        if isTodayButton {
            let plusWidth = min(bounds.width, bounds.height) * Constants.plusButtonScale
            let halfPlusWidth = plusWidth / 2
            let plusPath = UIBezierPath()
            plusPath.lineWidth = Constants.plusLineWidth
            plusPath.move(to: CGPoint(x: halfWidth - halfPlusWidth, y: halfHeight))
            plusPath.addLine(to: CGPoint(x: halfWidth + halfPlusWidth, y: halfHeight))
            plusPath.move(to: CGPoint(x: halfWidth, y: halfHeight + halfPlusWidth))
            plusPath.addLine(to: CGPoint(x: halfWidth, y: halfHeight-halfPlusWidth))
            UIColor.white.setFill()
            plusPath.stroke()
        }
        
        //Set up button labels
        bottomLabel.text = bottomLabelText
        bottomLabel.textColor = tertiaryColor
        
        topLabel.text = topLabelText
        topLabel.font = .systemFont(ofSize: mainDimension * 0.3 , weight: .bold)
        topLabel.textColor = secondaryColor
        
        self.addSubview(bottomLabel)
        bottomLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.10 * mainDimension).isActive = true
        bottomLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.addSubview(topLabel)
        topLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.57 * mainDimension).isActive = true
        topLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
    }
    
    func setTopLabelText(text: String) -> Void {
//        topLabel.text = text
        topLabelText = text
//        self.setNeedsUpdateConfiguration()
    }
    func setBottomLabelText(text: String) -> Void {
        bottomLabelText = text
    }
    
}
