//
//  CalendarDayButton.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/12/22.
//

import UIKit

@IBDesignable class CalendarDayButton: UIButton {

    @IBOutlet private weak var dayNameLabel: UILabel!
    @IBOutlet private weak var dayNumberLabel: UILabel!
    
    public func setDate(date: Date){
        dayNameLabel.text = String(date.formatted(date: .complete, time: .omitted).prefix(3))
        dayNumberLabel.text = String(date.formatted(date: .numeric, time: .omitted).prefix(2))
    }
    
    
//    override sele
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
